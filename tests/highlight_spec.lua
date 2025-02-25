---@module 'luassert'

local hl = require("undo-glow.highlight")
local spy = require("luassert.spy")

describe("undo-glow.highlight", function()
	local original_hlexists, original_nvim_set_hl, original_get_hl

	before_each(function()
		-- Backup original functions
		original_hlexists = vim.fn.hlexists
		original_nvim_set_hl = vim.api.nvim_set_hl
		original_get_hl = vim.api.nvim_get_hl
	end)

	after_each(function()
		-- Restore original functions
		vim.fn.hlexists = original_hlexists
		vim.api.nvim_set_hl = original_nvim_set_hl
		vim.api.nvim_get_hl = original_get_hl
	end)

	describe("set_highlight", function()
		it("should call nvim_set_hl if highlight does not exist", function()
			vim.fn.hlexists = function(name)
				return 0
			end
			local spy_set = spy.new(function(ns, name, color) end)
			vim.api.nvim_set_hl = spy_set

			hl.set_highlight("TestHL", { bg = "#123456", fg = "#654321" })
			assert
				.spy(spy_set)
				.was_called_with(0, "TestHL", { bg = "#123456", fg = "#654321" })
		end)

		it("should not call nvim_set_hl if highlight exists", function()
			vim.fn.hlexists = function(name)
				return 1
			end
			local spy_set = spy.new(function(ns, name, color) end)
			vim.api.nvim_set_hl = spy_set

			hl.set_highlight("TestHL", { bg = "#123456", fg = "#654321" })
			assert.spy(spy_set).was_not_called()
		end)
	end)

	describe("link_highlight", function()
		it("should use formatted bg/fg from target if available", function()
			-- Stub vim.api.nvim_get_hl to return numeric values for bg and fg.
			vim.api.nvim_get_hl = function(ns, opts)
				if opts.name == "TargetHL" then
					return { bg = 0x112233, fg = 0x445566 }
				end
				return {}
			end

			-- Replace set_highlight with a spy.
			local spy_set_highlight = spy.new(function(name, color) end)
			hl.set_highlight = spy_set_highlight

			hl.link_highlight(
				"FromHL",
				"TargetHL",
				{ bg = "#FF0000", fg = "#00FF00" }
			)
			assert
				.spy(spy_set_highlight)
				.was_called_with("FromHL", { bg = "#112233", fg = "#445566" })
		end)

		it("should use provided color if target has no bg/fg", function()
			vim.api.nvim_get_hl = function(ns, opts)
				return {} -- No bg or fg fields.
			end

			local spy_set_highlight = spy.new(function(name, color) end)
			hl.set_highlight = spy_set_highlight

			hl.link_highlight(
				"FromHL",
				"TargetHL",
				{ bg = "#FF0000", fg = "#00FF00" }
			)
			assert
				.spy(spy_set_highlight)
				.was_called_with("FromHL", { bg = "#FF0000", fg = "#00FF00" })
		end)
	end)

	describe("setup_highlight", function()
		it(
			"should call link_highlight when config_hl differs from target_hlgroup",
			function()
				local spy_link = spy.new(function(from, to, color) end)
				local spy_set = spy.new(function(name, color) end)
				hl.link_highlight = spy_link
				hl.set_highlight = spy_set

				hl.setup_highlight(
					"TargetHL",
					"ConfigHL",
					{ bg = "#AAAAAA", fg = "#BBBBBB" }
				)
				assert
					.spy(spy_link)
					.was_called_with("TargetHL", "ConfigHL", { bg = "#AAAAAA", fg = "#BBBBBB" })
				assert.spy(spy_set).was_not_called()
			end
		)

		it(
			"should call set_highlight when config_hl equals target_hlgroup",
			function()
				local spy_link = spy.new(function(from, to, color) end)
				local spy_set = spy.new(function(name, color) end)
				hl.link_highlight = spy_link
				hl.set_highlight = spy_set

				hl.setup_highlight(
					"SameHL",
					"SameHL",
					{ bg = "#CCCCCC", fg = "#DDDDDD" }
				)
				assert
					.spy(spy_set)
					.was_called_with("SameHL", { bg = "#CCCCCC", fg = "#DDDDDD" })
				assert.spy(spy_link).was_not_called()
			end
		)
	end)

	describe("resolve_hlgroup", function()
		it("should follow links until a non-linked hl is found", function()
			local call_count = 0
			vim.api.nvim_get_hl = function(ns, opts)
				call_count = call_count + 1
				if opts.name == "A" then
					return { link = "B" }
				elseif opts.name == "B" then
					return { bg = 0x123456 }
				end
				return {}
			end

			local res = hl.resolve_hlgroup("A")
			assert.are.same({ bg = 0x123456 }, res)
			assert.equals(2, call_count)
		end)

		it("should break on cycles and return empty table", function()
			vim.api.nvim_get_hl = function(ns, opts)
				if opts.name == "A" then
					return { link = "B" }
				elseif opts.name == "B" then
					return { link = "A" }
				end
				return {}
			end

			local res = hl.resolve_hlgroup("A")
			assert.are.same({}, res)
		end)
	end)
end)
