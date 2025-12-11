---@mod undo-glow.commands Neovim commands
---@brief [[
---
---Neovim command definitions for undo-glow functionality.
---
---This module contains all the user-facing commands that trigger highlighting
---and animations for various operations like undo, redo, yank, paste, search, etc.
---
---Each command function:
---• Accepts optional configuration overrides
---• Merges with global configuration
---• Sets operation tracking for hooks
---• Calls the appropriate highlighting function
---
---@brief ]]

local M = {}

---Undo command that highlights the changed region.
---@param opts? UndoGlow.CommandOpts Optional command configuration to override defaults
---@return nil
---@usage [[
---require("undo-glow").undo()
---require("undo-glow").undo({ animation = { duration = 1000 } })
---@usage ]]
function M.undo(opts)
	local api = require("undo-glow.api")
	api.emit("command_executed", { command = "undo", opts = opts })

	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgUndo", opts)
	opts._operation = "undo"

	-- Always trigger hooks by calling highlight_region_enhanced
	-- This ensures all hooks fire even if there are no text changes to highlight
	require("undo-glow.api").highlight_region_enhanced(
		vim.tbl_extend("force", opts, {
			s_row = 0,
			s_col = 0,
			e_row = 0,
			e_col = 1,
			_operation = "undo",
		})
	)

	require("undo-glow").highlight_changes(opts)
	local success, err = pcall(vim.cmd, "undo")

	if not success then
		api.call_hook(
			"on_error",
			{ operation = "undo_command", error = err, opts = opts }
		)
	end
end

---Redo command that highlights the changed region.
---@param opts? UndoGlow.CommandOpts Optional command configuration to override defaults
---@return nil
---@usage [[
---require("undo-glow").redo()
---require("undo-glow").redo({ animation = { animation_type = "pulse" } })
---@usage ]]
function M.redo(opts)
	local api = require("undo-glow.api")
	api.emit("command_executed", { command = "redo", opts = opts })

	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgRedo", opts)
	opts._operation = "redo"

	-- Always trigger hooks by calling highlight_region_enhanced
	-- This ensures all hooks fire even if there are no text changes to highlight
	require("undo-glow.api").highlight_region_enhanced(
		vim.tbl_extend("force", opts, {
			s_row = 0,
			s_col = 0,
			e_row = 0,
			e_col = 1,
			_operation = "redo",
		})
	)

	require("undo-glow").highlight_changes(opts)
	local success, err = pcall(vim.cmd, "redo")

	if not success then
		api.call_hook(
			"on_error",
			{ operation = "redo_command", error = err, opts = opts }
		)
	end
end

---Yank command that highlights.
---For autocmd usage only.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.yank(opts)
	local api = require("undo-glow.api")
	api.emit("command_executed", { command = "yank", opts = opts })

	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgYank", opts)
	opts._operation = "yank"

	-- Always trigger hooks by calling highlight_region directly
	require("undo-glow.api").highlight_region_enhanced(
		vim.tbl_extend("force", opts, {
			s_row = 0,
			s_col = 0,
			e_row = 0,
			e_col = 1,
			_operation = "yank",
		})
	)

	local pos = vim.fn.getpos("'[")
	local pos2 = vim.fn.getpos("']")

	local success, err = pcall(
		require("undo-glow.api").highlight_region_enhanced,
		vim.tbl_extend("force", opts, {
			s_row = pos[2] - 1,
			s_col = pos[3] - 1,
			e_row = pos2[2] - 1,
			e_col = pos2[3],
		})
	)

	if not success then
		api.call_hook(
			"on_error",
			{ operation = "yank_command", error = err, opts = opts }
		)
	end
end

---Paste below command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.paste_below(opts)
	local api = require("undo-glow.api")
	api.emit("command_executed", { command = "paste_below", opts = opts })

	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgPaste", opts)
	opts._operation = "paste_below"

	-- Always trigger hooks by calling highlight_region directly
	require("undo-glow.api").highlight_region_enhanced(
		vim.tbl_extend("force", opts, {
			s_row = 0,
			s_col = 0,
			e_row = 0,
			e_col = 1,
			_operation = "paste_below",
		})
	)

	require("undo-glow").highlight_changes(opts)

	local register = vim.v.register
	local count = vim.v.count > 0 and vim.v.count or 1

	local success, err =
		pcall(vim.cmd, string.format('normal! %d"%sp', count, register))
	if not success then
		api.call_hook(
			"on_error",
			{ operation = "paste_below_command", error = err, opts = opts }
		)
	end
end

---Paste above command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.paste_above(opts)
	local api = require("undo-glow.api")
	api.emit("command_executed", { command = "paste_above", opts = opts })

	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgPaste", opts)
	opts._operation = "paste_above"

	-- Always trigger hooks by calling highlight_region directly
	require("undo-glow.api").highlight_region_enhanced(
		vim.tbl_extend("force", opts, {
			s_row = 0,
			s_col = 0,
			e_row = 0,
			e_col = 1,
			_operation = "paste_above",
		})
	)

	require("undo-glow").highlight_changes(opts)

	local register = vim.v.register
	local count = vim.v.count > 0 and vim.v.count or 1

	local success, err =
		pcall(vim.cmd, string.format('normal! %d"%sP', count, register))
	if not success then
		api.call_hook(
			"on_error",
			{ operation = "paste_above_command", error = err, opts = opts }
		)
	end
end

---Highlight current line after a search is performed.
---For autocmd usage only.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.search_cmd(opts)
	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgSearch", opts)
	opts._operation = "search_cmd"

	local region = require("undo-glow.utils").get_current_cursor_row()

	require("undo-glow.api").highlight_region_enhanced(
		vim.tbl_extend("force", opts, {
			s_row = region.s_row,
			s_col = region.s_col,
			e_row = region.e_row,
			e_col = region.e_col,
			force_edge = type(opts.force_edge) == "nil" and true
				or opts.force_edge,
		})
	)
end

---Search next command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command configuration to override defaults
---@return nil
---@usage [[
---require("undo-glow").search_next()
---require("undo-glow").search_next({ animation = { animation_type = "strobe" } })
---@usage ]]
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
	opts._operation = "search_next"

	require("undo-glow.api").highlight_region_enhanced(
		vim.tbl_extend("force", opts, {
			s_row = region.s_row,
			s_col = region.s_col,
			e_row = region.e_row,
			e_col = region.e_col,
		})
	)
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
	opts._operation = "search_prev"

	require("undo-glow.api").highlight_region_enhanced(
		vim.tbl_extend("force", opts, {
			s_row = region.s_row,
			s_col = region.s_col,
			e_row = region.e_row,
			e_col = region.e_col,
		})
	)
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
	local region = require("undo-glow.utils").get_current_search_match_region()

	if not region then
		return
	end

	opts = require("undo-glow.utils").merge_command_opts("UgSearch", opts)
	opts._operation = "search_star"

	require("undo-glow.api").highlight_region_enhanced(
		vim.tbl_extend("force", opts, {
			s_row = region.s_row,
			s_col = region.s_col,
			e_row = region.e_row,
			e_col = region.e_col,
		})
	)
end

---Search star (#) command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.search_hash(opts)
	vim.g.ug_ignore_cursor_moved = true

	local ok = pcall(vim.cmd, "normal! #")

	if not ok then
		return
	end
	local region = require("undo-glow.utils").get_current_search_match_region()

	if not region then
		return
	end

	opts = require("undo-glow.utils").merge_command_opts("UgSearch", opts)
	opts._operation = "search_hash"

	require("undo-glow.api").highlight_region_enhanced(
		vim.tbl_extend("force", opts, {
			s_row = region.s_row,
			s_col = region.s_col,
			e_row = region.e_row,
			e_col = region.e_col,
		})
	)
end

---Comment with `gc` in `n` and `x` mode with highlights.
---Requires `expr` = true in ``vim.keymap.set`
---@param opts? UndoGlow.CommandOpts Optional command option
---@return string|nil expression String for expression and nil for non-expression
function M.comment(opts)
	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgComment", opts)
	opts._operation = "comment"
	require("undo-glow").highlight_changes(opts)
	return require("vim._comment").operator()
end

---Comment with `gc` in `o` mode. E.g. gcip, gcap, etc with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.comment_textobject(opts)
	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgComment", opts)
	opts._operation = "comment_textobject"
	require("undo-glow").highlight_changes(opts)
	return require("vim._comment").textobject()
end

---Comment lines with `gcc` with highlights.
---Requires `expr` = true in ``vim.keymap.set`
---@param opts? UndoGlow.CommandOpts Optional command option
---@return string expression String for expression
function M.comment_line(opts)
	opts = require("undo-glow.utils").merge_command_opts("UgComment", opts)
	opts._operation = "comment_line"
	require("undo-glow").highlight_changes(opts)
	return require("vim._comment").operator() .. "_"
end

---Cursor movement highlighting command (autocmd usage).
---@param opts? UndoGlow.CommandOpts Optional command configuration to override defaults
---@param cursor_moved_opts? UndoGlow.CursorMovedOpts Optional cursor movement options:
---  • ignored_ft (table) - Filetypes to ignore
---  • steps_to_trigger (number) - Lines to move before triggering (default: 10)
---  • trigger_on_new_buffer (boolean) - Trigger on buffer change
---  • trigger_on_new_window (boolean) - Trigger on window change
---@return nil
---@usage [[
---vim.api.nvim_create_autocmd("CursorMoved", {
---  callback = function() require("undo-glow").cursor_moved() end
---})
---@usage ]]
function M.cursor_moved(opts, cursor_moved_opts)
	if vim.api.nvim_get_mode().mode ~= "n" then
		return
	end

	opts = require("undo-glow.utils").merge_command_opts("UgCursor", opts)
	opts._operation = "cursor_moved"

	cursor_moved_opts = vim.tbl_deep_extend("force", {
		ignored_ft = {},
		steps_to_trigger = 10,
		trigger_on_new_buffer = true,
		trigger_on_new_window = true,
	}, cursor_moved_opts or {})

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

	local is_ignored_ft =
		vim.tbl_contains(cursor_moved_opts.ignored_ft, vim.bo.filetype)

	if
		is_preview_window
		or is_floating_window
		or is_not_text_buffer
		or is_ignored_ft
	then
		return
	end

	local pos = require("undo-glow.utils").get_current_cursor_row()

	local prev_buf = vim.g.ug_prev_buf
	local prev_row = vim.g.ug_prev_cursor or pos.s_row
	local prev_win = vim.g.ug_prev_win

	local diff = math.abs(pos.s_row - prev_row)
	local new_buffer = (prev_buf ~= current_buf)
	local new_window = (prev_win ~= current_win)

	if not vim.g.ug_ignore_cursor_moved then
		if
			diff > cursor_moved_opts.steps_to_trigger
			or (cursor_moved_opts.trigger_on_new_buffer and new_buffer)
			or (cursor_moved_opts.trigger_on_new_window and new_window)
		then
			require("undo-glow.api").highlight_region_enhanced(
				vim.tbl_extend("force", opts, {
					s_row = pos.s_row,
					s_col = pos.s_col,
					e_row = pos.e_row,
					e_col = pos.e_col,
					force_edge = type(opts.force_edge) == "nil" and true
						or opts.force_edge,
				})
			)
		end
	end

	vim.g.ug_prev_cursor = pos.s_row
	vim.g.ug_prev_buf = current_buf
	vim.g.ug_prev_win = current_win

	if vim.g.ug_ignore_cursor_moved == true then
		vim.g.ug_ignore_cursor_moved = nil
	end
end

return M
