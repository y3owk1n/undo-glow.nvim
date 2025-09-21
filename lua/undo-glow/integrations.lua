local M = {}

M.yanky = {}

---Yanky.nvim put command that highlights.
---@param yanky_action string The yanky action to perform.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
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

return M
