---@mod undo-glow.nvim.health Health checks
---@brief [[
---
---Health check utilities for plugin diagnostics.
---
---@brief ]]

local M = {}

---Reports a status message using vim.health.
---Supports boolean values (true for OK, false for error) and string levels ("ok", "warn", "error").
---@param level "ok"|"warn"|"error" The status level.
---@param msg string The message to display.
local function report_status(level, msg)
	local health = vim.health or {}
	if level == "ok" then
		health.ok(msg)
	elseif level == "warn" then
		if health.warn then
			health.warn(msg)
		else
			-- Fallback if vim.health.warn isn't defined
			health.ok("WARN: " .. msg)
		end
	elseif level == "error" then
		health.error(msg)
	else
		error("Invalid level: " .. level)
	end
end

---Prints a separator header for a new section.
---@param title string The section title.
local function separator(title)
	vim.health.start(title)
end

function M.check()
	-- Emit health check start event
	local api = require("undo-glow.api")
	api.emit("health_check_started")

	separator("Neovim Version Check")
	local v = vim.version()
	if v.major > 0 or (v.major == 0 and v.minor >= 10) then
		report_status(
			"ok",
			"Neovim version is " .. v.major .. "." .. v.minor .. "." .. v.patch
		)
	else
		report_status(
			"error",
			"Neovim version is too old: "
				.. v.major
				.. "."
				.. v.minor
				.. "."
				.. v.patch
				.. ". Please upgrade to 0.10 or later."
		)
	end

	separator("Neovim API Checks")
	-- Check for vim.uv API.
	if not vim.uv then
		report_status(
			"error",
			"vim.uv not found. Please upgrade to a newer Neovim version (>=0.7)."
		)
	else
		report_status("ok", "vim.uv is available.")
	end

	-- Check for nvim_set_hl API.
	if not vim.api.nvim_set_hl then
		report_status("error", "nvim_set_hl API is missing.")
	else
		report_status("ok", "nvim_set_hl API is available.")
	end

	-- Check if `scoped` is available for extmark
	local dummy_buf = vim.api.nvim_create_buf(false, true)
	local test_ns = vim.api.nvim_create_namespace("HealthExtmarkTest")
	local ok, err = pcall(function()
		vim.api.nvim_buf_set_extmark(dummy_buf, test_ns, 0, 0, {
			virt_text = { { "test", "None" } },
			scoped = true,
		})
	end)
	if ok then
		report_status(
			"ok",
			"vim.api.nvim_buf_set_extmark supports the 'scoped' option (experimental)."
		)
	else
		report_status(
			"warn",
			"vim.api.nvim_buf_set_extmark does not support the 'scoped' option: "
				.. err
		)
	end
	vim.api.nvim_buf_delete(dummy_buf, { force = true })

	-- New health check for experimental namespace functions.
	local dummy_win = vim.api.nvim_get_current_win()
	local dummy_ns = vim.api.nvim_create_namespace("HealthNamespaceTest")
	local function_string
	local ok_ns, err_ns = pcall(function()
		if vim.fn.has("nvim-0.11") == 1 then
			-- Experimental API for nvim-0.11 and later.
			vim.api.nvim__ns_set(dummy_ns, { wins = { dummy_win } })
			function_string = "'vim.api.nvim__ns_set'"
		else
			-- Fallback for older versions.
			vim.api.nvim__win_add_ns(dummy_win, dummy_ns)
			function_string = "'vim.api.nvim__win_add_ns'"
		end
	end)
	if ok_ns then
		report_status(
			"ok",
			"Experimental namespace API "
				.. function_string
				.. " functions are callable."
		)
	else
		report_status(
			"error",
			"Experimental namespace API "
				.. function_string
				.. " functions are not callable: "
				.. err_ns
		)
	end

	separator("Timer Creation Test")
	-- Test timer creation.
	local timer = vim.uv.new_timer()
	if timer then
		report_status("ok", "Timer creation is working.")
		timer:stop()
		if not vim.uv.is_closing(timer) then
			timer:close()
		end
	else
		report_status("error", "Timer creation failed.")
	end

	separator("Highlight Group Test")
	-- Test setting a highlight group.
	local test_hl = "UgHealthTest"
	local highlight_ok, highlight_err = pcall(function()
		vim.api.nvim_set_hl(0, test_hl, { bg = "#000000", fg = "#FFFFFF" })
	end)
	if highlight_ok then
		report_status("ok", "Able to set highlight group '" .. test_hl .. "'.")
	else
		report_status(
			"error",
			"Failed to set highlight group '"
				.. test_hl
				.. "': "
				.. highlight_err
		)
	end

	-- Clean up the test highlight group.
	vim.cmd("hi clear " .. test_hl)

	separator("TextYankPost Autocmds Check")
	-- Check for interfering TextYankPost autocmds.
	local yank_autocmds = vim.api.nvim_get_autocmds({ event = "TextYankPost" })
	local interfering = {}

	for _, ac in ipairs(yank_autocmds) do
		if ac.callback then
			if type(ac.callback) == "function" then
				local info = debug.getinfo(ac.callback, "S")
				local source = info and info.short_src or ""
				-- Only ignore callbacks coming from undo-glow.
				if not source:find("undo%-glow") then
					table.insert(interfering, ac)
				end
			else
				-- If ac.callback isn't a function, add it to interfering list.
				table.insert(interfering, ac)
			end
		else
			-- No callback provided—consider it interfering.
			table.insert(interfering, ac)
		end
	end

	if #interfering > 0 then
		report_status(
			"warn",
			"Found "
				.. #interfering
				.. " interfering TextYankPost autocmd(s) (excluding those that use undo-glow)."
		)
	else
		report_status(
			"ok",
			"No interfering TextYankPost autocmd found (excluding those that use undo-glow)."
		)
	end

	separator("Plugin Integration Checks")

	-- Check yanky integration
	local yanky_ok = pcall(require, "yanky")
	if yanky_ok then
		report_status("ok", "yanky.nvim is available for integration.")
	else
		report_status(
			"warn",
			"yanky.nvim is not installed. Yank highlighting will be limited."
		)
	end

	-- Check substitute integration
	local substitute_ok = pcall(require, "substitute")
	if substitute_ok then
		report_status("ok", "substitute.nvim is available for integration.")
	else
		report_status(
			"warn",
			"substitute.nvim is not installed. Substitute highlighting will be limited."
		)
	end

	-- Check flash integration
	local flash_ok = pcall(require, "flash")
	if flash_ok then
		report_status("ok", "flash.nvim is available for integration.")
	else
		report_status(
			"warn",
			"flash.nvim is not installed. Flash highlighting will be limited."
		)
	end

	separator("Config Checks")
	local config = require("undo-glow.config").config

	if config.animation.enabled then
		report_status("ok", "Animation is enabled in the configuration.")
	else
		report_status("warn", "Animation is disabled in the configuration.")
	end

	if config.animation.enabled and config.animation.duration < 50 then
		report_status(
			"warn",
			"Animation duration is very short (< 50ms), might not be visible"
		)
	elseif config.animation.enabled and config.animation.duration > 2000 then
		report_status(
			"warn",
			"Animation duration is very long (> 2000ms), might be distracting"
		)
	else
		report_status("ok", "Animation duration seems reasonable")
	end

	if config.animation.enabled and config.animation.fps < 15 then
		report_status(
			"warn",
			"FPS less than 15 might result in choppy animation"
		)
	elseif config.animation.enabled and config.animation.fps > 120 then
		report_status(
			"warn",
			"FPS greater than 120 might cause performance issues"
		)
	elseif config.animation.enabled then
		report_status("ok", "FPS is reasonably set")
	end

	-- Check animation type validity
	if config.animation.enabled then
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
		local anim_type = config.animation.animation_type
		if
			type(anim_type) == "string"
			and not vim.tbl_contains(valid_types, anim_type)
		then
			report_status(
				"error",
				"Invalid animation_type: '" .. anim_type .. "'"
			)
		elseif type(anim_type) == "function" then
			report_status("ok", "Custom animation function is configured")
		else
			report_status("ok", "Animation type is valid")
		end
	end

	separator("Performance Configuration Checks")

	-- Check performance settings
	if config.performance then
		if
			config.performance.color_cache_size
			and config.performance.color_cache_size < 100
		then
			report_status(
				"warn",
				"Color cache size is very small (< 100), might reduce performance benefits"
			)
		elseif
			config.performance.color_cache_size
			and config.performance.color_cache_size > 10000
		then
			report_status(
				"warn",
				"Color cache size is very large (> 10000), might use excessive memory"
			)
		else
			report_status("ok", "Color cache size is reasonably configured")
		end

		if
			config.performance.debounce_delay
			and config.performance.debounce_delay < 10
		then
			report_status(
				"warn",
				"Debounce delay is very short (< 10ms), might cause performance issues"
			)
		elseif
			config.performance.debounce_delay
			and config.performance.debounce_delay > 500
		then
			report_status(
				"warn",
				"Debounce delay is very long (> 500ms), might feel unresponsive"
			)
		else
			report_status("ok", "Debounce delay is reasonably configured")
		end

		if config.performance.animation_skip_unchanged == false then
			report_status(
				"info",
				"Animation optimization is disabled - all frames will be rendered"
			)
		else
			report_status(
				"ok",
				"Animation optimization is enabled for better performance"
			)
		end
	else
		report_status("ok", "Using default performance settings")
	end

	separator("Highlight Configuration Checks")

	-- Check highlight configurations
	local required_highlights =
		{ "undo", "redo", "yank", "paste", "search", "comment", "cursor" }
	for _, hl_name in ipairs(required_highlights) do
		local hl_config = config.highlights[hl_name]
		if not hl_config then
			report_status(
				"error",
				"Missing highlight configuration for '" .. hl_name .. "'"
			)
		elseif not hl_config.hl then
			report_status(
				"error",
				"Missing 'hl' field in "
					.. hl_name
					.. " highlight configuration"
			)
		elseif not hl_config.hl_color then
			report_status(
				"error",
				"Missing 'hl_color' field in "
					.. hl_name
					.. " highlight configuration"
			)
		else
			report_status("ok", hl_name .. " highlight configuration is valid")
		end
	end

	separator("Transparency Fallback Checks")
	local normal = vim.api.nvim_get_hl(0, { name = "Normal" })

	if not normal.bg then
		if
			not config.fallback_for_transparency
			or not config.fallback_for_transparency.bg
		then
			report_status(
				"error",
				"Transparent background detected, but no fallback color is set. Please set `config.fallback_for_transparency.bg` to a valid color."
			)
		else
			report_status(
				"ok",
				"Fallback background color is configured for transparency"
			)
		end
	else
		report_status(
			"ok",
			"Background color is set, no transparency fallback needed"
		)
	end

	if not normal.fg then
		if
			not config.fallback_for_transparency
			or not config.fallback_for_transparency.fg
		then
			report_status(
				"error",
				"Transparent foreground detected, but no fallback color is set. Please set `config.fallback_for_transparency.fg` to a valid color."
			)
		else
			report_status(
				"ok",
				"Fallback foreground color is configured for transparency"
			)
		end
	else
		report_status(
			"ok",
			"Foreground color is set, no transparency fallback needed"
		)
	end

	separator("Priority Configuration Check")
	if config.priority < 0 then
		report_status("error", "Extmark priority cannot be negative")
	elseif config.priority > 65535 then
		report_status("error", "Extmark priority cannot exceed 65535")
	elseif config.priority < 1000 then
		report_status(
			"warn",
			"Extmark priority is low (< 1000), highlights might be hidden by other plugins"
		)
	else
		report_status("ok", "Extmark priority is reasonably configured")
	end

	-- Emit health check completed event
	api.emit("health_check_completed")
end

return M
