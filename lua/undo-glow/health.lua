local M = {}

--- Reports a status message using vim.health.
--- Supports boolean values (true for OK, false for error) and string levels ("ok", "warn", "error").
--- @param level "ok"|"warn"|"error" The status level.
--- @param msg string The message to display.
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

--- Prints a separator header for a new section.
--- @param title string The section title.
local function separator(title)
	vim.health.start(title)
end

function M.check()
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

	separator("Module Load Checks")
	-- Check that required plugin modules load successfully.
	local required_modules = {
		"undo-glow.animation",
		"undo-glow.callback",
		"undo-glow.color",
		"undo-glow.commands",
		"undo-glow.config",
		"undo-glow.easing",
		"undo-glow.highlight",
		"undo-glow.utils",
		"vim._comment",
	}
	for _, mod in ipairs(required_modules) do
		local ok, _ = pcall(require, mod)
		if ok then
			report_status("ok", "Module " .. mod .. " loaded.")
		else
			report_status("error", "Module " .. mod .. " failed to load.")
		end
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
	local ok, err = pcall(function()
		vim.api.nvim_set_hl(0, test_hl, { bg = "#000000", fg = "#ffffff" })
	end)
	if ok then
		report_status("ok", "Able to set highlight group '" .. test_hl .. "'.")
	else
		report_status(
			"error",
			"Failed to set highlight group '" .. test_hl .. "': " .. err
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

	separator("Config Checks")
	local config = require("undo-glow").config

	if config.animation.enabled then
		report_status("ok", "Animation is enabled in the configuration.")
	else
		report_status("warn", "Animation is disabled in the configuration.")
	end

	if config.animation.enabled and config.animation.duration < 300 then
		report_status(
			"warn",
			"Duration is less than 300, it might be too fast for an animation"
		)
	elseif
		config.animation.enabled == false
		and config.animation.duration > 300
	then
		report_status(
			"warn",
			"Duration is more than 300, the highlights might be too slow!"
		)
	else
		report_status("ok", "Animation duration seems reasonable")
	end

	if config.animation.enabled and config.animation.fps < 30 then
		report_status("warn", "FPS less than 30 might be visually unappealling")
	elseif config.animation.enabled and config.animation.fps > 30 then
		report_status("ok", "FPS is reasonably set")
	end
end

return M
