---@module 'luassert'

local highlight = require("undo-glow.highlight")

describe("undo-glow.highlight", function()
	describe("set_highlight", function()
		it("should create new highlight group when not exists", function()
			local name = "TestNewHL"
			local color = { bg = "#FF0000", fg = "#00FF00" }
			assert.equals(0, vim.fn.hlexists(name))
			highlight.set_highlight(name, color)
			assert.equals(1, vim.fn.hlexists(name))
			local hl = vim.api.nvim_get_hl(0, { name = name })
			assert.equals(
				color.bg:lower(),
				string.format("#%06x", hl.bg):lower()
			)
			assert.equals(
				color.fg:lower(),
				string.format("#%06x", hl.fg):lower()
			)
			vim.api.nvim_set_hl(0, name, {})
		end)

		it("should not modify existing highlight group", function()
			local name = "TestExistingHL"
			local initial_color = { bg = "#0000FF", fg = "#FFFFFF" }
			vim.api.nvim_set_hl(0, name, initial_color)
			highlight.set_highlight(name, { bg = "#FF0000", fg = "#00FF00" })
			local hl = vim.api.nvim_get_hl(0, { name = name })
			assert.equals(
				initial_color.bg:lower(),
				string.format("#%06x", hl.bg):lower()
			)
			assert.equals(
				initial_color.fg:lower(),
				string.format("#%06x", hl.fg):lower()
			)
			vim.api.nvim_set_hl(0, name, {})
		end)
	end)

	describe("link_highlight", function()
		it("should prioritize target group's colors", function()
			local from = "FromHL"
			local to = "ToHL"
			local to_color = { bg = "#123456", fg = "#654321" }
			vim.api.nvim_set_hl(0, to, to_color)
			highlight.link_highlight(
				from,
				to,
				{ bg = "#FF0000", fg = "#00FF00" }
			)
			local hl = vim.api.nvim_get_hl(0, { name = from })
			assert.equals(
				to_color.bg:lower(),
				string.format("#%06x", hl.bg):lower()
			)
			assert.equals(
				to_color.fg:lower(),
				string.format("#%06x", hl.fg):lower()
			)
			vim.api.nvim_set_hl(0, from, {})
			vim.api.nvim_set_hl(0, to, {})
		end)

		it("should use provided colors when target has none", function()
			local from = "FromHLNoColor"
			local to = "ToHLNoColor"
			vim.api.nvim_set_hl(0, to, { link = "NonExistentHL" })
			local color = { bg = "#112233", fg = "#445566" }
			highlight.link_highlight(from, to, color)
			local hl = vim.api.nvim_get_hl(0, { name = from })
			assert.equals(
				color.bg:lower(),
				string.format("#%06x", hl.bg):lower()
			)
			assert.equals(
				color.fg:lower(),
				string.format("#%06x", hl.fg):lower()
			)
			vim.api.nvim_set_hl(0, from, {})
			vim.api.nvim_set_hl(0, to, {})
		end)
	end)

	describe("setup_highlight", function()
		it("should link groups when different", function()
			local target = "TargetLink"
			local config_hl = "ConfigHL"
			vim.api.nvim_set_hl(
				0,
				config_hl,
				{ bg = "#000000", fg = "#FFFFFF" }
			)
			highlight.setup_highlight(
				target,
				config_hl,
				{ bg = "#123456", fg = "#654321" }
			)
			local target_hl = vim.api.nvim_get_hl(0, { name = target })
			local config_hl_attr = vim.api.nvim_get_hl(0, { name = config_hl })
			assert.equals(config_hl_attr.bg, target_hl.bg)
			assert.equals(config_hl_attr.fg, target_hl.fg)
			vim.api.nvim_set_hl(0, target, {})
			vim.api.nvim_set_hl(0, config_hl, {})
		end)

		it("should set directly when groups match", function()
			local target = "TargetDirect"
			local color = { bg = "#1A2B3C", fg = "#4D5E6F" }
			highlight.setup_highlight(target, target, color)
			local hl = vim.api.nvim_get_hl(0, { name = target })
			assert.equals(
				color.bg:lower(),
				string.format("#%06x", hl.bg):lower()
			)
			assert.equals(
				color.fg:lower(),
				string.format("#%06x", hl.fg):lower()
			)
			vim.api.nvim_set_hl(0, target, {})
		end)
	end)

	describe("resolve_hlgroup", function()
		it("should resolve single link chain", function()
			local base = "BaseHL"
			local linked = "LinkedHL"
			vim.api.nvim_set_hl(0, base, { bg = "#111111" })
			vim.api.nvim_set_hl(0, linked, { link = base })
			local resolved = highlight.resolve_hlgroup(linked)
			local base_hl = vim.api.nvim_get_hl(0, { name = base })
			assert.same(base_hl, resolved)
			vim.api.nvim_set_hl(0, base, {})
			vim.api.nvim_set_hl(0, linked, {})
		end)

		it("should resolve multi-link chain", function()
			local hl1 = "HL1"
			local hl2 = "HL2"
			local hl3 = "HL3"
			vim.api.nvim_set_hl(0, hl3, { fg = "#333333" })
			vim.api.nvim_set_hl(0, hl2, { link = hl3 })
			vim.api.nvim_set_hl(0, hl1, { link = hl2 })
			local resolved = highlight.resolve_hlgroup(hl1)
			local hl3_attr = vim.api.nvim_get_hl(0, { name = hl3 })
			assert.same(hl3_attr, resolved)
			vim.api.nvim_set_hl(0, hl1, {})
			vim.api.nvim_set_hl(0, hl2, {})
			vim.api.nvim_set_hl(0, hl3, {})
		end)

		it("should handle circular links safely", function()
			local hl_a = "HLCircularA"
			local hl_b = "HLCircularB"
			vim.api.nvim_set_hl(0, hl_a, { link = hl_b })
			vim.api.nvim_set_hl(0, hl_b, { link = hl_a })
			local resolved = highlight.resolve_hlgroup(hl_a)
			assert.same({}, resolved)
			vim.api.nvim_set_hl(0, hl_a, {})
			vim.api.nvim_set_hl(0, hl_b, {})
		end)
	end)
end)
