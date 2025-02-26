local M = {}

local counter = 0 -- For unique highlight groups

M.ns = vim.api.nvim_create_namespace("undo-glow")

---@param base string
---@return string
function M.get_unique_hlgroup(base)
	counter = counter + 1

	-- Reset counter if it becomes too high
	if counter > 1e6 then
		counter = 1
	end
	return base .. "_" .. counter
end

-- Sanitize coordinates to prevent out-of-range
---@param bufnr integer Buffer number
---@param s_row integer Start row
---@param s_col integer Start column
---@param e_row integer End row
---@param e_col integer End column
---@return integer, integer, integer, integer
function M.sanitize_coords(bufnr, s_row, s_col, e_row, e_col)
	local line_count = vim.api.nvim_buf_line_count(bufnr)

	-- Make sure s_row is within range
	if s_row < 0 then
		s_row = 0
	end
	if s_row > line_count then
		s_row = line_count
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
	if e_row > line_count then
		e_row = line_count
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
---@return integer
function M.highlight_range(bufnr, hlgroup, s_row, s_col, e_row, e_col)
	s_row, s_col, e_row, e_col =
		M.sanitize_coords(bufnr, s_row, s_col, e_row, e_col)

	local extmark_id = vim.api.nvim_buf_set_extmark(bufnr, M.ns, s_row, s_col, {
		end_row = e_row,
		end_col = e_col,
		hl_group = hlgroup,
		hl_mode = "combine",
	})

	return extmark_id
end

---@param opts UndoGlow.HandleHighlight
function M.handle_highlight(opts)
	if vim.api.nvim_buf_is_valid(opts.bufnr) then
		opts = M.validate_state_for_highlight(opts)

		-- If animation is off, use the existing hlgroup else use unique hlgroups.
		-- Unique hlgroups is needed for animated version, because we will be changing the hlgroup colors during
		-- animation.
		local unique_hlgroup = opts.state.animation.enabled
				and M.get_unique_hlgroup(opts.state.current_hlgroup)
			or opts.state.current_hlgroup

		-- TODO: Think of any other way that don't need to follow links or faster
		-- Follow links if exists and get the actual color code for bg and fg
		local current_hlgroup_detail =
			require("undo-glow.highlight").resolve_hlgroup(
				opts.state.current_hlgroup
			)

		local init_color =
			require("undo-glow.color").init_colors(current_hlgroup_detail)

		local extmark_id = M.highlight_range(
			opts.bufnr,
			unique_hlgroup,
			opts.s_row,
			opts.s_col,
			opts.e_row,
			opts.e_col
		)

		M.animate_or_clear_highlights(
			opts.bufnr,
			opts.state,
			unique_hlgroup,
			extmark_id,
			init_color.bg,
			init_color.fg,
			opts.config
		)
	end
end

---@return UndoGlow.RowCol | nil
function M.get_search_region()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1
	local col = cursor[2]

	local search_pattern = vim.fn.getreg("/")
	if search_pattern == "" then
		return
	end

	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
	if not line then
		return
	end

	local match_start, match_end
	local offset = 1
	while true do
		local s, e = line:find(search_pattern, offset)
		if not s then
			break
		end

		local s0 = s - 1

		if col >= s0 and col < e then
			match_start, match_end = s, e
			break
		end

		if s0 > col then
			match_start, match_end = s, e
			break
		end
		offset = e + 1
	end

	if not match_start or not match_end then
		match_start, match_end = line:find(search_pattern)
		if not match_start or not match_end then
			return
		end
	end

	return {
		s_row = row,
		s_col = match_start - 1,
		e_row = row,
		e_col = match_end,
	}
end

---@return UndoGlow.RowCol | nil
function M.get_search_star_region()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1

	local search_pattern = vim.fn.getreg("/")
	if search_pattern == "" then
		return
	end

	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
	if not line then
		return
	end

	local reg = vim.regex(search_pattern)
	local match_start = reg:match_str(line)
	if match_start == nil then
		return
	end

	local matched_text = vim.fn.matchstr(line, search_pattern)
	local match_end = match_start + #matched_text

	return {
		s_row = row,
		s_col = match_start,
		e_row = row,
		e_col = match_end,
	}
end

-- Animate or clear highlights after a duration
---@param bufnr integer Buffer number
---@param state UndoGlow.State State
---@param hlgroup string Unique highlight group name
---@param extmark_id integer
---@param start_bg string The starting background color (hex)
---@param start_fg? string The starting foreground color (hex)
---@param config UndoGlow.Config
function M.animate_or_clear_highlights(
	bufnr,
	state,
	hlgroup,
	extmark_id,
	start_bg,
	start_fg,
	config
)
	local end_bg = require("undo-glow.color").get_normal_bg()
	local end_fg = require("undo-glow.color").get_normal_fg()

	if state.animation.enabled then
		---@type UndoGlow.Animation
		local animation_opts = {
			bufnr = bufnr,
			hlgroup = hlgroup,
			extmark_id = extmark_id,
			start_bg = require("undo-glow.color").hex_to_rgb(start_bg),
			end_bg = require("undo-glow.color").hex_to_rgb(end_bg),
			start_fg = start_fg and require("undo-glow.color").hex_to_rgb(
				start_fg
			) or nil,
			end_fg = start_fg and require("undo-glow.color").hex_to_rgb(end_fg)
				or nil,
			duration = state.animation.duration,
			config = config,
			state = state,
		}

		state.animation.animation_type(animation_opts)
	else
		vim.defer_fn(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_del_extmark(
					bufnr,
					require("undo-glow.utils").ns,
					extmark_id
				)
			end
		end, state.animation.duration)
	end

	state.should_detach = true
end

---@param hlgroup string
---@param opts? UndoGlow.CommandOpts
---@return UndoGlow.CommandOpts
function M.merge_command_opts(hlgroup, opts)
	opts = vim.tbl_extend("force", {
		hlgroup = hlgroup,
		animation = {
			enabled = nil,
			animation_type = nil,
			duration = nil,
			easing = nil,
			fps = nil,
		},
	}, opts or {})

	return opts
end

---@param opts? UndoGlow.CommandOpts
---@return UndoGlow.State
function M.create_state(opts)
	opts = opts or {}
	opts.animation = opts.animation or {}

	return {
		should_detach = false,
		current_hlgroup = opts.hlgroup or "UgUndo",
		animation = {
			animation_type = M.get_animation_type(
				opts.animation.animation_type
			) or nil,
			enabled = opts.animation.enabled or nil,
			duration = opts.animation.duration or nil,
			easing = M.get_easing(opts.animation.easing) or nil,
			fps = opts.animation.fps or nil,
		},
	}
end

---@param opts UndoGlow.HandleHighlight
---@return UndoGlow.HandleHighlight
function M.validate_state_for_highlight(opts)
	-- Check animation status and fallback to global
	if type(opts.state.animation.enabled) ~= "boolean" then
		opts.state.animation.enabled = opts.config.animation.enabled
	end

	-- Check animation_type and fallback to global
	if not opts.state.animation.animation_type then
		opts.state.animation.animation_type =
			M.get_animation_type(opts.config.animation.animation_type)
	end

	-- Check duration and fallback to global
	if not opts.state.animation.duration then
		opts.state.animation.duration = opts.config.animation.duration
	end

	-- Check easing and fallback to global
	if not opts.state.animation.easing then
		opts.state.animation.easing = M.get_easing(opts.config.animation.easing)
	end

	-- Check fps and fallback to global
	if not opts.state.animation.fps then
		opts.state.animation.fps = opts.config.animation.fps
	end

	return opts
end

---@param easing? UndoGlow.EasingString|UndoGlow.EasingFn
---@return UndoGlow.EasingFn|nil
function M.get_easing(easing)
	if type(easing) == "function" then
		return easing
	end
	if type(easing) == "string" then
		return require("undo-glow.easing")[easing]
	end

	return nil
end

---@param animation_type? UndoGlow.AnimationTypeString|UndoGlow.AnimationTypeFn
---@return UndoGlow.AnimationTypeFn|nil
function M.get_animation_type(animation_type)
	if type(animation_type) == "function" then
		return animation_type
	end
	if type(animation_type) == "string" then
		return require("undo-glow.animation").animate[animation_type]
	end

	return nil
end

return M
