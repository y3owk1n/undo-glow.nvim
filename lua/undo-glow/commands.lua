local M = {}

---@param opts? UndoGlow.CommandOpts
function M.undo(opts)
	opts = opts or {}
	require("undo-glow").highlight_changes({
		hlgroup = opts.hlgroup or "UgUndo",
		animation_type = opts.animation_type,
	})
	vim.cmd("undo")
end

---@param opts? UndoGlow.CommandOpts
function M.redo(opts)
	opts = opts or {}
	require("undo-glow").highlight_changes({
		hlgroup = opts.hlgroup or "UgRedo",
		animation_type = opts.animation_type,
	})
	vim.cmd("redo")
end

--- Helper to use this in autocmds. Do not use this as a command, it does nothing.
---@param opts? UndoGlow.CommandOpts
function M.yank(opts)
	opts = opts or {}
	local pos = vim.fn.getpos("'[")
	local pos2 = vim.fn.getpos("']")
	require("undo-glow").highlight_region({
		hlgroup = opts.hlgroup or "UgYank",
		animation_type = opts.animation_type,
		s_row = pos[2] - 1,
		s_col = pos[3] - 1,
		e_row = pos2[2] - 1,
		e_col = pos2[3],
	})
end

---@param opts? UndoGlow.CommandOpts
function M.paste_below(opts)
	opts = opts or {}
	require("undo-glow").highlight_changes({
		hlgroup = opts.hlgroup or "UgPaste",
		animation_type = opts.animation_type,
	})
	vim.cmd("normal! p")
end

---@param opts? UndoGlow.CommandOpts
function M.paste_above(opts)
	opts = opts or {}
	require("undo-glow").highlight_changes({
		hlgroup = opts.hlgroup or "UgPaste",
		animation_type = opts.animation_type,
	})
	vim.cmd("normal! P")
end

---@param opts? UndoGlow.CommandOpts
function M.search_next(opts)
	vim.cmd("normal! n")
	local region = require("undo-glow.utils").get_search_region()

	if not region then
		return
	end

	opts = opts or {}

	require("undo-glow").highlight_region({
		hlgroup = opts.hlgroup or "UgSearch",
		animation_type = opts.animation_type,
		s_row = region.s_row,
		s_col = region.s_col,
		e_row = region.e_row,
		e_col = region.e_col,
	})
end

---@param opts? UndoGlow.CommandOpts
function M.search_prev(opts)
	vim.cmd("normal! N")
	local region = require("undo-glow.utils").get_search_region()

	if not region then
		return
	end

	opts = opts or {}

	require("undo-glow").highlight_region({
		hlgroup = opts.hlgroup or "UgSearch",
		animation_type = opts.animation_type,
		s_row = region.s_row,
		s_col = region.s_col,
		e_row = region.e_row,
		e_col = region.e_col,
	})
end

---@param opts? UndoGlow.CommandOpts
function M.search_star(opts)
	vim.cmd("normal! *")
	local region = require("undo-glow.utils").get_search_star_region()

	if not region then
		return
	end

	opts = opts or {}

	require("undo-glow").highlight_region({
		hlgroup = opts.hlgroup or "UgSearch",
		animation_type = opts.animation_type,
		s_row = region.s_row,
		s_col = region.s_col,
		e_row = region.e_row,
		e_col = region.e_col,
	})
end

---@param opts? UndoGlow.CommandOpts
function M.comment(opts)
	opts = opts or {}
	require("undo-glow").highlight_changes({
		hlgroup = opts.hlgroup or "UgComment",
		animation_type = opts.animation_type,
	})
	return require("vim._comment").operator()
end

---@param opts? UndoGlow.CommandOpts
function M.comment_textobject(opts)
	opts = opts or {}
	require("undo-glow").highlight_changes({
		hlgroup = opts.hlgroup or "UgComment",
		animation_type = opts.animation_type,
	})
	return require("vim._comment").textobject()
end

---@param opts? UndoGlow.CommandOpts
function M.comment_line(opts)
	opts = opts or {}
	require("undo-glow").highlight_changes({
		hlgroup = opts.hlgroup or "UgComment",
		animation_type = opts.animation_type,
	})
	return require("vim._comment").operator() .. "_"
end

return M
