local M = {}

local counter = 0 -- For unique highlight groups

M.ns = vim.api.nvim_create_namespace("undo-glow")

local color = require("undo-glow.color")
local highlight = require("undo-glow.highlight")

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
		-- If animation is off, use the existing hlgroup else use unique hlgroups.
		-- Unique hlgroups is needed for animated version, because we will be changing the hlgroup colors during
		-- animation.
		local unique_hlgroup = opts.config.animation
				and M.get_unique_hlgroup(opts.state.current_hlgroup)
			or opts.state.current_hlgroup

		-- TODO: Think of any other way that don't need to follow links or faster
		-- Follow links if exists and get the actual color code for bg and fg
		local current_hlgroup_detail =
			highlight.resolve_hlgroup(opts.state.current_hlgroup)

		local bg = nil
		local fg = nil

		if not current_hlgroup_detail.bg then
			bg = color.default_undo.bg
		else
			bg = string.format("#%06X", current_hlgroup_detail.bg)
		end

		if not current_hlgroup_detail.fg then
			fg = nil
		else
			fg = string.format("#%06X", current_hlgroup_detail.fg)
		end

		local init_color = {
			bg = bg,
			fg = fg,
		}

		local extmark_id = M.highlight_range(
			opts.bufnr,
			unique_hlgroup,
			opts.s_row,
			opts.s_col,
			opts.e_row,
			opts.e_col
		)

		require("undo-glow.animation").clear_highlights(
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

return M
