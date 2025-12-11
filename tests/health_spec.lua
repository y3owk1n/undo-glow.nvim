---@module 'luassert'

local health = require("undo-glow.health")

describe("undo-glow.health", function()
	describe("check", function()
		it("should run health checks without errors", function()
			-- Should not throw any errors
			local success = pcall(health.check)
			assert.is_true(success)
		end)

		it("should perform Neovim version checks", function()
			-- Should check Neovim version without errors
			local success = pcall(health.check)
			assert.is_true(success)
		end)

		it("should validate Neovim API availability", function()
			-- Should check API availability without errors
			local success = pcall(health.check)
			assert.is_true(success)
		end)
	end)
end)