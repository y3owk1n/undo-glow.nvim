---@module 'luassert'

local M = require("undo-glow")

describe("undo-glow API", function()
	describe("setup", function()
		it("should setup with default configuration", function()
			local success = pcall(M.setup)
			assert.is_true(success)
		end)

		it("should setup with custom configuration", function()
			local config = {
				animation = {
					enabled = false,
					duration = 200,
				},
				highlights = {
					undo = {
						hl = "CustomUndo",
						hl_color = "#FF0000",
					},
				},
			}
			local success = pcall(M.setup, config)
			assert.is_true(success)
		end)

		it("should handle invalid configuration gracefully", function()
			local invalid_config = {
				animation = {
					duration = -100, -- Invalid
				},
			}
			local success = pcall(M.setup, invalid_config)
			assert.is_true(success) -- Should not crash
		end)
	end)

	describe("highlight_changes", function()
		local bufnr

		before_each(function()
			bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(bufnr)
		end)

		after_each(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_delete(bufnr, { force = true })
			end
		end)

		it("should highlight changes without options", function()
			local success = pcall(M.highlight_changes)
			assert.is_true(success)
		end)

		it("should highlight changes with custom options", function()
			local opts = {
				hlgroup = "CustomHL",
				animation = {
					duration = 100,
					enabled = false,
				},
			}
			local success = pcall(M.highlight_changes, opts)
			assert.is_true(success)
		end)

		it("should handle invalid options gracefully", function()
			local invalid_opts = {
				hlgroup = 123, -- Invalid type
			}
			local success = pcall(M.highlight_changes, invalid_opts)
			assert.is_true(success) -- Should not crash
		end)
	end)

	describe("highlight_region", function()
		local bufnr

		before_each(function()
			bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(bufnr)
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {"line 1", "line 2", "line 3"})
		end)

		after_each(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_delete(bufnr, { force = true })
			end
		end)

		it("should highlight a valid region", function()
			local opts = {
				s_row = 0,
				s_col = 0,
				e_row = 0,
				e_col = 5,
			}
			local success = pcall(M.highlight_region, opts)
			assert.is_true(success)
		end)

		it("should handle invalid coordinates gracefully", function()
			local invalid_opts = {
				s_row = -1, -- Invalid
				s_col = 0,
				e_row = 0,
				e_col = 5,
			}
			local success = pcall(M.highlight_region, invalid_opts)
			assert.is_true(success) -- Should not crash
		end)
	end)

	describe("command functions", function()
		it("should have undo command function", function()
			assert.is_function(M.undo)
		end)

		it("should have redo command function", function()
			assert.is_function(M.redo)
		end)

		it("should have yank command function", function()
			assert.is_function(M.yank)
		end)

		it("should have paste command functions", function()
			assert.is_function(M.paste_below)
			assert.is_function(M.paste_above)
		end)

		it("should have search command functions", function()
			assert.is_function(M.search_cmd)
			assert.is_function(M.search_next)
			assert.is_function(M.search_prev)
			assert.is_function(M.search_star)
			assert.is_function(M.search_hash)
		end)

		it("should have comment command functions", function()
			assert.is_function(M.comment)
			assert.is_function(M.comment_textobject)
			assert.is_function(M.comment_line)
		end)

		it("should have cursor moved function", function()
			assert.is_function(M.cursor_moved)
		end)
	end)
end)