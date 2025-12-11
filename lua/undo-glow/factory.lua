---@mod undo-glow.factory Factory patterns for creating animations and highlights
---@brief [[
---
---Factory patterns for creating animations and highlights with better extensibility.
---
---@brief ]]

local M = {}

---Animation factory for creating animation instances
---@class AnimationFactory
local AnimationFactory = {}
AnimationFactory.__index = AnimationFactory

---Create a new animation factory
---@return AnimationFactory
function AnimationFactory:new()
	local instance = setmetatable({}, self)
	instance._animations = {}
	return instance
end

---Register an animation type
---@param name string The animation name
---@param animation_fn function The animation function
function AnimationFactory:register(name, animation_fn)
	self._animations[name] = animation_fn
end

---Create an animation instance
---@param name string|function The animation name or function
---@param opts table The animation options (unused for now, kept for API consistency)
---@return function|nil animation_fn The animation function or nil if not found
function AnimationFactory:create(name, opts)
	-- If name is already a function, return it directly
	if type(name) == "function" then
		return name
	end

	-- If name is a string, look it up in the registry
	if type(name) == "string" then
		local animation_fn = self._animations[name]
		if not animation_fn then
			require("undo-glow.log").warn("Unknown animation type: " .. name)
			return nil
		end
		return animation_fn
	end

	-- Invalid type
	require("undo-glow.log").warn("Invalid animation type: " .. type(name))
	return nil
end

---Get all registered animation names
---@return table animation_names List of registered animation names
function AnimationFactory:get_registered()
	local names = {}
	for name in pairs(self._animations) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

---Highlight factory for creating highlight instances
---@class HighlightFactory
local HighlightFactory = {}
HighlightFactory.__index = HighlightFactory

---Create a new highlight factory
---@return HighlightFactory
function HighlightFactory:new()
	local instance = setmetatable({}, self)
	instance._highlights = {}
	return instance
end

---Register a highlight type
---@param name string The highlight name
---@param highlight_fn function The highlight creation function
function HighlightFactory:register(name, highlight_fn)
	self._highlights[name] = highlight_fn
end

---Create a highlight instance
---@param name string The highlight name
---@param opts table The highlight options
---@return table|nil highlight_config The highlight configuration or nil if not found
function HighlightFactory:create(name, opts)
	local highlight_fn = self._highlights[name]
	if not highlight_fn then
		require("undo-glow.log").warn("Unknown highlight type: " .. name)
		return nil
	end

	return highlight_fn(opts)
end

---Get all registered highlight names
---@return table highlight_names List of registered highlight names
function HighlightFactory:get_registered()
	local names = {}
	for name in pairs(self._highlights) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

-- Global instances
M.animation_factory = AnimationFactory:new()
M.highlight_factory = HighlightFactory:new()

-- Register built-in animations
local animation = require("undo-glow.animation")
M.animation_factory:register("fade", animation.animate.fade)
M.animation_factory:register("fade_reverse", animation.animate.fade_reverse)
M.animation_factory:register("blink", animation.animate.blink)
M.animation_factory:register("pulse", animation.animate.pulse)
M.animation_factory:register("jitter", animation.animate.jitter)
M.animation_factory:register("spring", animation.animate.spring)
M.animation_factory:register("desaturate", animation.animate.desaturate)
M.animation_factory:register("strobe", animation.animate.strobe)
M.animation_factory:register("zoom", animation.animate.zoom)
M.animation_factory:register("rainbow", animation.animate.rainbow)
M.animation_factory:register("slide", animation.animate.slide)

-- Register built-in highlights
local highlight = require("undo-glow.highlight")
M.highlight_factory:register("basic", function(opts)
	return {
		hl = opts.hl or "UgHighlight",
		hl_color = opts.hl_color or { bg = "#FF5555" }
	}
end)

return M