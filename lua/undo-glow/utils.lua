local M = {}

local counter = 0 -- For unique highlight groups

M.ns = vim.api.nvim_create_namespace("undo-glow")

---Generates a unique highlight group name based on the given base.
---Increments an internal counter and appends it to the base string.
---@param base string The base name for the highlight group.
---@return string unique_hlgroup The unique highlight group name.
function M.get_unique_hlgroup(base)
	counter = counter + 1

	-- Reset counter if it becomes too high
	if counter > 1e6 then
		counter = 1
	end
	return base .. "_" .. counter
end

---Sanitizes coordinates to ensure they fall within the valid range for the given buffer.
---@param bufnr integer Buffer number.
---@param s_row integer Start row.
---@param s_col integer Start column.
---@param e_row integer End row.
---@param e_col integer End column.
---@return integer start_row Sanitized start row (1-based).
---@return integer start_col Sanitized start column (1-based).
---@return integer end_row Sanitized end row (1-based).
---@return integer end_col Sanitized end column (1-based).
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

---Highlights a range in the buffer using an extmark.
---Optionally forces edge highlighting by padding the virtual text.
---@param bufnr integer Buffer number.
---@param hlgroup string Highlight group name.
---@param s_row integer Start row.
---@param s_col integer Start column.
---@param e_row integer End row.
---@param e_col integer End column.
---@param force_edge? boolean Optional flag to force edge highlighting.
---@return integer extmark_id Extmark ID for the created highlight.
function M.highlight_range(
	bufnr,
	hlgroup,
	s_row,
	s_col,
	e_row,
	e_col,
	force_edge
)
	s_row, s_col, e_row, e_col =
		M.sanitize_coords(bufnr, s_row, s_col, e_row, e_col)

	---@type vim.api.keyset.set_extmark
	local opts = {
		end_row = e_row,
		end_col = e_col,
		hl_group = hlgroup,
		hl_mode = "combine",
	}

	if type(force_edge) == "boolean" and force_edge == true then
		local line = vim.api.nvim_buf_get_lines(bufnr, s_row, s_row + 1, false)[1]
			or ""
		local text_width = vim.fn.strdisplaywidth(line)
		local win_width = vim.api.nvim_win_get_width(0)
		local pad = win_width - text_width
		if pad > 0 then
			opts.virt_text = { { string.rep(" ", pad), hlgroup } }
			opts.virt_text_win_col = text_width
		end
	end

	local extmark_id =
		vim.api.nvim_buf_set_extmark(bufnr, M.ns, s_row, s_col, opts)
	return extmark_id
end

---Handles highlighting for a buffer by validating state, applying animations (if enabled),
---and ultimately setting up the extmark.
---@param opts UndoGlow.HandleHighlight The handle highlight options.
---@return nil
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
			opts.e_col,
			opts.state.force_edge
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

---Determines the region of the current search pattern based on the cursor position.
---@return UndoGlow.RowCol|nil region A table containing s_row, s_col, e_row, and e_col for the search region, or nil if not found.
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

---Determines the "search star" region based on the current search pattern and cursor position.
---@return UndoGlow.RowCol|nil region A table containing s_row, s_col, e_row, and e_col for the search star region, or nil if not found.
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

---Animates or clears highlights after a duration based on the state configuration.
---If animations are enabled, it invokes the animation callback; otherwise, it defers the removal of the extmark.
---@param bufnr integer Buffer number.
---@param state UndoGlow.State The state containing animation configuration.
---@param hlgroup string Unique highlight group name.
---@param extmark_id integer The extmark ID of the highlight.
---@param start_bg string The starting background color (hex).
---@param start_fg? string The starting foreground color (hex).
---@param config UndoGlow.Config The configuration options.
---@return nil
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

---Merges a given highlight group into the command options.
---@param hlgroup string The highlight group name.
---@param opts? UndoGlow.CommandOpts Optional command options.
---@return UndoGlow.CommandOpts The merged command options.
function M.merge_command_opts(hlgroup, opts)
	opts = (type(opts) == "table") and opts or {}

	opts = vim.tbl_extend("force", {
		hlgroup = hlgroup,
		animation = {
			enabled = nil,
			animation_type = nil,
			duration = nil,
			easing = nil,
			fps = nil,
		},
		force_edge = nil,
	}, opts)

	return opts
end

---Creates a state table from the provided command options.
---@param opts? UndoGlow.CommandOpts Optional command options.
---@return UndoGlow.State The created state table.
function M.create_state(opts)
	opts = opts or {}
	opts.animation = opts.animation or {}

	return {
		should_detach = false,
		current_hlgroup = opts.hlgroup or "UgUndo",
		force_edge = type(opts.force_edge) == "nil" and false
			or opts.force_edge,
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

---Validates and updates the state for highlighting by falling back to configuration defaults when necessary.
---@param opts UndoGlow.HandleHighlight The handle highlight options.
---@return UndoGlow.HandleHighlight The validated and updated handle highlight options.
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

---Retrieves an easing function based on the provided option.
---Accepts either a function or a string key to look up the easing function.
---@param easing? UndoGlow.EasingString|UndoGlow.EasingFn The easing option.
---@return UndoGlow.EasingFn|nil easing_fn The easing function, or nil if not found.
function M.get_easing(easing)
	if type(easing) == "function" then
		return easing
	end
	if type(easing) == "string" then
		return require("undo-glow.easing")[easing]
	end

	return nil
end

---Retrieves an animation type function based on the provided option.
---Accepts either a function or a string key to look up the animation type function.
---@param animation_type? UndoGlow.AnimationTypeString|UndoGlow.AnimationTypeFn The animation type option.
---@return UndoGlow.AnimationTypeFn|nil animation_type_fn The animation type function, or nil if not found.
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
