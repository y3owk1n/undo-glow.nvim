---@mod undo-glow.validate Input validation utilities
---@brief [[
---
---Centralized input validation utilities for consistent parameter checking.
---
---@brief ]]

local M = {}

local log = require("undo-glow.log")

---Validates that a value is a table
---@param value any The value to check
---@param param_name string The parameter name for error messages
---@return boolean
function M.is_table(value, param_name)
	if type(value) ~= "table" then
		log.error(
			string.format("%s must be a table, got %s", param_name, type(value))
		)
		return false
	end
	return true
end

---Validates that a value is a string
---@param value any The value to check
---@param param_name string The parameter name for error messages
---@return boolean
function M.is_string(value, param_name)
	if type(value) ~= "string" then
		log.error(
			string.format(
				"%s must be a string, got %s",
				param_name,
				type(value)
			)
		)
		return false
	end
	return true
end

---Validates that a value is a function
---@param value any The value to check
---@param param_name string The parameter name for error messages
---@return boolean
function M.is_function(value, param_name)
	if type(value) ~= "function" then
		log.error(
			string.format(
				"%s must be a function, got %s",
				param_name,
				type(value)
			)
		)
		return false
	end
	return true
end

---Validates that a value is a number
---@param value any The value to check
---@param param_name string The parameter name for error messages
---@param min? number Optional minimum value
---@param max? number Optional maximum value
---@return boolean
function M.is_number(value, param_name, min, max)
	if type(value) ~= "number" then
		log.error(
			string.format(
				"%s must be a number, got %s",
				param_name,
				type(value)
			)
		)
		return false
	end
	if min and value < min then
		log.error(
			string.format("%s must be >= %d, got %d", param_name, min, value)
		)
		return false
	end
	if max and value > max then
		log.error(
			string.format("%s must be <= %d, got %d", param_name, max, value)
		)
		return false
	end
	return true
end

---Validates that a value is a boolean
---@param value any The value to check
---@param param_name string The parameter name for error messages
---@return boolean
function M.is_boolean(value, param_name)
	if type(value) ~= "boolean" then
		log.error(
			string.format(
				"%s must be a boolean, got %s",
				param_name,
				type(value)
			)
		)
		return false
	end
	return true
end

---Validates animation configuration
---@param animation table The animation config to validate
---@return boolean
function M.validate_animation_config(animation)
	if not M.is_table(animation, "animation") then
		return false
	end

	-- Validate enabled
	if
		animation.enabled ~= nil
		and not M.is_boolean(animation.enabled, "animation.enabled")
	then
		return false
	end

	-- Validate duration
	if
		animation.duration ~= nil
		and not M.is_number(animation.duration, "animation.duration", 0)
	then
		return false
	end

	-- Validate fps
	if
		animation.fps ~= nil
		and not M.is_number(animation.fps, "animation.fps", 1, 240)
	then
		return false
	end

	-- Validate animation_type
	if animation.animation_type ~= nil then
		local valid_types = {
			"fade",
			"fade_reverse",
			"blink",
			"pulse",
			"jitter",
			"spring",
			"desaturate",
			"strobe",
			"zoom",
			"rainbow",
			"slide",
		}
		local is_valid_string = type(animation.animation_type) == "string"
			and vim.tbl_contains(valid_types, animation.animation_type)
		local is_valid_function = type(animation.animation_type) == "function"

		if not (is_valid_string or is_valid_function) then
			log.error(
				"animation.animation_type must be a valid animation name or function"
			)
			return false
		end
	end

	-- Validate window_scoped
	if
		animation.window_scoped ~= nil
		and not M.is_boolean(animation.window_scoped, "animation.window_scoped")
	then
		return false
	end

	return true
end

---Validates highlight configuration
---@param highlights table The highlights config to validate
---@return boolean
function M.validate_highlight_config(highlights)
	if not M.is_table(highlights, "highlights") then
		return false
	end

	local valid_keys =
		{ "undo", "redo", "yank", "paste", "search", "comment", "cursor" }

	for key, config in pairs(highlights) do
		if not vim.tbl_contains(valid_keys, key) then
			log.warn(string.format("Unknown highlight key '%s', ignoring", key))
		elseif type(config) ~= "table" then
			log.error(string.format("highlights.%s must be a table", key))
			return false
		end
	end

	return true
end

---Validates command options
---@param opts table The command options to validate
---@return boolean
function M.validate_command_opts(opts)
	if opts == nil then
		return true -- nil is valid
	end

	if not M.is_table(opts, "opts") then
		return false
	end

	-- Validate hlgroup
	if
		opts.hlgroup ~= nil and not M.is_string(opts.hlgroup, "opts.hlgroup")
	then
		return false
	end

	-- Validate animation
	if
		opts.animation ~= nil
		and not M.validate_animation_config(opts.animation)
	then
		return false
	end

	-- Validate force_edge
	if
		opts.force_edge ~= nil
		and not M.is_boolean(opts.force_edge, "opts.force_edge")
	then
		return false
	end

	return true
end

return M
