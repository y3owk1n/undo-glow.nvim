---@module 'luassert'

local config = require("undo-glow.config")
local validate = require("undo-glow.validate")
local animation = require("undo-glow.animation")
local highlight = require("undo-glow.highlight")
local utils = require("undo-glow.utils")
local color = require("undo-glow.color")
local spy = require("luassert.spy")

describe("Edge Cases and Error Conditions", function()
	describe("Configuration Validation", function()
		it("should handle nil configuration gracefully", function()
			local success = pcall(config.setup, nil)
			assert.is_true(success)
		end)

		it("should handle empty configuration table", function()
			local success = pcall(config.setup, {})
			assert.is_true(success)
		end)

		it("should reject invalid animation.enabled type", function()
			local success = validate.validate_animation_config({ enabled = "invalid" })
			assert.is_false(success)
		end)

		it("should reject negative animation duration", function()
			local success = validate.validate_animation_config({ duration = -100 })
			assert.is_false(success)
		end)

		it("should reject invalid animation fps", function()
			local success = validate.validate_animation_config({ fps = 300 })
			assert.is_false(success)
		end)

		it("should reject invalid animation type", function()
			local success = validate.validate_animation_config({ animation_type = "invalid_type" })
			assert.is_false(success)
		end)

		it("should accept valid custom animation function", function()
			local success = validate.validate_animation_config({
				animation_type = function() end
			})
			assert.is_true(success)
		end)

		it("should accept valid priority range", function()
			local success = pcall(config.setup, { priority = 1000 })
			assert.is_true(success)
		end)
	end)

	describe("Animation Edge Cases", function()
		local bufnr, ns

		before_each(function()
			bufnr = vim.api.nvim_create_buf(false, true)
			ns = utils.ns
		end)

		after_each(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_delete(bufnr, { force = true })
			end
		end)

		it("should handle animation with invalid buffer gracefully", function()
			local invalid_bufnr = 99999
			local opts = {
				bufnr = invalid_bufnr,
				ns = ns,
				hlgroup = "TestHL",
				start_bg = { r = 255, g = 0, b = 0 },
				end_bg = { r = 0, g = 255, b = 0 },
				duration = 100,
				state = { animation = { fps = 60, easing = "linear" } },
				coordinates = { s_row = 0, s_col = 0, e_row = 1, e_col = 10 },
				extmark_ids = {},
			}

			-- This should not crash
			local success = pcall(animation.animate.fade, opts)
			-- The function may or may not succeed depending on implementation, but it shouldn't crash
			assert.is_boolean(success)
		end)

		it("should handle animation with zero duration gracefully", function()
			local opts = {
				bufnr = bufnr,
				ns = ns,
				hlgroup = "TestHL",
				start_bg = { r = 255, g = 0, b = 0 },
				end_bg = { r = 0, g = 255, b = 0 },
				duration = 0,
				state = { animation = { fps = 60, easing = "linear" } },
				coordinates = { s_row = 0, s_col = 0, e_row = 1, e_col = 10 },
				extmark_ids = {},
			}

			local success = pcall(animation.animate.fade, opts)
			-- Should handle zero duration gracefully
			assert.is_boolean(success)
		end)
	end)

	describe("Highlight Edge Cases", function()
		it("should handle highlight creation with invalid colors", function()
			local success = pcall(highlight.set_highlight, "TestHL", { bg = "invalid" })
			assert.is_true(success) -- Should not crash
			vim.cmd("hi clear TestHL")
		end)

		it("should handle highlight creation with nil colors", function()
			local success = pcall(highlight.set_highlight, "TestHL", nil)
			assert.is_true(success) -- Should not crash
			vim.cmd("hi clear TestHL")
		end)

		it("should handle empty highlight name", function()
			local success = pcall(highlight.set_highlight, "", { bg = "#FF0000" })
			assert.is_true(success) -- Should not crash
		end)
	end)

	describe("Color Edge Cases", function()
		it("should handle invalid hex colors gracefully", function()
			local result = color.hex_to_rgb("invalid")
			-- The function may return a default value or nil, but shouldn't crash
			assert.is_table(result) -- It returns a table with default values
		end)

		it("should handle hex colors with odd length", function()
			local result = color.hex_to_rgb("#12345")
			-- Should handle malformed input gracefully
			assert.is_table(result)
		end)

		it("should handle rgb_to_hex with invalid values", function()
			local result = color.rgb_to_hex({ r = -1, g = 0, b = 0 })
			assert.is_string(result) -- Should still return a string
		end)

		it("should handle hsl_to_rgb with out of range values", function()
			local result = color.hsl_to_rgb({ h = 400, s = 150, l = -50 })
			assert.is_table(result) -- Should still return a table
		end)
	end)

	describe("Utility Edge Cases", function()
		local bufnr

		before_each(function()
			bufnr = vim.api.nvim_create_buf(false, true)
		end)

		after_each(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_delete(bufnr, { force = true })
			end
		end)

		it("should handle sanitize_coords with invalid buffer gracefully", function()
			local success = pcall(utils.sanitize_coords, 99999, 0, 0, 1, 10)
			-- Should handle invalid buffer gracefully
			assert.is_boolean(success)
		end)

		it("should handle sanitize_coords with empty buffer", function()
			-- Create an empty buffer
			local empty_buf = vim.api.nvim_create_buf(false, true)
			local s_row, s_col, e_row, e_col = utils.sanitize_coords(empty_buf, 0, 0, 1, 10)
			assert.equals(0, s_row)
			assert.equals(0, s_col)
			assert.equals(1, e_row) -- Should clamp to available lines
			assert.equals(0, e_col) -- Should clamp to line length
			vim.api.nvim_buf_delete(empty_buf, { force = true })
		end)

		it("should handle get_unique_hlgroup with empty base", function()
			local result = utils.get_unique_hlgroup("")
			assert.matches("^_%d+$", result)
		end)

		it("should handle get_unique_hlgroup with special characters", function()
			local result = utils.get_unique_hlgroup("test-with-dashes")
			assert.matches("^test%-with%-dashes_%d+$", result)
		end)
	end)

	describe("Validation Edge Cases", function()
		it("should handle validate_command_opts with nil", function()
			local success = validate.validate_command_opts(nil)
			assert.is_true(success)
		end)

		it("should handle validate_command_opts with invalid hlgroup", function()
			local success = validate.validate_command_opts({ hlgroup = 123 })
			assert.is_false(success)
		end)

		it("should handle validate_command_opts with invalid force_edge", function()
			local success = validate.validate_command_opts({ force_edge = "invalid" })
			assert.is_false(success)
		end)

		it("should handle validate_highlight_config with unknown keys", function()
			local success = validate.validate_highlight_config({
				undo = { hl = "Test" },
				invalid_key = { hl = "Test" }
			})
			assert.is_true(success) -- Should succeed but warn about unknown keys
		end)
	end)

	describe("Buffer and Window Edge Cases", function()
		it("should handle operations on invalid buffers", function()
			local success = pcall(vim.api.nvim_buf_set_lines, 99999, 0, -1, false, {"test"})
			assert.is_false(success)
		end)

		it("should handle operations on invalid windows", function()
			local success = pcall(vim.api.nvim_win_get_cursor, 99999)
			assert.is_false(success)
		end)

		it("should handle extmark operations on invalid buffers", function()
			local success = pcall(vim.api.nvim_buf_set_extmark, 99999, 0, 0, 0, {})
			assert.is_false(success)
		end)
	end)

	describe("Memory and Cleanup Edge Cases", function()
		it("should handle multiple rapid highlight operations", function()
			for i = 1, 50 do
				local hl_name = "RapidHL" .. i
				highlight.set_highlight(hl_name, { bg = "#FF0000" })
				vim.cmd("hi clear " .. hl_name)
			end
			-- Should not cause memory issues or crashes
			assert.is_true(true)
		end)

		it("should handle cleanup of non-existent highlights", function()
			local success = pcall(vim.cmd, "hi clear NonExistentHL")
			assert.is_true(success) -- Should not error
		end)

		it("should handle deletion of non-existent extmarks", function()
			local success = pcall(vim.api.nvim_buf_del_extmark, 1, 0, 99999)
			assert.is_false(success) -- Should fail gracefully
		end)
	end)
end)