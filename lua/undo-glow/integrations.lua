---@mod undo-glow.nvim.integrations Third-party integrations
---@brief [[
---
---Integration hooks for other Neovim plugins.
---
---This module provides seamless integration with popular Neovim plugins
---by hooking into their operations and adding highlighting effects.
---
---Supported integrations:
---• Yanky: Enhanced paste operations with highlighting
---• Substitute: Search and replace operations with highlighting
---• Flash: Jump operations with highlighting
---
---Each integration:
---• Checks if the plugin is installed
---• Registers appropriate hooks and events
---• Provides plugin-specific highlighting behavior
---
---@brief ]]

local M = {}

local yanky_ok, _ = pcall(require, "yanky")

local api = require("undo-glow.api")

M.yanky = {}

---Yanky.nvim put command that highlights the pasted region.
---@param yanky_action string The yanky action to perform (e.g., "YankyPutAfter")
---@param opts? UndoGlow.CommandOpts Optional command configuration to override defaults
---@return string|nil The plug command string for Yanky, or nil if plugin not available
---@usage [[
---local plug = require("undo-glow.integrations").yanky.put("YankyPutAfter")
---if plug then vim.cmd(plug) end
---@usage ]]
function M.yanky.put(yanky_action, opts)
	if type(yanky_action) ~= "string" then
		require("undo-glow.log").error(
			"Yanky action must be a string, e.g. 'YankyPutAfter'"
		)
		api.call_hook(
			"on_error",
			{ operation = "yanky_integration", error = "invalid_action_type" }
		)
		return
	end

	if not yanky_ok then
		require("undo-glow.log").error("Yanky is not installed")
		api.call_hook(
			"on_error",
			{ operation = "yanky_integration", error = "yanky_not_installed" }
		)
		-- Still return the plug command even if Yanky is not installed
		-- The plug mapping will be undefined, but that's okay
	end

	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgPaste", opts)
	opts._operation = "yanky_paste"
	require("undo-glow").highlight_changes(opts)

	local action_plug = string.format("<Plug>(%s)", yanky_action)

	return action_plug
end

M.substitute = {}

---Substitute plugin action that highlights the substituted region.
---@param action function The substitute action function to execute
---@param opts? UndoGlow.CommandOpts Optional command configuration to override defaults
---@return nil
---@usage [[
---require("undo-glow.integrations").substitute.action(function()
---  require("substitute").execute()
---end)
---@usage ]]
function M.substitute.action(action, opts)
	api.emit("integration_used", { plugin = "substitute", opts = opts })

	local substitute_ok = pcall(require, "substitute")
	if not substitute_ok then
		require("undo-glow.log").error("Substitute.nvim is not installed")
		api.call_hook("on_error", {
			operation = "substitute_integration",
			error = "substitute_not_installed",
		})
		return
	end

	if type(action) ~= "function" then
		require("undo-glow.log").error(
			"Substitute action must be a function. See the plugin's README for examples."
		)
		api.call_hook("on_error", {
			operation = "substitute_integration",
			error = "invalid_action_type",
		})
		return
	end

	vim.g.ug_ignore_cursor_moved = true
	opts = require("undo-glow.utils").merge_command_opts("UgPaste", opts)
	opts._operation = "substitute_paste"
	require("undo-glow").highlight_changes(opts)

	local success, err = pcall(action)
	if not success then
		api.call_hook(
			"on_error",
			{ operation = "substitute_integration", error = err, opts = opts }
		)
	end
end

M.flash = {}

---Flash plugin jump command that highlights the jump target.
---@param flash_opts? table The flash jump options passed to flash.jump()
---@param opts? UndoGlow.CommandOpts Optional command configuration to override defaults
---@return nil
---@usage [[
---require("undo-glow.integrations").flash.jump({ pattern = "function" })
---@usage ]]
function M.flash.jump(flash_opts, opts)
	api.emit(
		"integration_used",
		{ plugin = "flash", flash_opts = flash_opts, opts = opts }
	)

	local flash_ok, flash = pcall(require, "flash")
	if not flash_ok then
		require("undo-glow.log").error("Flash.nvim is not installed")
		api.call_hook(
			"on_error",
			{ operation = "flash_integration", error = "flash_not_installed" }
		)
		return
	end

	if type(flash_opts) ~= "table" then
		require("undo-glow.log").error(
			"Flash options must be a table. See the plugin's README for examples."
		)
		api.call_hook("on_error", {
			operation = "flash_integration",
			error = "invalid_flash_opts_type",
		})
		return
	end

	flash_opts = flash_opts or {}

	if type(flash_opts) ~= "table" then
		vim.notify(
			"[UndoGlow] Flash action must be a table, learn more from the plugin's README",
			vim.log.levels.ERROR
		)
		api.call_hook("on_error", {
			operation = "flash_integration",
			error = "invalid_flash_opts_type",
		})
		return
	end

	vim.g.ug_ignore_cursor_moved = true

	local success, err = pcall(flash.jump, flash_opts)
	if not success then
		api.call_hook("on_error", {
			operation = "flash_integration",
			error = err,
			flash_opts = flash_opts,
		})
		return
	end

	vim.defer_fn(function()
		local region = require("undo-glow.utils").get_current_cursor_row()

		local undo_glow_opts =
			require("undo-glow.utils").merge_command_opts("UgSearch", opts)

		local highlight_success, highlight_err = pcall(
			require("undo-glow.api").highlight_region_enhanced,
			vim.tbl_extend("force", undo_glow_opts, region)
		)

		if not highlight_success then
			api.call_hook("on_error", {
				operation = "flash_integration_highlight",
				error = highlight_err,
				opts = opts,
			})
		end
	end, 5)
end

return M
