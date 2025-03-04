local M = {}

---Undo command that highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.undo(opts)
	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgUndo", opts)
	require("undo-glow").highlight_changes(opts)
	pcall(vim.cmd, "undo")
end

---Redo command that highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.redo(opts)
	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgRedo", opts)
	require("undo-glow").highlight_changes(opts)
	pcall(vim.cmd, "redo")
end

---Yank command that highlights.
---For autocmd usage only.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.yank(opts)
	opts = require("undo-glow.utils").merge_command_opts("UgYank", opts)

	local pos = vim.fn.getpos("'[")
	local pos2 = vim.fn.getpos("']")

	require("undo-glow").highlight_region(vim.tbl_extend("force", opts, {
		s_row = pos[2] - 1,
		s_col = pos[3] - 1,
		e_row = pos2[2] - 1,
		e_col = pos2[3],
	}))
end

---Paste below command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.paste_below(opts)
	opts = require("undo-glow.utils").merge_command_opts("UgPaste", opts)
	require("undo-glow").highlight_changes(opts)
	local register = vim.v.register
	pcall(vim.cmd, string.format('normal! "%sp"', register))
end

---Paste above command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.paste_above(opts)
	opts = require("undo-glow.utils").merge_command_opts("UgPaste", opts)
	require("undo-glow").highlight_changes(opts)
	local register = vim.v.register
	pcall(vim.cmd, string.format('normal! "%sP"', register))
end

---Highlight current line after a search is performed.
---For autocmd usage only.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.search_cmd(opts)
	local is_search_cmd = vim.v.event.cmdtype == "/"
		or vim.v.event.cmdtype == "?"

	local is_search_abort = vim.v.event.abort

	if not is_search_cmd or is_search_abort then
		return
	end

	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgSearch", opts)

	local current_win = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(current_win)
	local current_row = cursor[1] - 1
	local line = vim.api.nvim_get_current_line()

	require("undo-glow").highlight_region(vim.tbl_extend("force", opts, {
		s_row = current_row,
		s_col = 0,
		e_row = current_row,
		e_col = #line,
		force_edge = type(opts.force_edge) == "nil" and true or opts.force_edge,
	}))
end

---Search next command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.search_next(opts)
	vim.g.ug_ignore_cursor_moved = true

	local ok = pcall(vim.cmd, "normal! n")

	if not ok then
		return
	end
	local region = require("undo-glow.utils").get_search_region()

	if not region then
		return
	end

	opts = require("undo-glow.utils").merge_command_opts("UgSearch", opts)

	require("undo-glow").highlight_region(vim.tbl_extend("force", opts, {
		s_row = region.s_row,
		s_col = region.s_col,
		e_row = region.e_row,
		e_col = region.e_col,
	}))
end

---Search prev command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.search_prev(opts)
	vim.g.ug_ignore_cursor_moved = true

	local ok = pcall(vim.cmd, "normal! N")

	if not ok then
		return
	end

	local region = require("undo-glow.utils").get_search_region()

	if not region then
		return
	end

	opts = require("undo-glow.utils").merge_command_opts("UgSearch", opts)

	require("undo-glow").highlight_region(vim.tbl_extend("force", opts, {
		s_row = region.s_row,
		s_col = region.s_col,
		e_row = region.e_row,
		e_col = region.e_col,
	}))
end

---Search star (*) command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.search_star(opts)
	vim.g.ug_ignore_cursor_moved = true

	local ok = pcall(vim.cmd, "normal! *")

	if not ok then
		return
	end
	local region = require("undo-glow.utils").get_search_star_region()

	if not region then
		return
	end

	opts = require("undo-glow.utils").merge_command_opts("UgSearch", opts)

	require("undo-glow").highlight_region(vim.tbl_extend("force", opts, {
		s_row = region.s_row,
		s_col = region.s_col,
		e_row = region.e_row,
		e_col = region.e_col,
	}))
end

---Comment with `gc` in `n` and `x` mode with highlights.
---Requires `expr` = true in ``vim.keymap.set`
---@param opts? UndoGlow.CommandOpts Optional command option
---@return string|nil expression String for expression and nil for non-expression
function M.comment(opts)
	opts = require("undo-glow.utils").merge_command_opts("UgComment", opts)
	require("undo-glow").highlight_changes(opts)
	return require("vim._comment").operator()
end

---Comment with `gc` in `o` mode. E.g. gcip, gcap, etc with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.comment_textobject(opts)
	opts = require("undo-glow.utils").merge_command_opts("UgComment", opts)
	require("undo-glow").highlight_changes(opts)
	return require("vim._comment").textobject()
end

---Comment lines with `gcc` with highlights.
---Requires `expr` = true in ``vim.keymap.set`
---@param opts? UndoGlow.CommandOpts Optional command option
---@return string expression String for expression
function M.comment_line(opts)
	opts = require("undo-glow.utils").merge_command_opts("UgComment", opts)
	require("undo-glow").highlight_changes(opts)
	return require("vim._comment").operator() .. "_"
end

---Cursor move command that highlights.
---For autocmd usage only.
---@param opts? UndoGlow.CommandOpts Optional command option
---@param ignored_ft? table<string> Optional filetypes to ignore
---@return nil
function M.cursor_moved(opts, ignored_ft)
	opts = require("undo-glow.utils").merge_command_opts("UgCursor", opts)

	local current_buf = vim.api.nvim_get_current_buf()
	local current_win = vim.api.nvim_get_current_win()

	if not vim.api.nvim_buf_is_loaded(current_buf) then
		return
	end

	local is_preview_window = vim.wo.previewwindow

	-- NOTE: Disable floating window will also disable lazy, mason, zen mode and more that uses it
	-- This come in handy to disable almost all snacks related windows
	-- Consider different approach maybe by explicitly ignore filetype and do not ignore floating window, but
	-- we will then need to maintain a list of it.
	local is_floating_window = vim.api.nvim_win_get_config(current_win).relative
		~= ""

	local is_not_text_buffer = vim.bo.buftype ~= ""

	local is_ignored_ft = vim.tbl_contains(ignored_ft or {}, vim.bo.filetype)

	if
		is_preview_window
		or is_floating_window
		or is_not_text_buffer
		or is_ignored_ft
	then
		return
	end

	local current_row, current_col = unpack(vim.api.nvim_win_get_cursor(0))

	local prev_buf = vim.g.ug_prev_buf
	local prev_row = vim.g.ug_prev_cursor or current_row
	local prev_win = vim.g.ug_prev_win

	local diff = math.abs(current_row - prev_row)
	local new_buffer = (prev_buf ~= current_buf)
	local new_window = (prev_win ~= current_win)

	if not vim.g.ug_ignore_cursor_moved then
		if diff > 10 or new_buffer or new_window then
			local cur_line = vim.api.nvim_get_current_line()
			local cur_line_length = #cur_line
			require("undo-glow").highlight_region(
				vim.tbl_extend("force", opts, {
					s_row = current_row - 1,
					s_col = 0, -- use current_col if want to start from the cursor, i think full width is nicer
					e_row = current_row - 1,
					e_col = cur_line_length,
					force_edge = type(opts.force_edge) == "nil" and true
						or opts.force_edge,
				})
			)
		end
	end

	vim.g.ug_prev_cursor = current_row
	vim.g.ug_prev_buf = current_buf
	vim.g.ug_prev_win = current_win

	if vim.g.ug_ignore_cursor_moved == true then
		vim.g.ug_ignore_cursor_moved = nil
	end
end

return M
