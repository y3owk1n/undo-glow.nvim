---@mod undo-glow.api Enhanced API with hooks and builders
---@brief [[
---
---Enhanced API system with hooks, builders, and extension points for undo-glow.nvim.
---
---This module provides the programmatic interface for extending and customizing
---undo-glow behavior through hooks, event subscriptions, and runtime configuration.
---
---Key features:
---• Hook system for operation customization (pre/post highlight, animation)
---• Event system for monitoring plugin activity
---• Configuration builder for runtime settings changes
---• Factory registration for custom animations and highlights
---• Status introspection for debugging and monitoring
---
---@brief ]]

local M = {}

---Hooks registry for extension points
local hooks = {
	pre_highlight = {}, -- Called before highlighting
	post_highlight = {}, -- Called after highlighting
	pre_animation = {}, -- Called before animation starts
	post_animation = {}, -- Called after animation completes
	on_error = {}, -- Called when errors occur
	on_config_change = {}, -- Called when configuration changes
}

---Event system for notifications
local events = {}

---Configuration builder for fluent API pattern
---@class ConfigBuilder
---@field _config table Internal configuration storage
local ConfigBuilder = {}
ConfigBuilder.__index = ConfigBuilder

---Create a new configuration builder instance
---@return ConfigBuilder
---@usage [[
---local api = require("undo-glow.api")
---local config = api.config_builder()
---    :animation({ enabled = true, duration = 500 })
---    :performance({ debounce_delay = 100 })
---    :build()
---@usage ]]
function ConfigBuilder:new()
	local instance = setmetatable({}, self)
	instance._config = {
		animation = {},
		highlights = {},
		performance = {},
		logging = {},
	}
	return instance
end

---Set animation configuration for runtime changes
---@param config table Animation configuration table:
---  • enabled (boolean) - Enable/disable animations
---  • duration (number) - Animation duration in milliseconds
---  • fps (number) - Frames per second (max 240)
---  • animation_type (UndoGlow.AnimationTypeString) - Animation type ("fade", "blink", "bounce", etc.)
---  • easing (UndoGlow.EasingString) - Easing function ("linear", "in_out_cubic", etc.)
---  • window_scoped (boolean) - Restrict to current window
---@return ConfigBuilder
---@usage `config_builder:animation({ enabled = true, duration = 500 })`
function ConfigBuilder:animation(config)
	self._config.animation =
		vim.tbl_extend("force", self._config.animation, config)
	return self
end

---Set highlight configuration for a specific action
---@param name string Highlight name: "undo" | "redo" | "yank" | "paste" | "search" | "comment" | "cursor"
---@param config table Highlight configuration:
---  • hl (string) - Highlight group name (optional, defaults to "Ug" + Name)
---  • hl_color (UndoGlow.HlColor) - Color definition with bg and optional fg
---@return ConfigBuilder
---@usage `config_builder:highlight("undo", { hl_color = { bg = "#4A90E2" } })`
function ConfigBuilder:highlight(name, config)
	self._config.highlights[name] = config
	return self
end

---Set performance configuration for optimization
---@param config table Performance tuning options:
---  • color_cache_size (number) - Size of color conversion cache (default: 1000)
---  • debounce_delay (number) - Debounce delay in milliseconds (default: 50)
---@return ConfigBuilder
---@usage `config_builder:performance({ debounce_delay = 100, color_cache_size = 2000 })`
function ConfigBuilder:performance(config)
	self._config.performance =
		vim.tbl_extend("force", self._config.performance, config)
	return self
end

---Set logging configuration
---@param config table Logging options:
---  • level (string) - Log level: "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "OFF"
---  • notify (boolean) - Show logs in Neovim notifications
---  • file (boolean|string) - Write logs to file (true for auto-generated path, string for custom path)
---@return ConfigBuilder
---@usage `config_builder:logging({ level = "DEBUG", notify = true })`
function ConfigBuilder:logging(config)
	self._config.logging = vim.tbl_extend("force", self._config.logging, config)
	return self
end

---Build and apply the final configuration
---@return table Complete configuration object that was applied
---@usage `local applied_config = config_builder:build()`
function ConfigBuilder:build()
	return vim.deepcopy(self._config)
end

---Enhanced highlight function with hooks
---@param opts UndoGlow.HighlightRegion Enhanced highlight options
---@return nil
function M.highlight_region_enhanced(opts)
	-- Pre-highlight hook
	M.call_hook("pre_highlight", opts)

	local success, err = pcall(function()
		require("undo-glow").highlight_region(opts)
	end)

	if not success then
		M.call_hook(
			"on_error",
			{ operation = "highlight_region", error = err, opts = opts }
		)
		require("undo-glow.log").error("Enhanced highlight failed: " .. err)
	else
		-- Post-highlight hook
		M.call_hook("post_highlight", opts)
	end
end

---Enhanced animation function with hooks
---@param opts UndoGlow.Animation Animation options including coordinates, colors, and timing
---@return nil
function M.animate_enhanced(opts)
	-- Pre-animation hook
	M.call_hook("pre_animation", opts)

	local success, err = pcall(function()
		require("undo-glow.animation").animate_start(opts)
	end)

	if not success then
		M.call_hook(
			"on_error",
			{ operation = "animate", error = err, opts = opts }
		)
		require("undo-glow.log").error("Enhanced animation failed: " .. err)
	else
		-- Post-animation hook (called after animation completes)
		vim.defer_fn(function()
			M.call_hook("post_animation", opts)
		end, opts.duration or 100)
	end
end

---Register a hook for an event
---@param event string Event name ("pre_highlight", "post_highlight", "pre_animation", "post_animation", "on_error", "on_config_change")
---@param callback function Callback function with signature: function(data) where data contains event-specific information
---@param priority? number Priority (higher numbers run first, default 0)
---@return number hook_id Unique hook ID for removal
function M.register_hook(event, callback, priority)
	if not hooks[event] then
		hooks[event] = {}
	end

	local hook_id = math.random(1000000)
	hooks[event][hook_id] = {
		callback = callback,
		priority = priority or 0,
	}

	return hook_id
end

---Remove a hook
---@param event string Event name
---@param hook_id number Hook ID returned by register_hook
---@return boolean success
function M.remove_hook(event, hook_id)
	if hooks[event] and hooks[event][hook_id] then
		hooks[event][hook_id] = nil
		return true
	end
	return false
end

---Call all hooks for an event (internal use)
---@param event string Event name
---@param ... any Arguments to pass to hooks
---@return nil
---@private
function M.call_hook(event, ...)
	if not hooks[event] then
		return
	end

	-- Sort hooks by priority (higher priority first)
	local sorted_hooks = {}
	for hook_id, hook_data in pairs(hooks[event]) do
		table.insert(sorted_hooks, {
			id = hook_id,
			data = hook_data,
		})
	end
	table.sort(sorted_hooks, function(a, b)
		return (a.data.priority or 0) > (b.data.priority or 0)
	end)

	-- Call hooks in priority order
	for _, hook_info in ipairs(sorted_hooks) do
		local success, err = pcall(hook_info.data.callback, ...)
		if not success then
			require("undo-glow.log").error("Hook failed: " .. err)
		end
	end
end

---Subscribe to events
---@param event string Event name ("command_executed", "integration_used", "buffer_changed", "config_changed", "config_error", "health_check_started", "health_check_completed", "log_message", "debounce_started", "debounce_executed", "color_conversion", "color_cache_hit", "factory_registered", "coordinates_sanitized")
---@param callback function Callback function with signature: function(data) where data contains event-specific information
---@return number subscription_id
function M.subscribe(event, callback)
	if not events[event] then
		events[event] = {}
	end

	local sub_id = math.random(1000000)
	events[event][sub_id] = callback
	return sub_id
end

---Unsubscribe from events
---@param event string Event name
---@param subscription_id number Subscription ID
---@return boolean success
function M.unsubscribe(event, subscription_id)
	if events[event] and events[event][subscription_id] then
		events[event][subscription_id] = nil
		return true
	end
	return false
end

---Emit an event to all subscribers (internal use)
---@param event string Event name
---@param ... any Event data passed to callback functions
---@return nil
---@private
function M.emit(event, ...)
	if events[event] then
		for _, callback in pairs(events[event]) do
			local success, err = pcall(callback, ...)
			if not success then
				require("undo-glow.log").error("Event callback failed: " .. err)
			end
		end
	end
end

---Create a configuration builder for runtime config changes
---Use this for dynamic configuration updates after plugin initialization
---@return ConfigBuilder
function M.config_builder()
	return ConfigBuilder:new()
end

---Register a custom animation function
---@param name string Animation name (used in config.animation_type)
---@param animation_fn function Animation function with signature: function(opts: UndoGlow.Animation)
---@return boolean success
function M.register_animation(name, animation_fn)
	local factory = require("undo-glow.factory")
	return factory.animation_factory:register(name, animation_fn)
end

---Register a custom highlight function
---@param name string Highlight name (used in config.highlights)
---@param highlight_fn function Highlight function with signature: function(opts) -> { hl: string, hl_color: UndoGlow.HlColor }
---@return boolean success
function M.register_highlight(name, highlight_fn)
	local factory = require("undo-glow.factory")
	return factory.highlight_factory:register(name, highlight_fn)
end

---Get comprehensive plugin status and runtime information
---@return table status Table containing: config (current config), registered_animations (list of custom animations), registered_highlights (list of custom highlights), active_hooks (hook counts by event)
function M.status()
	local config = require("undo-glow.config").config
	local factory = require("undo-glow.factory")

	return {
		config = config,
		registered_animations = factory.animation_factory:get_registered(),
		registered_highlights = factory.highlight_factory:get_registered(),
		active_hooks = vim.tbl_map(function(hook_table)
			return vim.tbl_count(hook_table)
		end, hooks),
		active_subscriptions = vim.tbl_map(function(sub_table)
			return vim.tbl_count(sub_table)
		end, events),
	}
end

return M
