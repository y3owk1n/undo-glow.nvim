local M = {}

local function report_status(ok, msg)
	local health = vim.health or {}
	if ok then
		health.ok(msg)
	else
		health.error(msg)
	end
end

function M.check()
	if not vim.uv then
		report_status(
			false,
			"vim.uv not found. Please upgrade to a newer Neovim version (>=0.7)."
		)
	else
		report_status(true, "vim.uv is available.")
	end

	if not vim.api.nvim_set_hl then
		report_status(false, "nvim_set_hl API is missing.")
	else
		report_status(true, "nvim_set_hl API is available.")
	end

	-- Check that required plugin modules load successfully
	local required_modules = {
		"undo-glow.animation",
		"undo-glow.callback",
		"undo-glow.color",
		"undo-glow.config",
		"undo-glow.easing",
		"undo-glow.highlight",
		"undo-glow.utils",
	}
	for _, mod in ipairs(required_modules) do
		local ok, _ = pcall(require, mod)
		if ok then
			report_status(true, "Module " .. mod .. " loaded.")
		else
			report_status(false, "Module " .. mod .. " failed to load.")
		end
	end

	-- Test timer creation
	local timer = vim.uv.new_timer()
	if timer then
		report_status(true, "Timer creation is working.")
		timer:stop()
		if not vim.uv.is_closing(timer) then
			timer:close()
		end
	else
		report_status(false, "Timer creation failed.")
	end

	-- Test setting a highlight group
	local test_hl = "UndoGlowHealthTest"
	local ok, err = pcall(function()
		vim.api.nvim_set_hl(0, test_hl, { bg = "#000000", fg = "#ffffff" })
	end)
	if ok then
		report_status(true, "Able to set highlight group '" .. test_hl .. "'.")
	else
		report_status(
			false,
			"Failed to set highlight group '" .. test_hl .. "': " .. err
		)
	end

	-- Clean up the test highlight group
	vim.cmd("hi clear " .. test_hl)
end

return M
