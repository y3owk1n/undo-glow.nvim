#!/usr/bin/env -S nvim -l

-- Configure lazy.nvim environment variables.
vim.env.LAZY_STDPATH = ".tests"
-- vim.env.LAZY_PATH = vim.fs.normalize("~/projects/lazy.nvim")

-- Bootstrap lazy.nvim by loading its bootstrap script.
load(
	vim.fn.system(
		"curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"
	)
)()

-- Setup lazy.nvim in minimal mode. This will load plugins as defined in your spec.
require("lazy.minit").setup({
	spec = {
		{ "nvim-lua/plenary.nvim", lazy = false }, -- Ensure plenary loads immediately.
		{ "gbprod/yanky.nvim", lazy = false }, -- Yank integration testing
		{ "gbprod/substitute.nvim", lazy = false }, -- Substitute integration testing
		{ "folke/flash.nvim", lazy = false }, -- Flash integration testing
		{
			dir = vim.uv.cwd(),
			opts = {
				notify = false,
			},
		},
	},
})
