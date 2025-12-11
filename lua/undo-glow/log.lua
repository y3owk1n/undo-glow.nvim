---@mod undo-glow.log Logging utilities
---@brief [[
---
---Centralized logging utilities for consistent error messages and logging levels.
---
---@brief ]]

local M = {}

---Plugin name prefix for log messages
local PLUGIN_PREFIX = "[UndoGlow]"

---Log levels
M.levels = {
	ERROR = vim.log.levels.ERROR,
	WARN = vim.log.levels.WARN,
	INFO = vim.log.levels.INFO,
	DEBUG = vim.log.levels.DEBUG,
}

---Log an error message with consistent formatting
---@param message string The error message
---@param context? table Optional context information
function M.error(message, context)
	local full_message = PLUGIN_PREFIX .. " " .. message
	if context then
		full_message = full_message
			.. " (context: "
			.. vim.inspect(context)
			.. ")"
	end
	vim.notify(full_message, M.levels.ERROR)
end

---Log a warning message with consistent formatting
---@param message string The warning message
---@param context? table Optional context information
function M.warn(message, context)
	local full_message = PLUGIN_PREFIX .. " " .. message
	if context then
		full_message = full_message
			.. " (context: "
			.. vim.inspect(context)
			.. ")"
	end
	vim.notify(full_message, M.levels.WARN)
end

---Log an info message with consistent formatting
---@param message string The info message
---@param context? table Optional context information
function M.info(message, context)
	local full_message = PLUGIN_PREFIX .. " " .. message
	if context then
		full_message = full_message
			.. " (context: "
			.. vim.inspect(context)
			.. ")"
	end
	vim.notify(full_message, M.levels.INFO)
end

---Log a debug message with consistent formatting
---@param message string The debug message
---@param context? table Optional context information
function M.debug(message, context)
	local full_message = PLUGIN_PREFIX .. " " .. message
	if context then
		full_message = full_message
			.. " (context: "
			.. vim.inspect(context)
			.. ")"
	end
	vim.notify(full_message, M.levels.DEBUG)
end

return M
