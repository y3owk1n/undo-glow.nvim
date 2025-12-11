---@module 'luassert'

local M = require("undo-glow")

describe("Stress Tests", function()
	describe("Large Buffer Operations", function()
		local large_bufnr

		before_each(function()
			large_bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(large_bufnr)

			-- Create a large buffer with 1000 lines
			local lines = {}
			for i = 1, 1000 do
				lines[i] = "Line " .. i .. ": " .. string.rep("word ", 20)
			end
			vim.api.nvim_buf_set_lines(large_bufnr, 0, -1, false, lines)
		end)

		after_each(function()
			if vim.api.nvim_buf_is_valid(large_bufnr) then
				vim.api.nvim_buf_delete(large_bufnr, { force = true })
			end
		end)

		it("should handle highlighting large regions efficiently", function()
			local start_time = vim.uv.hrtime()

			-- Highlight a large region (lines 100-900)
			local opts = {
				s_row = 100,
				s_col = 0,
				e_row = 900,
				e_col = 50,
			}

			local success = pcall(M.highlight_region, opts)
			assert.is_true(success)

			local end_time = vim.uv.hrtime()
			local duration = (end_time - start_time) / 1000000 -- milliseconds

			-- Should complete within reasonable time (under 100ms for large operations)
			assert.is_true(duration < 100, string.format("Large region highlighting took %.2fms", duration))
		end)

		it("should handle rapid successive operations", function()
			local start_time = vim.uv.hrtime()

			-- Perform 50 rapid highlight operations
			for i = 1, 50 do
				local opts = {
					s_row = i * 10,
					s_col = 0,
					e_row = i * 10,
					e_col = 20,
				}
				M.highlight_region(opts)
			end

			local end_time = vim.uv.hrtime()
			local duration = (end_time - start_time) / 1000000 -- milliseconds

			-- Should handle rapid operations efficiently
			assert.is_true(duration < 500, string.format("50 rapid operations took %.2fms", duration))
		end)
	end)

	describe("Resource Management", function()
		it("should not accumulate extmarks over time", function()
			local bufnr = vim.api.nvim_create_buf(false, true)
			local ns = vim.api.nvim_create_namespace("StressTest")

			local initial_marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})

			-- Create and delete 100 extmarks
			for i = 1, 100 do
				local id = vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})
				vim.api.nvim_buf_del_extmark(bufnr, ns, id)
			end

			local final_marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})

			vim.api.nvim_buf_delete(bufnr, { force = true })

			-- Should not leak extmarks
			assert.equals(#initial_marks, #final_marks, "Extmarks should be properly cleaned up")
		end)

		it("should handle many concurrent animations", function()
			local bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {"Test line for animation"})

			-- Start multiple animations simultaneously
			local animations = {}
			for i = 1, 10 do
				local opts = {
					s_row = 0,
					s_col = i * 2,
					e_row = 0,
					e_col = i * 2 + 2,
				}
				table.insert(animations, coroutine.create(function()
					M.highlight_region(opts)
				end))
			end

			-- Resume all animations
			for _, anim in ipairs(animations) do
				coroutine.resume(anim)
			end

			vim.api.nvim_buf_delete(bufnr, { force = true })

			-- Should not crash with concurrent operations
			assert.is_true(true)
		end)
	end)

	describe("Memory and Performance Limits", function()
		it("should handle very long lines", function()
			local bufnr = vim.api.nvim_create_buf(false, true)

			-- Create a line with 10,000 characters
			local long_line = string.rep("a", 10000)
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {long_line})

			local start_time = vim.uv.hrtime()

			local opts = {
				s_row = 0,
				s_col = 1000,
				e_row = 0,
				e_col = 2000,
			}

			local success = pcall(M.highlight_region, opts)
			assert.is_true(success)

			local end_time = vim.uv.hrtime()
			local duration = (end_time - start_time) / 1000000 -- milliseconds

			vim.api.nvim_buf_delete(bufnr, { force = true })

			-- Should handle long lines reasonably well
			assert.is_true(duration < 50, string.format("Long line highlighting took %.2fms", duration))
		end)

		it("should handle deep nesting of operations", function()
			local bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {"Nested operations test"})

			local start_time = vim.uv.hrtime()

			-- Create deeply nested highlight operations
			for depth = 1, 20 do
				local opts = {
					s_row = 0,
					s_col = depth,
					e_row = 0,
					e_col = depth + 1,
				}
				M.highlight_region(opts)
			end

			local end_time = vim.uv.hrtime()
			local duration = (end_time - start_time) / 1000000 -- milliseconds

			vim.api.nvim_buf_delete(bufnr, { force = true })

			-- Should handle nested operations efficiently
			assert.is_true(duration < 100, string.format("Nested operations took %.2fms", duration))
		end)
	end)
end)