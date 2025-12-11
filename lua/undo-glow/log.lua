---@mod undo-glow.log Logging utilities
---@brief [[
---
---Centralized logging utilities for consistent error messages and configurable logging levels.
---
---@brief ]]

local M = {}

---Plugin name prefix for log messages
local PLUGIN_PREFIX = "[UndoGlow]"

---Log levels (ordered by severity, higher number = more severe)
M.levels = {
	TRACE = 0,
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4,
	OFF = 5,
}

---Current minimum log level (configurable)
local current_level = M.levels.INFO

---Set the minimum log level
---@param level integer The minimum log level to display
function M.set_level(level)
	current_level = level
end

---Get the current log level
---@return integer
function M.get_level()
	return current_level
end

---Format a log message with consistent structure
---@param level_name string The level name (ERROR, WARN, etc.)
---@param message string The log message
---@param context? table Optional context information
---@return string formatted_message The formatted log message
local function format_message(level_name, message, context)
	local timestamp = os.date("%H:%M:%S")
	local full_message = string.format("[%s] %s %s: %s",
		timestamp, PLUGIN_PREFIX, level_name, message)

	if context then
		full_message = full_message .. "\nContext: " .. vim.inspect(context)
	end

	return full_message
end

---Check if a log level should be displayed
---@param level integer The level to check
---@return boolean
local function should_log(level)
	return level >= current_level
end

---Log an error message with structured formatting
---@param message string The error message
---@param context? table Optional context information
function M.error(message, context)
	if not should_log(M.levels.ERROR) then return end
	local formatted = format_message("ERROR", message, context)
	vim.notify(formatted, vim.log.levels.ERROR)
end

---Log a warning message with structured formatting
---@param message string The warning message
---@param context? table Optional context information
function M.warn(message, context)
	if not should_log(M.levels.WARN) then return end
	local formatted = format_message("WARN", message, context)
	vim.notify(formatted, vim.log.levels.WARN)
end

---Log an info message with structured formatting
---@param message string The info message
---@param context? table Optional context information
function M.info(message, context)
	if not should_log(M.levels.INFO) then return end
	local formatted = format_message("INFO", message, context)
	vim.notify(formatted, vim.log.levels.INFO)
end

---Log a debug message with structured formatting
---@param message string The debug message
---@param context? table Optional context information
function M.debug(message, context)
	if not should_log(M.levels.DEBUG) then return end
	local formatted = format_message("DEBUG", message, context)
	vim.notify(formatted, vim.log.levels.DEBUG)
end

---Log a trace message with structured formatting (most verbose)
---@param message string The trace message
---@param context? table Optional context information
function M.trace(message, context)
	if not should_log(M.levels.TRACE) then return end
	local formatted = format_message("TRACE", message, context)
	vim.notify(formatted, vim.log.levels.DEBUG) -- Use DEBUG level for trace
end

return M
