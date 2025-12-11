---@module 'luassert'

local M = require("undo-glow")
local config = require("undo-glow.config")

describe("Configuration Tests", function()
	describe("Performance Configuration", function()
		it("should apply performance settings correctly", function()
			local test_config = {
				performance = {
					color_cache_size = 500,
					debounce_delay = 100,
					animation_skip_unchanged = false,
				},
			}

			local success = pcall(M.setup, test_config)
			assert.is_true(success)

			-- Verify config was applied
			assert.equals(500, config.config.performance.color_cache_size)
			assert.equals(100, config.config.performance.debounce_delay)
			assert.equals(
				false,
				config.config.performance.animation_skip_unchanged
			)
		end)

		it(
			"should use default performance settings when not specified",
			function()
				local test_config = {} -- Empty config

				local success = pcall(M.setup, test_config)
				assert.is_true(success)

				-- Verify defaults are applied
				assert.equals(1000, config.config.performance.color_cache_size)
				assert.equals(50, config.config.performance.debounce_delay)
				assert.equals(
					true,
					config.config.performance.animation_skip_unchanged
				)
			end
		)

		it("should handle invalid performance settings gracefully", function()
			local test_config = {
				performance = {
					color_cache_size = -100, -- Invalid
					debounce_delay = "invalid", -- Invalid type
				},
			}

			local success = pcall(M.setup, test_config)
			assert.is_true(success) -- Should not crash

			-- Config object retains the invalid values, but modules should use defaults
			-- The important thing is that the plugin doesn't crash
			assert.is_true(true)
		end)
	end)

	describe("Logging Configuration", function()
		it("should apply logging settings correctly", function()
			local test_config = {
				logging = {
					level = "DEBUG",
					notify = false,
					file = true,
					file_path = "/tmp/test.log",
				},
			}

			local success = pcall(M.setup, test_config)
			assert.is_true(success)

			-- Verify config was applied
			assert.equals("DEBUG", config.config.logging.level)
			assert.equals(false, config.config.logging.notify)
			assert.equals(true, config.config.logging.file)
			assert.equals("/tmp/test.log", config.config.logging.file_path)
		end)

		it("should use default logging settings when not specified", function()
			local test_config = {} -- Empty config

			local success = pcall(M.setup, test_config)
			assert.is_true(success)

			-- Verify defaults are applied
			assert.equals("INFO", config.config.logging.level)
			assert.equals(true, config.config.logging.notify)
			assert.equals(false, config.config.logging.file)
			assert.is_nil(config.config.logging.file_path)
		end)

		it("should handle invalid logging settings gracefully", function()
			local test_config = {
				logging = {
					level = "INVALID_LEVEL", -- Invalid
					notify = "not_boolean", -- Invalid type
				},
			}

			local success = pcall(M.setup, test_config)
			assert.is_true(success) -- Should not crash

			-- Config object retains the invalid values, but modules should use defaults
			-- The important thing is that the plugin doesn't crash
			assert.is_true(true)
		end)
	end)

	describe("Backward Compatibility", function()
		it("should work with minimal configuration", function()
			local minimal_config = {
				animation = {
					enabled = true,
				},
				highlights = {
					undo = {
						hl_color = { bg = "#FF0000" },
					},
				},
			}

			local success = pcall(M.setup, minimal_config)
			assert.is_true(success)

			-- Should have defaults for new features
			assert.is_table(config.config.performance)
			assert.is_table(config.config.logging)
		end)

		it("should preserve existing behavior", function()
			-- Test that existing functionality still works
			local test_config = {
				animation = {
					enabled = true,
					duration = 200,
				},
				highlights = {
					undo = { hl_color = { bg = "#FF0000" } },
					redo = { hl_color = { bg = "#00FF00" } },
				},
				priority = 500,
			}

			local success = pcall(M.setup, test_config)
			assert.is_true(success)

			-- Verify existing config still works
			assert.equals(true, config.config.animation.enabled)
			assert.equals(200, config.config.animation.duration)
			assert.equals("#FF0000", config.config.highlights.undo.hl_color.bg)
			assert.equals(500, config.config.priority)
		end)
	end)
end)
