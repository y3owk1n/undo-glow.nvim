---@module 'luassert'

local M = require("undo-glow")

describe("Documentation Examples", function()
	describe("README examples", function()
		it("should work with basic setup example", function()
			-- Example from README: Basic setup
			local success = pcall(function()
				require("undo-glow").setup({
					animation = {
						enabled = true,
						duration = 300,
						animation_type = "fade",
					},
					highlights = {
						undo = {
							hl = "UndoGlow",
							hl_color = "#FF0000",
						},
					},
				})
			end)
			assert.is_true(success)
		end)

		it("should work with custom colors example", function()
			-- Example from README: Custom colors
			local success = pcall(function()
				require("undo-glow").setup({
					highlights = {
						undo = { hl_color = "#FF6B6B" },
						redo = { hl_color = "#4ECDC4" },
						yank = { hl_color = "#45B7D1" },
						paste = { hl_color = "#96CEB4" },
					},
				})
			end)
			assert.is_true(success)
		end)

		it("should work with animation disabled example", function()
			-- Example from README: Animation disabled
			local success = pcall(function()
				require("undo-glow").setup({
					animation = {
						enabled = false,
					},
				})
			end)
			assert.is_true(success)
		end)
	end)

	describe("Recipes examples", function()
		it("should work with yank integration example", function()
			-- Example from recipes: Yank integration
			local success = pcall(function()
				require("undo-glow").setup({
					animation = {
						enabled = true,
						duration = 200,
					},
				})
			end)
			assert.is_true(success)
		end)

		it("should work with flash integration example", function()
			-- Example from recipes: Flash integration
			local success = pcall(function()
				require("undo-glow").setup({
					animation = {
						enabled = true,
						duration = 150,
					},
				})
			end)
			assert.is_true(success)
		end)
	end)
end)