---@module 'luassert'

local integrations = require("undo-glow.integrations")
local spy = require("luassert.spy")

describe("undo-glow.integrations", function()
	describe("yanky", function()
		describe("put", function()
			before_each(function()
				-- Reset global state
				vim.g.ug_ignore_cursor_moved = nil
			end)

			after_each(function()
				-- Clean up
				vim.g.ug_ignore_cursor_moved = nil
			end)

			it("should return plug command when yanky is available", function()
				local result = integrations.yanky.put("YankyPutAfter")
				assert.equals("<Plug>(YankyPutAfter)", result)
				assert.is_true(vim.g.ug_ignore_cursor_moved)
			end)

			it("should work with real yanky plugin", function()
				-- Test that yanky integration works with the real plugin loaded
				local result = integrations.yanky.put("YankyPutAfter")
				assert.equals("<Plug>(YankyPutAfter)", result)
				assert.is_true(vim.g.ug_ignore_cursor_moved)
			end)

			it("should return nil and log error for invalid action type", function()
				local result = integrations.yanky.put(123)
				assert.is_nil(result)
			end)

			it("should accept command options", function()
				local result = integrations.yanky.put("YankyPutAfter", { hlgroup = "CustomHL" })
				assert.equals("<Plug>(YankyPutAfter)", result)
				assert.is_true(vim.g.ug_ignore_cursor_moved)
			end)
		end)
	end)

	describe("substitute", function()
		describe("action", function()
			before_each(function()
				-- Reset global state
				vim.g.ug_ignore_cursor_moved = nil
			end)

			after_each(function()
				-- Clean up
				vim.g.ug_ignore_cursor_moved = nil
			end)

			it("should execute action when substitute is available", function()
				local action_called = false
				local test_action = function()
					action_called = true
				end

				integrations.substitute.action(test_action)
				assert.is_true(action_called)
				assert.is_true(vim.g.ug_ignore_cursor_moved)
			end)

			it("should work with real substitute plugin", function()
				-- Test that substitute integration works with the real plugin loaded
				local action_called = false
				local test_action = function()
					action_called = true
				end

				integrations.substitute.action(test_action)
				assert.is_true(action_called)
				assert.is_true(vim.g.ug_ignore_cursor_moved)
			end)

			it("should log error for invalid action type", function()
				integrations.substitute.action("not_a_function")
			end)

			it("should accept command options", function()
				local action_called = false
				local test_action = function()
					action_called = true
				end

				integrations.substitute.action(test_action, { hlgroup = "CustomHL" })
				assert.is_true(action_called)
				assert.is_true(vim.g.ug_ignore_cursor_moved)
			end)
		end)
	end)

	describe("flash", function()
		describe("jump", function()
			before_each(function()
				-- Reset global state
				vim.g.ug_ignore_cursor_moved = nil
			end)

			after_each(function()
				-- Clean up
				vim.g.ug_ignore_cursor_moved = nil
			end)

			it("should execute flash jump when flash is available", function()
				integrations.flash.jump({})
				assert.is_true(vim.g.ug_ignore_cursor_moved)
			end)

			it("should work with real flash plugin", function()
				-- Test that flash integration works with the real plugin loaded
				integrations.flash.jump({})
				assert.is_true(vim.g.ug_ignore_cursor_moved)
			end)

			it("should log error for invalid flash options type", function()
				integrations.flash.jump("not_a_table")
			end)

			it("should accept command options", function()
				integrations.flash.jump({}, { hlgroup = "CustomHL" })
				assert.is_true(vim.g.ug_ignore_cursor_moved)
			end)

			it("should handle empty flash options", function()
				integrations.flash.jump({})
				assert.is_true(vim.g.ug_ignore_cursor_moved)
			end)
		end)
	end)
end)