---@module 'luassert'

local color = require("undo-glow.color")

describe("undo-glow.color", function()
	describe("hex_to_rgb", function()
		it("should convert valid hex colors to RGB tables", function()
			local result = color.hex_to_rgb("#FF5555")
			assert.are.same({ r = 255, g = 85, b = 85 }, result)

			result = color.hex_to_rgb("50FA7B")
			assert.are.same({ r = 80, g = 250, b = 123 }, result)
		end)

		it("should handle 3-character hex codes", function()
			local result = color.hex_to_rgb("#F00")
			assert.are.same({ r = 255, g = 0, b = 0 }, result)
		end)
	end)

	describe("rgb_to_hex", function()
		it("should convert RGB tables to hex strings", function()
			local result = color.rgb_to_hex({ r = 255, g = 85, b = 85 })
			assert.are.equal("#FF5555", result)

			result = color.rgb_to_hex({ r = 0, g = 0, b = 0 })
			assert.are.equal("#000000", result)
		end)
	end)

	describe("blend_color", function()
		it("should properly blend two colors", function()
			local red = color.hex_to_rgb("#FF0000")
			local blue = color.hex_to_rgb("#0000FF")

			local result = color.blend_color(red, blue, 0.5)
			assert.are.equal("#800080", result)

			result = color.blend_color(red, blue, 0)
			assert.are.equal("#FF0000", result)

			result = color.blend_color(red, blue, 1)
			assert.are.equal("#0000FF", result)
		end)
	end)

	describe("get_normal_bg", function()
		before_each(function()
			vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
		end)

		it("should return Normal highlight background", function()
			vim.api.nvim_set_hl(0, "Normal", { bg = "#123456" })
			assert.are.equal("#123456", color.get_normal_bg())
		end)

		it("should return default when no background set", function()
			assert.are.equal(color.default_bg, color.get_normal_bg())
		end)
	end)

	describe("get_normal_fg", function()
		before_each(function()
			vim.api.nvim_set_hl(0, "Normal", { fg = "NONE" })
		end)

		it("should return Normal highlight foreground", function()
			vim.api.nvim_set_hl(0, "Normal", { fg = "#ABCDEF" })
			assert.are.equal("#ABCDEF", color.get_normal_fg())
		end)

		it("should return default when no foreground set", function()
			assert.are.equal(color.default_fg, color.get_normal_fg())
		end)
	end)

	describe("init_colors", function()
		it("should initialize colors from hl group data", function()
			local hl_group = { bg = 0xFF5555, fg = 0x50FA7B }
			local result = color.init_colors(hl_group)
			assert.are.same({ bg = "#FF5555", fg = "#50FA7B" }, result)
		end)

		it("should use default_undo bg when missing", function()
			local hl_group = { fg = 0x50FA7B }
			local result = color.init_colors(hl_group)
			assert.are.same(
				{ bg = color.default_undo.bg, fg = "#50FA7B" },
				result
			)
		end)

		it("should handle missing fg gracefully", function()
			local hl_group = { bg = 0xFF5555 }
			local result = color.init_colors(hl_group)
			assert.are.same({ bg = "#FF5555", fg = nil }, result)
		end)
	end)
end)
