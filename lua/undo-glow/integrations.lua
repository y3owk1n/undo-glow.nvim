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

return M
