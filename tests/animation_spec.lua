---@module 'luassert'

local animation = require("undo-glow.animation")

local assert = require("luassert")

local utils = require("undo-glow.utils")

describe("undo-glow.animation", function()
	local bufnr
	local hlgroup
	local ns = utils.ns

	before_each(function()
		bufnr = vim.api.nvim_create_buf(false, true)
		hlgroup = "TestHl" .. tostring(math.random(1000))
	end)

	after_each(function()
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
		vim.cmd("hi clear " .. hlgroup)
	end)

	local function start_animation(animation_type, duration)
		local extmark_id = vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})
		local opts = {
			bufnr = bufnr,
			extmark_id = extmark_id,
			hlgroup = hlgroup,
			start_bg = { r = 255, g = 0, b = 0 }, -- Red
			end_bg = { r = 0, g = 0, b = 255 }, -- Blue
			start_fg = { r = 255, g = 255, b = 255 }, -- White
			end_fg = { r = 0, g = 0, b = 0 }, -- Black
			duration = duration or 100, -- Default 100ms for tests
			state = {
				animation = {
					fps = 60,
					easing = function(params)
						return params.time
					end, -- Linear easing
				},
			},
		}
		animation.animate[animation_type](opts)
		return extmark_id
	end

	local function wait_for_animation(duration)
		vim.wait(duration + 50) -- Wait duration + 50ms buffer
	end

	describe("fade animation", function()
		it("cleans up extmark and hlgroup", function()
			local extmark_id = start_animation("fade", 100)
			wait_for_animation(100)

			local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
			assert.same({}, marks)

			local hl = vim.api.nvim_get_hl(hlgroup, true)
			assert.is_nil(hl.background)
		end)
	end)

	describe("blink animation", function()
		it("cleans up extmark and hlgroup", function()
			local extmark_id = start_animation("blink", 100)
			wait_for_animation(100)

			local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
			assert.same({}, marks)

			local hl = vim.api.nvim_get_hl(hlgroup, true)
			assert.is_nil(hl.background)
		end)
	end)

	describe("jitter animation", function()
		it("cleans up extmark and hlgroup", function()
			local extmark_id = start_animation("jitter", 100)
			wait_for_animation(100)

			local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
			assert.same({}, marks)

			local hl = vim.api.nvim_get_hl(hlgroup, true)
			assert.is_nil(hl.background)
		end)
	end)

	describe("pulse animation", function()
		it("cleans up extmark and hlgroup", function()
			local extmark_id = start_animation("pulse", 100)
			wait_for_animation(100)

			local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
			assert.same({}, marks)

			local hl = vim.api.nvim_get_hl(hlgroup, true)
			assert.is_nil(hl.background)
		end)
	end)

	it("handles invalid buffer during animation", function()
		local extmark_id = start_animation("fade", 200)
		vim.api.nvim_buf_delete(bufnr, { force = true })
		wait_for_animation(200)

		local hl = vim.api.nvim_get_hl(hlgroup, true)
		assert.is_nil(hl.background)
	end)
end)
