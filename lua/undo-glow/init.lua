local M = {}

local ns = vim.api.nvim_create_namespace("undo-glow")
local counter = 0 -- For unique highlight groups

---@class UndoGlow.Config
---@field duration number In ms
---@field animation boolean
---@field undo_hl string
---@field redo_hl string
---@field undo_hl_color vim.api.keyset.highlight
---@field redo_hl_color vim.api.keyset.highlight

---@class UndoGlow.State
---@field current_hlgroup string

---@class UndoGlow.RGBColor
---@field r integer Red (0-255)
---@field g integer Green (0-255)
---@field b integer Blue (0-255)

---@class UndoGlow.AttachAndRunOpts
---@field hlgroup string
---@field cmd? function

-- Default configuration
---@type UndoGlow.Config
M.config = {
	duration = 300,
	animation = true,
	undo_hl = "UgUndo",
	redo_hl = "UgRedo",
	undo_hl_color = { bg = "#FF5555", fg = "#000000" },
	redo_hl_color = { bg = "#50FA7B", fg = "#000000" },
}

-- Utility functions for color manipulation and easing
---@param hex string
---@return UndoGlow.RGBColor
local function hex_to_rgb(hex)
	hex = hex:gsub("#", "")
	return {
		r = tonumber(hex:sub(1, 2), 16),
		g = tonumber(hex:sub(3, 4), 16),
		b = tonumber(hex:sub(5, 6), 16),
	}
end
---@param rgb UndoGlow.RGBColor
---@return string
local function rgb_to_hex(rgb)
	return string.format("#%02X%02X%02X", rgb.r, rgb.g, rgb.b)
end

---@param c1 UndoGlow.RGBColor
---@param c2 UndoGlow.RGBColor
---@param t number (0-1) Interpolation factor
---@return string
local function blend_color(c1, c2, t)
	local r = math.floor(c1.r + (c2.r - c1.r) * t + 0.5)
	local g = math.floor(c1.g + (c2.g - c1.g) * t + 0.5)
	local b = math.floor(c1.b + (c2.b - c1.b) * t + 0.5)
	return rgb_to_hex({ r = r, g = g, b = b })
end

---@param t number (0-1) Interpolation factor
---@return number
local function ease_out_quad(t)
	return 1 - (1 - t) * (1 - t)
end

---@return string
local function get_normal_bg()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
	if normal.bg then
		return string.format("#%06X", normal.bg)
	else
		return "#000000"
	end
end

-- Animate the fadeout of a highlight group from a start color to the Normal background
---@param bufnr integer Buffer number
---@param hlgroup string
---@param start_color UndoGlow.RGBColor
---@param end_color UndoGlow.RGBColor
---@param duration integer
local function animate_fadeout(bufnr, hlgroup, start_color, end_color, duration)
	local start_time = vim.loop.hrtime()
	local interval = 16 -- roughly 60 FPS (16ms per frame)
	local timer = vim.loop.new_timer()

	timer:start(
		0,
		interval,
		vim.schedule_wrap(function()
			local now = vim.loop.hrtime()
			local elapsed = (now - start_time) / 1e6 -- convert from ns to ms
			local t = math.min(elapsed / duration, 1)
			local eased = ease_out_quad(t)
			local blended = blend_color(start_color, end_color, eased)

			vim.api.nvim_set_hl(0, hlgroup, { bg = blended })

			if t >= 1 then
				timer:stop()
				timer:close()
				if vim.api.nvim_buf_is_valid(bufnr) then
					vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
				end
			end
		end)
	)
end

---@param name string Highlight name
---@param color vim.api.keyset.highlight
local function set_highlight(name, color)
	if vim.fn.hlexists(name) == 0 then
		vim.api.nvim_set_hl(0, name, color)
	end
end

-- Sanitize coordinates to prevent out-of-range
---@param bufnr integer Buffer number
---@param s_row integer Start row
---@param s_col integer Start column
---@param e_row integer End row
---@param e_col integer End column
---@return integer, integer, integer, integer
local function sanitize_coords(bufnr, s_row, s_col, e_row, e_col)
	local line_count = vim.api.nvim_buf_line_count(bufnr)

	-- Make sure s_row is within range
	if s_row < 0 then
		s_row = 0
	end
	if s_row >= line_count then
		s_row = line_count - 1
	end

	-- Clamp s_col
	local start_line = vim.api.nvim_buf_get_lines(
		bufnr,
		s_row,
		s_row + 1,
		false
	)[1] or ""
	if s_col < 0 then
		s_col = 0
	end
	if s_col > #start_line then
		s_col = #start_line
	end

	-- Make sure e_row is within range
	if e_row < s_row then
		e_row = s_row
	end
	if e_row >= line_count then
		e_row = line_count - 1
	end

	-- Clamp e_col
	local end_line = vim.api.nvim_buf_get_lines(bufnr, e_row, e_row + 1, false)[1]
		or ""
	if e_col < 0 then
		e_col = 0
	end
	if e_col > #end_line then
		e_col = #end_line
	end

	return s_row, s_col, e_row, e_col
end

-- Highlight a range in the buffer
---@param bufnr integer Buffer number
---@param hlgroup string Highlight group
---@param s_row integer Start row
---@param s_col integer Start column
---@param e_row integer End row
---@param e_col integer End column
local function highlight_range(bufnr, hlgroup, s_row, s_col, e_row, e_col)
	s_row, s_col, e_row, e_col =
		sanitize_coords(bufnr, s_row, s_col, e_row, e_col)

	vim.api.nvim_buf_set_extmark(bufnr, ns, s_row, s_col, {
		end_row = e_row,
		end_col = e_col,
		hl_group = hlgroup,
		hl_mode = "combine",
	})
end

-- Animate or clear highlights after a duration
---@param bufnr integer Buffer number
---@param hlgroup string Unique highlight group name
---@param start_bg string The starting background color (hex)
local function clear_highlights(bufnr, hlgroup, start_bg)
	local end_bg = get_normal_bg()

	if M.config.animation then
		animate_fadeout(
			bufnr,
			hlgroup,
			hex_to_rgb(start_bg),
			hex_to_rgb(end_bg),
			M.config.duration
		)
	else
		vim.defer_fn(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
			end
		end, M.config.duration)
	end
end

--- Callback to track changes
---@param state UndoGlow.State State
---@param _err any Error
---@param bufnr integer Buffer number
---@param _changedtick any Changed tick
---@param s_row integer Start row
---@param s_col integer Start column
---@param _byte_offset any Byte offset
---@param _old_er any Old end row
---@param _old_ec any Old end column
---@param _old_off any Old offset
---@param new_er integer New end row
---@param new_ec integer New end column
---@param _new_off any New offset
---@return boolean
local function on_bytes_wrapper(
	state,
	_err,
	bufnr,
	_changedtick,
	s_row,
	s_col,
	_byte_offset,
	_old_er,
	_old_ec,
	_old_off,
	new_er,
	new_ec,
	_new_off
)
	-- Calculate the ending position.
	local end_row, end_col
	if new_er == 0 then
		-- Single-line change: new_ec is relative to the start column.
		end_row = s_row
		end_col = s_col + new_ec
	else
		-- Multi-line change: new_er is the number of lines added,
		-- and new_ec is the absolute column on the last line.
		end_row = s_row + new_er
		end_col = new_ec
	end

	vim.schedule(function()
		if vim.api.nvim_buf_is_valid(bufnr) then
			counter = counter + 1
			local unique_hlgroup = state.current_hlgroup .. "_" .. counter

			local init_color = (
				state.current_hlgroup == M.config.undo_hl
				and M.config.undo_hl_color
			) or M.config.redo_hl_color

			set_highlight(unique_hlgroup, init_color)

			highlight_range(
				bufnr,
				unique_hlgroup,
				s_row,
				s_col,
				end_row,
				end_col
			)

			clear_highlights(bufnr, unique_hlgroup, init_color.bg)
		end
	end)
	return false
end

-- Helper to attach to a buffer with a local state.
---@param opts UndoGlow.AttachAndRunOpts
function M.attach_and_run(opts)
	local bufnr = vim.api.nvim_get_current_buf()

	---@type UndoGlow.State
	local state = { current_hlgroup = opts.hlgroup }

	vim.api.nvim_buf_attach(bufnr, false, {
		on_bytes = function(...)
			return on_bytes_wrapper(state, ...)
		end,
	})

	if opts.cmd then
		opts.cmd()
	end
end

function M.undo()
	M.attach_and_run({
		hlgroup = M.config.undo_hl,
		cmd = function()
			vim.cmd("undo")
		end,
	})
end

function M.redo()
	M.attach_and_run({
		hlgroup = M.config.redo_hl,
		cmd = function()
			vim.cmd("redo")
		end,
	})
end

---@param user_config? UndoGlow.Config
function M.setup(user_config)
	M.config = vim.tbl_extend("force", M.config, user_config or {})

	set_highlight(M.config.undo_hl, M.config.undo_hl_color)
	set_highlight(M.config.redo_hl, M.config.redo_hl_color)
end

return M
