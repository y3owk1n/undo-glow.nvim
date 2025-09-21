local M = {}

M.yanky = {}

---Yanky.nvim put command that highlights.
---@param yanky_action string The yanky action to perform.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return string|nil The plug command.
function M.yanky.put(yanky_action, opts)
	if type(yanky_action) ~= "string" then
		vim.notify(
			"[UndoGlow] Yanky action must be a string, e.g. (YankyPutAfter)",
			vim.log.levels.ERROR
		)
		return
	end

	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgPaste", opts)
	require("undo-glow").highlight_changes(opts)
	local action_plug = string.format("<Plug>(%s)", yanky_action)

	return action_plug
end

M.substitute = {}

---Substitute.nvim action command that highlights.
---@param action fun() The action to perform.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.substitute.action(action, opts)
	if type(action) ~= "function" then
		vim.notify(
			"[UndoGlow] Substitute.nvim action must be a function, learn more from the plugin's README",
			vim.log.levels.ERROR
		)
		return
	end

	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgPaste", opts)
	require("undo-glow").highlight_changes(opts)

	action()
end

M.flash = {}

---Flash.nvim jump command that highlights.
---@param flash_opts? table The flash jump options.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.flash.jump(flash_opts, opts)
	local flash_ok, flash = pcall(require, "flash")
	if not flash_ok then
		vim.notify(
			"[UndoGlow] Flash.nvim is not installed",
			vim.log.levels.ERROR
		)
		return
	end

	flash_opts = flash_opts or {}

	if type(flash_opts) ~= "table" then
		vim.notify(
			"[UndoGlow] Flash action must be a table, learn more from the plugin's README",
			vim.log.levels.ERROR
		)
		return
	end

	vim.g.ug_ignore_cursor_moved = true

	flash.jump(flash_opts)

	vim.defer_fn(function()
		local region = require("undo-glow.utils").get_current_cursor_row()

		local undo_glow_opts =
			require("undo-glow.utils").merge_command_opts("UgSearch", opts)

		require("undo-glow").highlight_region(
			vim.tbl_extend("force", undo_glow_opts, region)
		)
	end, 5)
end

return M
