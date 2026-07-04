#!/usr/bin/env -S nvim -l

vim.env.NVIM_TESTING = "1"

local deps_dir = vim.uv.cwd() .. "/.tests/deps"

local function ensure_dep(name, url)
	local path = deps_dir .. "/" .. name
	if vim.fn.isdirectory(path) == 0 then
		vim.fn.mkdir(deps_dir, "p")
		local ok = vim.fn.system({
			"git", "clone", "--depth=1", "--single-branch",
			url, path,
		})
		if vim.v.shell_error ~= 0 then
			vim.print("Failed to clone " .. name .. ": " .. ok)
			vim.cmd("cquit!")
		end
	end
	vim.opt.rtp:append(path)
end

ensure_dep("plenary.nvim", "https://github.com/nvim-lua/plenary.nvim.git")
ensure_dep("yanky.nvim", "https://github.com/gbprod/yanky.nvim.git")
ensure_dep("substitute.nvim", "https://github.com/gbprod/substitute.nvim.git")
ensure_dep("flash.nvim", "https://github.com/folke/flash.nvim.git")

vim.opt.rtp:append(vim.uv.cwd())

require("plenary.busted")
require("plenary.test_harness").test_directory("tests", { init = "tests/init.lua" })
