local M = {}

function M.undo()
	require("undo-glow").attach_and_run({
		hlgroup = "UgUndo",
		cmd = function()
			vim.cmd("undo")
		end,
	})
end

function M.redo()
	require("undo-glow").attach_and_run({
		hlgroup = "UgRedo",
		cmd = function()
			vim.cmd("redo")
		end,
	})
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
	require("undo-glow").attach_and_run({
		hlgroup = "UgPasteBelow",
		cmd = function()
			vim.cmd("normal! p")
		end,
	})
end

function M.paste_above()
	require("undo-glow").attach_and_run({
		hlgroup = "UgPasteAbove",
		cmd = function()
			vim.cmd("normal! P")
		end,
	})
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
