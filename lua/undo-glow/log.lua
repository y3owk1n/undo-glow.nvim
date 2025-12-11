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

---Check if we're in test mode (checked at runtime to handle load order issues)
local function is_test_mode()
	return vim.env.NVIM_TESTING or vim.g.undo_glow_testing or false
end

---Log output destinations
local outputs = {
	notify = true, -- Neovim notifications (default)
	file = false, -- File logging (optional)
}

---Log file path (when file logging is enabled)
local log_file_path = nil

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

---Enable or disable log outputs
---@param notify? boolean Enable Neovim notifications
---@param file? boolean Enable file logging
---@param file_path? string Path to log file (required if file=true)
function M.set_outputs(notify, file, file_path)
	outputs.notify = notify ~= false
	outputs.file = file == true

	if outputs.file then
		if not file_path then
			-- Default log file location
			local cache_dir = vim.fn.stdpath("cache")
			log_file_path = vim.fs.joinpath(cache_dir, "undo-glow.log")
		else
			log_file_path = file_path
		end

		-- Ensure log directory exists
		local log_dir = vim.fs.dirname(log_file_path)
		if not vim.uv.fs_stat(log_dir) then
			vim.uv.fs_mkdir(log_dir, 493) -- 0755 permissions
		end
	end
end

---Write a message to the log file
---@param message string The formatted log message
local function write_to_file(message)
	if not outputs.file or not log_file_path then
		return
	end

	local file = io.open(log_file_path, "a")
	if file then
		file:write(message .. "\n")
		file:close()
	end
end

---Get the current log file path
---@return string|nil
function M.get_log_file()
	return log_file_path
end

---Format a log message with consistent structure
---@param level_name string The level name (ERROR, WARN, etc.)
---@param message string The log message
---@param context? table Optional context information
---@return string formatted_message The formatted log message
local function format_message(level_name, message, context)
	local timestamp = os.date("%H:%M:%S")
	local full_message = string.format(
		"[%s] %s %s: %s",
		timestamp,
		PLUGIN_PREFIX,
		level_name,
		message
	)

	if context then
		full_message = full_message .. "\nContext: " .. vim.inspect(context)
	end

	return full_message
end

---Check if a log level should be displayed
---@param level integer The level to check
---@return boolean
local function should_log(level)
	-- In test mode, only show ERROR level messages
	if is_test_mode() then
		return level >= M.levels.ERROR
	end
	return level >= current_level
end

---Log an error message with structured formatting
---@param message string The error message
---@param context? table Optional context information
function M.error(message, context)
	if not should_log(M.levels.ERROR) then
		return
	end
	local formatted = format_message("ERROR", message, context)

	-- Emit log event
	local api = require("undo-glow.api")
	api.emit("log_message", {
		level = "ERROR",
		message = message,
		context = context,
		formatted = formatted,
	})

	if outputs.notify then
		vim.notify(formatted, vim.log.levels.ERROR)
	end
	if outputs.file then
		write_to_file(formatted)
	end
end

---Log a warning message with structured formatting
---@param message string The warning message
---@param context? table Optional context information
function M.warn(message, context)
	if not should_log(M.levels.WARN) then
		return
	end
	local formatted = format_message("WARN", message, context)

	-- Emit log event
	local api = require("undo-glow.api")
	api.emit("log_message", {
		level = "WARN",
		message = message,
		context = context,
		formatted = formatted,
	})

	if outputs.notify then
		vim.notify(formatted, vim.log.levels.WARN)
	end
	if outputs.file then
		write_to_file(formatted)
	end
end

---Log an info message with structured formatting
---@param message string The info message
---@param context? table Optional context information
function M.info(message, context)
	if not should_log(M.levels.INFO) then
		return
	end
	local formatted = format_message("INFO", message, context)

	if outputs.notify then
		vim.notify(formatted, vim.log.levels.INFO)
	end
	if outputs.file then
		write_to_file(formatted)
	end
end

---Log a debug message with structured formatting
---@param message string The debug message
---@param context? table Optional context information
function M.debug(message, context)
	if not should_log(M.levels.DEBUG) then
		return
	end
	local formatted = format_message("DEBUG", message, context)

	if outputs.notify then
		vim.notify(formatted, vim.log.levels.DEBUG)
	end
	if outputs.file then
		write_to_file(formatted)
	end
end

---Log a trace message with structured formatting (most verbose)
---@param message string The trace message
---@param context? table Optional context information
function M.trace(message, context)
	if not should_log(M.levels.TRACE) then
		return
	end
	local formatted = format_message("TRACE", message, context)

	if outputs.notify then
		vim.notify(formatted, vim.log.levels.DEBUG) -- Use DEBUG level for trace
	end
	if outputs.file then
		write_to_file(formatted)
	end
end

return M
