vim.env.NVIM_TESTING = "1"

local deps_dir = vim.fn.getcwd() .. "/.tests/deps"
for _, name in ipairs({ "yanky.nvim", "substitute.nvim", "flash.nvim" }) do
	vim.opt.rtp:prepend(deps_dir .. "/" .. name)
end
vim.opt.rtp:prepend(vim.fn.getcwd())

require("undo-glow").setup({
	notify = false,
	logging = { notify = false, file = false },
})
