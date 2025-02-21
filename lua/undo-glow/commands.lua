local M = {}

function M.undo()
	require("undo-glow").highlight_changes({
		hlgroup = "UgUndo",
	})
	vim.cmd("undo")
end

function M.redo()
	require("undo-glow").highlight_changes({
		hlgroup = "UgRedo",
	})
	vim.cmd("redo")
end

--- Helper to use this in autocmds. Do not use this as a command, it does nothing.
function M.yank()
	local pos = vim.fn.getpos("'[")
	local pos2 = vim.fn.getpos("']")
	require("undo-glow").highlight_region({
		hlgroup = "UgYank",
		s_row = pos[2] - 1,
		s_col = pos[3] - 1,
		e_row = pos2[2] - 1,
		e_col = pos2[3],
	})
end

function M.paste_below()
	require("undo-glow").highlight_changes({
		hlgroup = "UgPaste",
	})
	vim.cmd("normal! p")
end

function M.paste_above()
	require("undo-glow").highlight_changes({
		hlgroup = "UgPaste",
	})
	vim.cmd("normal! P")
end

function M.search_next()
	vim.cmd("normal! n")
	local region = require("undo-glow.utils").get_search_region()

	if not region then
		return
	end

	require("undo-glow").highlight_region({
		hlgroup = "UgSearch",
		s_row = region.s_row,
		s_col = region.s_col,
		e_row = region.e_row,
		e_col = region.e_col,
	})
end

function M.search_prev()
	vim.cmd("normal! N")
	local region = require("undo-glow.utils").get_search_region()

	if not region then
		return
	end

	require("undo-glow").highlight_region({
		hlgroup = "UgSearch",
		s_row = region.s_row,
		s_col = region.s_col,
		e_row = region.e_row,
		e_col = region.e_col,
	})
end

function M.search_star()
	vim.cmd("normal! *")
	local region = require("undo-glow.utils").get_search_star_region()

	if not region then
		return
	end

	require("undo-glow").highlight_region({
		hlgroup = "UgSearch",
		s_row = region.s_row,
		s_col = region.s_col,
		e_row = region.e_row,
		e_col = region.e_col,
	})
end

function M.comment()
	require("undo-glow").highlight_changes({
		hlgroup = "UgComment",
	})
	return require("vim._comment").operator()
end

function M.comment_textobject()
	require("undo-glow").highlight_changes({
		hlgroup = "UgComment",
	})
	return require("vim._comment").textobject()
end

function M.comment_line()
	require("undo-glow").highlight_changes({
		hlgroup = "UgComment",
	})
	return require("vim._comment").operator() .. "_"
end

return M
