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
		hlgroup = "UgPasteBelow",
	})
	vim.cmd("normal! p")
end

function M.paste_above()
	require("undo-glow").highlight_changes({
		hlgroup = "UgPasteAbove",
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
		hlgroup = "UgSearchNext",
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
		hlgroup = "UgSearchPrev",
		s_row = region.s_row,
		s_col = region.s_col,
		e_row = region.e_row,
		e_col = region.e_col,
	})
end

return M
