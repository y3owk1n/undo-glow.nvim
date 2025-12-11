---@module 'luassert'

local animation = require("undo-glow.animation")
local color = require("undo-glow.color")
local highlight = require("undo-glow.highlight")
local utils = require("undo-glow.utils")

describe("Performance Benchmarks", function()
	local bufnr, ns, hlgroup

	before_each(function()
		bufnr = vim.api.nvim_create_buf(false, true)
		ns = utils.ns
		hlgroup = "BenchmarkHL"
	end)

	after_each(function()
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
		vim.cmd("hi clear " .. hlgroup)
	end)

	describe("Animation Performance", function()
		it("should benchmark fade animation creation", function()
			-- Set up buffer content for valid coordinates
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {"Hello World!"})

			local animation_opts = {
				bufnr = bufnr,
				ns = ns,
				hlgroup = hlgroup,
				start_bg = { r = 255, g = 0, b = 0 },
				end_bg = { r = 0, g = 255, b = 0 },
				duration = 500,
				state = {
					animation = {
						fps = 60,
						easing = "linear",
					},
					force_edge = false,
				},
				coordinates = { s_row = 0, s_col = 0, e_row = 0, e_col = 5 },
				extmark_ids = {},
			}

			local start_time = vim.uv.hrtime()
			local iterations = 100

			for i = 1, iterations do
				animation.animate.fade(animation_opts)
			end

			local end_time = vim.uv.hrtime()
			local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds
			local avg_time = total_time / iterations

			print(string.format("Fade animation creation: %d iterations, %.2fms total, %.4fms avg", iterations, total_time, avg_time))
			assert.is_true(avg_time < 10, "Fade animation should be fast (< 10ms per operation)")
		end)

		it("should benchmark highlight creation", function()
			local iterations = 1000

			local start_time = vim.uv.hrtime()

			for i = 1, iterations do
				local name = "BenchmarkHL" .. i
				local color_def = { bg = "#FF0000", fg = "#00FF00" }
				highlight.set_highlight(name, color_def)
				vim.cmd("hi clear " .. name)
			end

			local end_time = vim.uv.hrtime()
			local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds
			local avg_time = total_time / iterations

			print(string.format("Highlight creation: %d iterations, %.2fms total, %.4fms avg", iterations, total_time, avg_time))
			assert.is_true(avg_time < 1, "Highlight creation should be very fast (< 1ms per operation)")
		end)

		it("should benchmark color conversion performance", function()
			local iterations = 10000

			local start_time = vim.uv.hrtime()

			for i = 1, iterations do
				color.hex_to_rgb("#FF5555")
				color.rgb_to_hex({ r = 255, g = 85, b = 85 })
				color.rgb_to_hsl({ r = 255, g = 85, b = 85 })
			end

			local end_time = vim.uv.hrtime()
			local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds
			local avg_time = total_time / iterations

			print(string.format("Color operations: %d iterations, %.2fms total, %.4fms avg", iterations, total_time, avg_time))
			assert.is_true(avg_time < 0.1, "Color operations should be very fast (< 0.1ms per operation)")
		end)

		it("should benchmark coordinate sanitization", function()
			-- Set up a buffer with content
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
				"Hello World!",
				"Another Hello World!",
				"No More!",
			})

			local iterations = 10000

			local start_time = vim.uv.hrtime()

			for i = 1, iterations do
				utils.sanitize_coords(bufnr, 0, 0, 2, 10)
			end

			local end_time = vim.uv.hrtime()
			local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds
			local avg_time = total_time / iterations

			print(string.format("Coordinate sanitization: %d iterations, %.2fms total, %.4fms avg", iterations, total_time, avg_time))
			assert.is_true(avg_time < 0.01, "Coordinate sanitization should be extremely fast (< 0.01ms per operation)")
		end)

		it("should benchmark extmark operations", function()
			local iterations = 1000

			local start_time = vim.uv.hrtime()

			local extmark_ids = {}
			for i = 1, iterations do
				local id = vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})
				table.insert(extmark_ids, id)
			end

			-- Clean up
			for _, id in ipairs(extmark_ids) do
				vim.api.nvim_buf_del_extmark(bufnr, ns, id)
			end

			local end_time = vim.uv.hrtime()
			local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds
			local avg_time = total_time / iterations

			print(string.format("Extmark operations: %d iterations, %.2fms total, %.4fms avg", iterations, total_time, avg_time))
			assert.is_true(avg_time < 0.1, "Extmark operations should be fast (< 0.1ms per operation)")
		end)
	end)

	describe("Memory and Resource Usage", function()
		it("should not leak highlight groups", function()
			local initial_hl_count = #vim.api.nvim_get_hl(0, {})

			for i = 1, 100 do
				local name = "TempHL" .. i
				highlight.set_highlight(name, { bg = "#FF0000" })
				vim.cmd("hi clear " .. name)
			end

			local final_hl_count = #vim.api.nvim_get_hl(0, {})
			assert.equals(initial_hl_count, final_hl_count, "Highlight groups should be cleaned up properly")
		end)

		it("should not leak extmarks", function()
			local initial_marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})

			for i = 1, 50 do
				local id = vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})
				vim.api.nvim_buf_del_extmark(bufnr, ns, id)
			end

			local final_marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
			assert.equals(#initial_marks, #final_marks, "Extmarks should be cleaned up properly")
		end)
	end)
end)