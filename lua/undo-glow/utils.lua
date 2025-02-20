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

return M
