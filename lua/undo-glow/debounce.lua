---@mod undo-glow.debounce Debouncing utilities for performance optimization
---@brief [[
---
---Debouncing utilities to prevent excessive operations during rapid events.
---
---@brief ]]

local M = {}

-- Store active timers
local timers = {}

-- Default debounce delay (configurable)
local DEFAULT_DEBOUNCE_DELAY = 50

---Set the default debounce delay
---@param delay number The delay in milliseconds
function M.set_default_delay(delay)
	DEFAULT_DEBOUNCE_DELAY = delay
end

---Debounces a function call, ensuring it's only executed after a delay
---without being called again during that delay period.
---@param fn function The function to debounce
---@param delay? number The delay in milliseconds (uses default if not provided)
---@param key string A unique key to identify this debounced function
---@return function debounced_fn The debounced function
function M.debounce(fn, delay, key)
	delay = delay or DEFAULT_DEBOUNCE_DELAY
	return function(...)
		local args = { ... }

		-- Cancel existing timer for this key
		if timers[key] then
			timers[key]:stop()
			timers[key]:close()
			timers[key] = nil
		end

		-- Create new timer
		local timer = vim.uv.new_timer()
		if timer then
			timer:start(
				delay,
				0,
				vim.schedule_wrap(function()
					-- Execute the function
					fn(unpack(args))

					-- Clean up timer
					if timers[key] then
						timers[key]:stop()
						timers[key]:close()
						timers[key] = nil
					end
				end)
			)

			timers[key] = timer
		else
			-- Fallback: execute immediately if timer creation fails
			fn(unpack(args))
		end
	end
end

---Throttles a function call, ensuring it's executed at most once per interval.
---@param fn function The function to throttle
---@param interval number The minimum interval in milliseconds
---@param key string A unique key to identify this throttled function
---@return function throttled_fn The throttled function
function M.throttle(fn, interval, key)
	local last_call = 0

	return function(...)
		local args = { ... }
		local now = vim.uv.hrtime() / 1000000 -- Convert to milliseconds

		if now - last_call >= interval then
			last_call = now
			fn(unpack(args))
		end
	end
end

---Cancels a debounced or throttled function by key
---@param key string The key used when creating the debounced/throttled function
function M.cancel(key)
	if timers[key] then
		timers[key]:stop()
		timers[key]:close()
		timers[key] = nil
	end
end

---Cancels all active debounced/throttled functions
function M.cancel_all()
	for key, timer in pairs(timers) do
		if timer then
			timer:stop()
			timer:close()
		end
	end
	timers = {}
end

return M
