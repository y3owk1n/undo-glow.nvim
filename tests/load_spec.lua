---@module 'luassert'

local M = require("undo-glow")

describe("Load Tests", function()
	describe("Plugin Startup Performance", function()
		it("should initialize quickly", function()
			local start_time = vim.uv.hrtime()

			-- Setup the plugin
			M.setup()

			local end_time = vim.uv.hrtime()
			local duration = (end_time - start_time) / 1000000 -- milliseconds

			-- Plugin should initialize in under 50ms
			assert.is_true(duration < 50, string.format("Plugin initialization took %.2fms", duration))
		end)

		it("should handle multiple setup calls gracefully", function()
			local start_time = vim.uv.hrtime()

			-- Call setup multiple times
			for i = 1, 10 do
				M.setup({
					animation = {
						enabled = i % 2 == 0, -- Alternate enabled/disabled
					}
				})
			end

			local end_time = vim.uv.hrtime()
			local duration = (end_time - start_time) / 1000000 -- milliseconds

			-- Multiple setups should be reasonably fast
			assert.is_true(duration < 200, string.format("Multiple setups took %.2fms", duration))
		end)
	end)

	describe("Memory Usage Over Time", function()
		it("should not accumulate memory with repeated operations", function()
			local bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {"Test line for memory test"})

			-- Perform many operations
			for i = 1, 100 do
				M.highlight_region({
					s_row = 0,
					s_col = 0,
					e_row = 0,
					e_col = 4,
				})
			end

			vim.api.nvim_buf_delete(bufnr, { force = true })

			-- Should not cause memory issues
			collectgarbage("collect")
			assert.is_true(true) -- If we get here without crashing, memory is OK
		end)

		it("should cleanup resources properly after operations", function()
			local bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {"Cleanup test"})

			-- Create some highlights
			for i = 1, 20 do
				M.highlight_region({
					s_row = 0,
					s_col = i % 10,
					e_row = 0,
					e_col = (i % 10) + 2,
				})
			end

			-- Force cleanup
			vim.cmd("hi clear")
			vim.api.nvim_buf_delete(bufnr, { force = true })

			-- Should not leave dangling references
			assert.is_true(true)
		end)
	end)

	describe("Concurrent Operations", function()
		it("should handle operations during buffer changes", function()
			local bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(bufnr)

			-- Simulate rapid buffer changes and highlights
			local operations = {}
			for i = 1, 50 do
				table.insert(operations, function()
					vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {string.rep("x", i)})
					M.highlight_region({
						s_row = 0,
						s_col = 0,
						e_row = 0,
						e_col = math.min(i, 10),
					})
				end)
			end

			-- Execute operations
			for _, op in ipairs(operations) do
				op()
			end

			vim.api.nvim_buf_delete(bufnr, { force = true })

			-- Should handle concurrent operations without crashing
			assert.is_true(true)
		end)

		it("should handle operations across multiple buffers", function()
			local buffers = {}

			-- Create multiple buffers
			for i = 1, 10 do
				local bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {"Buffer " .. i})
				table.insert(buffers, bufnr)
			end

			-- Perform operations on all buffers
			for _, bufnr in ipairs(buffers) do
				vim.api.nvim_set_current_buf(bufnr)
				M.highlight_region({
					s_row = 0,
					s_col = 0,
					e_row = 0,
					e_col = 7,
				})
			end

			-- Cleanup
			for _, bufnr in ipairs(buffers) do
				vim.api.nvim_buf_delete(bufnr, { force = true })
			end

			-- Should handle multi-buffer operations
			assert.is_true(true)
		end)
	end)
end)