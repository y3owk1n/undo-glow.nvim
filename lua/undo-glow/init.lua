local M = {}

local ns = vim.api.nvim_create_namespace("undo-glow")

-- Default configuration
---@class UndoGlow.Config
---@field duration number In ms
---@field undo_hl string
---@field redo_hl string
---@field undo_hl_color vim.api.keyset.highlight
---@field redo_hl_color vim.api.keyset.highlight
M.config = {
	duration = 300,
	undo_hl = "UgUndo",
	redo_hl = "UgRedo",
	undo_hl_color = { bg = "#FF5555", fg = "#000000" },
	redo_hl_color = { bg = "#50FA7B", fg = "#000000" },
}

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

--- Callback to track changes
---@param state{should_detach:boolean,current_hlgroup: string} State
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
	if state.should_detach then
		return true
	end

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
			highlight_range(
				bufnr,
				state.current_hlgroup,
				s_row,
				s_col,
				end_row,
				end_col
			)
		end
	end)
	return false
end

-- Clear highlights after a duration
---@param bufnr integer Buffer number
---@param state{should_detach:boolean,current_hlgroup: string} State
local function clear_highlights(bufnr, state)
	vim.defer_fn(function()
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
		end
		state.should_detach = true
	end, M.config.duration)
end

-- Helper to attach to a buffer with a local state.
---@param hlgroup string
---@param cmd function
local function attach_and_run(hlgroup, cmd)
	local bufnr = vim.api.nvim_get_current_buf()

	local state = { should_detach = false }
	state.current_hlgroup = hlgroup

	vim.api.nvim_buf_attach(bufnr, false, {
		on_bytes = function(...)
			return on_bytes_wrapper(state, ...)
		end,
	})

	cmd()

	clear_highlights(bufnr, state)
end

function M.undo()
	attach_and_run(M.config.undo_hl, function()
		vim.cmd("undo")
	end)
end

function M.redo()
	attach_and_run(M.config.redo_hl, function()
		vim.cmd("redo")
	end)
end

---@param user_config? UndoGlow.Config
function M.setup(user_config)
	M.config = vim.tbl_extend("force", M.config, user_config or {})

	set_highlight(M.config.undo_hl, M.config.undo_hl_color)
	set_highlight(M.config.redo_hl, M.config.redo_hl_color)
end

return M
