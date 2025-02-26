---@module 'luassert'

local color = require("undo-glow.color")

describe("undo-glow.color", function()
	describe("hex_to_rgb", function()
		it("converts hex color to rgb", function()
			local rgb = color.hex_to_rgb("#FF0000")
			assert.are.same({ r = 255, g = 0, b = 0 }, rgb)
		end)
	end)

	describe("rgb_to_hex", function()
		it("converts rgb to hex", function()
			local hex = color.rgb_to_hex({ r = 255, g = 0, b = 0 })
			assert.are.equal("#FF0000", hex)
		end)
	end)

	describe("blend_color", function()
		it("blends two colors with t=0.5", function()
			local c1 = { r = 255, g = 0, b = 0 } -- red
			local c2 = { r = 0, g = 0, b = 255 } -- blue
			local blended = color.blend_color(c1, c2, 0.5)
			assert.are.equal("#800080", blended) -- expect purple (#800080)
		end)
	end)

	describe("get_normal_bg", function()
		local original_get_hl = vim.api.nvim_get_hl
		after_each(function()
			vim.api.nvim_get_hl = original_get_hl
		end)

		it("returns formatted bg if present", function()
			vim.api.nvim_get_hl = function(ns, opts)
				return { bg = 16711680 } -- 0xFF0000
			end
			local bg = color.get_normal_bg()
			assert.are.equal("#FF0000", bg)
		end)

		it("returns default bg if not present", function()
			vim.api.nvim_get_hl = function(ns, opts)
				return {} -- no bg field
			end
			local bg = color.get_normal_bg()
			assert.are.equal(color.default_bg, bg)
		end)
	end)

	describe("get_normal_fg", function()
		local original_get_hl = vim.api.nvim_get_hl
		after_each(function()
			vim.api.nvim_get_hl = original_get_hl
		end)

		it("returns formatted fg if present", function()
			vim.api.nvim_get_hl = function(ns, opts)
				return { fg = 255 } -- 0x0000FF when formatted (#0000FF)
			end
			local fg = color.get_normal_fg()
			assert.are.equal("#0000FF", fg)
		end)

		it("returns default fg if not present", function()
			vim.api.nvim_get_hl = function(ns, opts)
				return {} -- no fg field
			end
			local fg = color.get_normal_fg()
			assert.are.equal(color.default_fg, fg)
		end)
	end)

	describe("init_colors", function()
		it("formats bg and fg when provided", function()
			local detail = { bg = 16776960, fg = 65280 } -- bg: 0xFFFF00, fg: 0x00FF00
			local init = color.init_colors(detail)
			assert.are.equal("#FFFF00", init.bg)
			assert.are.equal("#00FF00", init.fg)
		end)

		it("returns default undo bg if bg is missing and nil for fg", function()
			local detail = {} -- no bg or fg provided
			local init = color.init_colors(detail)
			assert.are.equal(color.default_undo.bg, init.bg)
			assert.is_nil(init.fg)
		end)
	end)
end)
