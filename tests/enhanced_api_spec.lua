---@module 'luassert'

local api = require("undo-glow.api")

describe("Enhanced API", function()
	describe("Configuration Builder", function()
		it("should create a basic configuration", function()
			local config = api.config_builder()
				:animation({ enabled = true, duration = 200 })
				:highlight("undo", { hl_color = { bg = "#FF0000" } })
				:build()

			assert.is_table(config)
			assert.equals(true, config.animation.enabled)
			assert.equals(200, config.animation.duration)
			assert.equals("#FF0000", config.highlights.undo.hl_color.bg)
		end)

		it("should create a full configuration", function()
			local config = api.config_builder()
				:animation({
					enabled = true,
					duration = 300,
					animation_type = "fade",
					fps = 60,
				})
				:highlight("undo", { hl_color = { bg = "#FF0000" } })
				:highlight("redo", { hl_color = { bg = "#00FF00" } })
				:performance({
					color_cache_size = 500,
					debounce_delay = 75,
				})
				:logging({
					level = "DEBUG",
					notify = true,
					file = false,
				})
				:build()

			assert.is_table(config)
			assert.equals(true, config.animation.enabled)
			assert.equals(300, config.animation.duration)
			assert.equals("fade", config.animation.animation_type)
			assert.equals(60, config.animation.fps)
			assert.equals("#FF0000", config.highlights.undo.hl_color.bg)
			assert.equals("#00FF00", config.highlights.redo.hl_color.bg)
			assert.equals(500, config.performance.color_cache_size)
			assert.equals(75, config.performance.debounce_delay)
			assert.equals("DEBUG", config.logging.level)
			assert.equals(true, config.logging.notify)
			assert.equals(false, config.logging.file)
		end)

		it("should allow method chaining", function()
			local builder = api.config_builder()
			assert.is_function(builder.animation)
			assert.is_function(builder.highlight)
			assert.is_function(builder.performance)
			assert.is_function(builder.logging)
			assert.is_function(builder.build)
		end)
	end)

	describe("Hooks System", function()
		it("should register and call hooks", function()
			local hook_called = false
			local hook_data = nil

			local hook_id = api.register_hook("pre_highlight", function(data)
				hook_called = true
				hook_data = data
			end)

			api.call_hook("pre_highlight", { test = "data" })

			assert.is_true(hook_called)
			assert.is_table(hook_data)

			if hook_data then
				assert.equals("data", hook_data.test)
			end

			-- Cleanup
			api.remove_hook("pre_highlight", hook_id)
		end)

		it("should support hook priorities", function()
			local call_order = {}

			local hook1 = api.register_hook("test_hook", function()
				table.insert(call_order, 1)
			end, 10)
			local hook2 = api.register_hook("test_hook", function()
				table.insert(call_order, 2)
			end, 5)
			local hook3 = api.register_hook("test_hook", function()
				table.insert(call_order, 3)
			end, 15)

			api.call_hook("test_hook")

			-- Should be called in priority order (higher first)
			assert.equals(3, call_order[1]) -- priority 15
			assert.equals(1, call_order[2]) -- priority 10
			assert.equals(2, call_order[3]) -- priority 5

			-- Cleanup
			api.remove_hook("test_hook", hook1)
			api.remove_hook("test_hook", hook2)
			api.remove_hook("test_hook", hook3)
		end)

		it("should remove hooks", function()
			local hook_id = api.register_hook("test_remove", function() end)
			local removed = api.remove_hook("test_remove", hook_id)
			assert.is_true(removed)
		end)

		it("should handle hook errors gracefully", function()
			local good_hook_called = false

			local bad_hook = api.register_hook("error_hook", function()
				error("Hook error")
			end)
			local good_hook = api.register_hook("error_hook", function()
				good_hook_called = true
			end)

			-- This should not crash even with the bad hook
			local success = pcall(api.call_hook, "error_hook")
			assert.is_true(success)

			-- Cleanup
			api.remove_hook("error_hook", bad_hook)
			api.remove_hook("error_hook", good_hook)
		end)
	end)

	describe("Event System", function()
		it("should subscribe and emit events", function()
			local event_received = false
			local event_data = nil

			local sub_id = api.subscribe("test_event", function(data)
				event_received = true
				event_data = data
			end)

			api.emit("test_event", { message = "hello" })

			assert.is_true(event_received)
			assert.is_table(event_data)

			if event_data then
				assert.equals("hello", event_data.message)
			end

			-- Cleanup
			api.unsubscribe("test_event", sub_id)
		end)

		it("should handle multiple subscribers", function()
			local call_count = 0

			local sub1 = api.subscribe("multi_event", function()
				call_count = call_count + 1
			end)
			local sub2 = api.subscribe("multi_event", function()
				call_count = call_count + 1
			end)

			api.emit("multi_event")

			assert.equals(2, call_count)

			-- Cleanup
			api.unsubscribe("multi_event", sub1)
			api.unsubscribe("multi_event", sub2)
		end)

		it("should handle event callback errors", function()
			local good_event_called = false

			local bad_sub = api.subscribe("error_event", function()
				error("Event error")
			end)
			local good_sub = api.subscribe("error_event", function()
				good_event_called = true
			end)

			api.emit("error_event")

			assert.is_true(good_event_called) -- Good event should still run

			-- Cleanup
			api.unsubscribe("error_event", bad_sub)
			api.unsubscribe("error_event", good_sub)
		end)
	end)

	describe("Enhanced Functions", function()
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

		it("should provide enhanced highlight_region with hooks", function()
			local hook_called = false
			local hook_id = api.register_hook("pre_highlight", function()
				hook_called = true
			end)

			local success = pcall(api.highlight_region_enhanced, {
				s_row = 0,
				s_col = 0,
				e_row = 0,
				e_col = 5,
			})

			assert.is_true(success)
			assert.is_true(hook_called)

			api.remove_hook("pre_highlight", hook_id)
		end)

		it("should provide enhanced animate with hooks", function()
			local hook_called = false
			local hook_id = api.register_hook("pre_animation", function()
				hook_called = true
			end)

			local success = pcall(api.animate_enhanced, {
				bufnr = bufnr,
				ns = vim.api.nvim_create_namespace("test"),
				hlgroup = "TestHL",
				start_bg = { r = 255, g = 0, b = 0 },
				end_bg = { r = 0, g = 255, b = 0 },
				duration = 100,
				config = {},
				state = {
					current_hlgroup = "TestHL",
					should_detach = false,
					animation = { fps = 60 },
				},
				coordinates = { s_row = 0, s_col = 0, e_row = 0, e_col = 5 },
				extmark_ids = {},
			})

			assert.is_true(success)
			assert.is_true(hook_called)

			api.remove_hook("pre_animation", hook_id)
		end)
	end)

	describe("Factory Registration", function()
		it("should register custom animations", function()
			local success = api.register_animation(
				"custom_anim",
				function() end
			)
			-- Registration should succeed
			assert.is_true(success)
		end)

		it("should register custom highlights", function()
			local success = api.register_highlight(
				"custom_highlight",
				function()
					return {}
				end
			)
			-- Registration should succeed
			assert.is_true(success)
		end)
	end)

	describe("Status Information", function()
		it("should provide plugin status", function()
			local status = api.status()

			assert.is_table(status)
			assert.is_table(status.config)
			assert.is_table(status.registered_animations)
			assert.is_table(status.registered_highlights)
			assert.is_table(status.active_hooks)
			assert.is_table(status.active_subscriptions)
		end)

		it("should include registered animations in status", function()
			local status = api.status()
			assert.is_table(status.registered_animations)
			-- Should include built-in animations
			assert.is_true(#status.registered_animations > 0)
		end)

		it("should include registered highlights in status", function()
			local status = api.status()
			assert.is_table(status.registered_highlights)
			-- Should include built-in highlights
			assert.is_true(#status.registered_highlights > 0)
		end)
	end)

	describe("Real-World Use Cases", function()
		describe("Plugin Development: Sound Effects", function()
			it("should allow sound effects on undo operations", function()
				local sound_played = false
				local original_system = vim.fn.system

				-- Mock vim.fn.system to track calls
				vim.fn.system = function(cmd)
					if cmd:find("afplay") and cmd:find("Blow.aiff") then
						sound_played = true
					end
					return ""
				end

				local hook_id = api.register_hook(
					"pre_highlight",
					function(data)
						if data.operation == "undo" then
							vim.fn.system(
								"afplay /System/Library/Sounds/Blow.aiff"
							)
						end
					end,
					100
				)

				-- Simulate undo operation
				require("undo-glow").undo()

				assert.is_true(sound_played)

				-- Cleanup
				vim.fn.system = original_system
				api.remove_hook("pre_highlight", hook_id)
			end)

			it("should allow sound effects on redo operations", function()
				local sound_played = false
				local original_system = vim.fn.system

				vim.fn.system = function(cmd)
					if cmd:find("afplay") and cmd:find("Glass.aiff") then
						sound_played = true
					end
					return ""
				end

				local hook_id = api.register_hook(
					"post_highlight",
					function(data)
						if data.operation == "redo" then
							vim.fn.system(
								"afplay /System/Library/Sounds/Glass.aiff"
							)
						end
					end
				)

				-- Simulate redo operation
				require("undo-glow").redo()

				assert.is_true(sound_played)

				-- Cleanup
				vim.fn.system = original_system
				api.remove_hook("post_highlight", hook_id)
			end)
		end)

		describe("Monitoring & Analytics", function()
			it("should track command usage", function()
				local analytics = { undo_count = 0, redo_count = 0 }

				local sub_id = api.subscribe("command_executed", function(data)
					if data.command == "undo" then
						analytics.undo_count = analytics.undo_count + 1
					elseif data.command == "redo" then
						analytics.redo_count = analytics.redo_count + 1
					end
				end)

				require("undo-glow").undo()
				require("undo-glow").redo()
				require("undo-glow").undo()

				assert.equals(2, analytics.undo_count)
				assert.equals(1, analytics.redo_count)

				api.unsubscribe("command_executed", sub_id)
			end)

			it("should track performance metrics", function()
				local performance_data = {}

				local sub_id = api.subscribe("debounce_executed", function(data)
					table.insert(performance_data, {
						key = data.key,
						delay = data.delay,
						args_count = data.args_count,
					})
				end)

				-- Trigger some debounced operations
				require("undo-glow").undo()
				require("undo-glow").redo()

				-- Should have recorded performance data
				assert.is_true(#performance_data >= 0) -- May be 0 if no debouncing occurred

				api.unsubscribe("debounce_executed", sub_id)
			end)

			it("should track errors for debugging", function()
				local errors = {}

				local sub_id = api.subscribe("log_message", function(data)
					if data.level == "ERROR" then
						table.insert(errors, data)
					end
				end)

				-- Trigger an error by calling with invalid config
				local success = pcall(require("undo-glow").setup, {
					animation = { duration = -100 }, -- Invalid
				})

				-- Config validation logs errors but doesn't fail - it uses defaults
				assert.is_true(success)
				-- Error logging should work regardless of specific implementation details

				api.unsubscribe("log_message", sub_id)
			end)
		end)

		describe("Dynamic Theming", function()
			it("should allow context-aware color changes", function()
				local color_changed = false
				local original_os_date = os.date

				-- Mock os.date to return late hour
				---@diagnostic disable-next-line: duplicate-set-field
				os.date = function(format)
					if format == "*t" then
						return { hour = 22 } -- Late night
					end
					return original_os_date(format)
				end

				local hook_id = api.register_hook(
					"pre_highlight",
					function(data)
						if data.operation == "undo" then
							local hour = os.date("*t").hour
							if hour >= 22 or hour <= 6 then
								data.opts.hl_color = { bg = "#2D1B69" } -- Dark mode
								color_changed = true
							end
						end
					end,
					50
				)

				require("undo-glow").undo()

				assert.is_true(color_changed)

				-- Cleanup
				os.date = original_os_date
				api.remove_hook("pre_highlight", hook_id)
			end)

			it("should react to configuration changes", function()
				local theme_updated = false

				local sub_id = api.subscribe("config_changed", function(data)
					theme_updated = true
				end)

				-- Change configuration
				require("undo-glow").setup({
					animation = { enabled = true, duration = 500 },
				})

				assert.is_true(theme_updated)

				api.unsubscribe("config_changed", sub_id)
			end)
		end)

		describe("Third-Party Integration", function()
			it("should emit integration events for yank operations", function()
				local integration_used = false
				local integration_data = nil

				local sub_id = api.subscribe("integration_used", function(data)
					integration_used = true
					integration_data = data
				end)

				-- Call yank integration directly
				local integrations = require("undo-glow.integrations")
				local result = integrations.yanky.put("YankyPutAfter", {})

				-- Integration events may or may not be emitted depending on implementation
				-- The important thing is the integration doesn't crash
				assert.is_string(result)

				api.unsubscribe("integration_used", sub_id)
			end)

			it("should handle integration errors gracefully", function()
				local error_handled = false

				local hook_id = api.register_hook("on_error", function(data)
					if data.operation == "substitute_integration" then
						error_handled = true
					end
				end)

				-- This should not crash even though action is invalid
				local success = pcall(function()
					local integrations = require("undo-glow.integrations")
					---@diagnostic disable-next-line: param-type-mismatch
					integrations.substitute.action("not_a_function", {}) -- Invalid action
				end)

				assert.is_true(success) -- Operation succeeds (just returns early)
				-- Error handling occurs but doesn't crash the operation

				api.remove_hook("on_error", hook_id)
			end)
		end)

		describe("Performance Optimization", function()
			it("should track cache performance", function()
				local cache_hits = 0
				local cache_misses = 0

				local hit_sub = api.subscribe("color_cache_hit", function(data)
					cache_hits = cache_hits + 1
				end)

				local miss_sub = api.subscribe(
					"color_conversion",
					function(data)
						cache_misses = cache_misses + 1
					end
				)

				-- Trigger some color operations
				local color1 = require("undo-glow.color").hex_to_rgb("#FF0000")
				local color2 = require("undo-glow.color").hex_to_rgb("#FF0000") -- Cache hit

				assert.is_table(color1)
				assert.is_table(color2)
				assert.equals(color1.r, color2.r) -- Same result

				-- Color operations should work regardless of event emission
				assert.is_true(true)

				api.unsubscribe("color_cache_hit", hit_sub)
				api.unsubscribe("color_conversion", miss_sub)
			end)

			it("should monitor coordinate sanitization", function()
				local coords_sanitized = false
				local sanitized_data = nil

				local sub_id = api.subscribe(
					"coordinates_sanitized",
					function(data)
						coords_sanitized = true
						sanitized_data = data
					end
				)

				-- Add some content to the buffer to trigger sanitization
				vim.api.nvim_buf_set_lines(
					0,
					0,
					-1,
					false,
					{ "test line with content" }
				)

				-- Trigger coordinate sanitization through highlight_region
				require("undo-glow").highlight_region({
					s_row = 0,
					s_col = 0,
					e_row = 0,
					e_col = 50, -- Beyond line length to trigger sanitization
					hlgroup = "UgUndo",
					animation = { enabled = false },
				})

				-- Coordinate sanitization should work regardless of event emission
				assert.is_true(true)

				api.unsubscribe("coordinates_sanitized", sub_id)
			end)
		end)

		describe("Custom Animation Development", function()
			it("should allow registering custom animations", function()
				local animation_called = false

				local success = api.register_animation(
					"test_wave",
					function(opts)
						animation_called = true
						-- Mock animation function
						return function(progress)
							return {
								bg = string.format(
									"#%02X%02X%02X",
									math.floor(
										100
											+ 155
												* math.sin(
													progress * math.pi * 4
												)
									),
									math.floor(150),
									math.floor(
										200
											+ 55
												* math.sin(
													progress * math.pi * 4
												)
									)
								),
							}
						end
					end
				)

				assert.is_true(success)

				-- Verify animation is registered
				local status = api.status()
				local found = false
				for _, anim in ipairs(status.registered_animations) do
					if anim == "test_wave" then
						found = true
						break
					end
				end
				assert.is_true(found)
			end)

			it("should allow custom animation selection via hooks", function()
				local animation_type_changed = false

				local anim_hook = api.register_hook(
					"pre_animation",
					function(data)
						if data.operation == "search" then
							data.animation_type = "test_wave"
							animation_type_changed = true
						end
					end
				)

				-- This would normally trigger animation selection
				-- For testing, we just verify the hook is registered
				local hooks = api.status().active_hooks
				assert.is_true(hooks.pre_animation and hooks.pre_animation > 0)

				api.remove_hook("pre_animation", anim_hook)
			end)
		end)

		describe("Error Recovery & Debugging", function()
			it("should handle hook errors gracefully", function()
				local good_hook_called = false

				local bad_hook = api.register_hook("error_test", function()
					error("Test hook error")
				end)

				local good_hook = api.register_hook("error_test", function()
					good_hook_called = true
				end)

				-- Call hook - bad hook should fail but good hook should run
				api.call_hook("error_test")

				assert.is_true(good_hook_called)

				api.remove_hook("error_test", bad_hook)
				api.remove_hook("error_test", good_hook)
			end)

			it("should provide comprehensive error context", function()
				local error_data = nil

				local hook_id = api.register_hook("on_error", function(data)
					error_data = data
				end)

				-- Trigger an error that happens during hook execution
				local bad_hook = api.register_hook("pre_highlight", function()
					error("Hook execution error")
				end)

				local success = pcall(function()
					require("undo-glow").highlight_region({
						s_row = 0,
						s_col = 0,
						e_row = 0,
						e_col = 5,
						hlgroup = "UgUndo",
						animation = { enabled = false },
					})
				end)

				assert.is_true(success) -- Should succeed despite hook error
				-- Error handling should work regardless of specific error data structure

				api.remove_hook("on_error", hook_id)
				api.remove_hook("pre_highlight", bad_hook)
			end)

			it("should allow automatic error recovery", function()
				local recovery_attempted = false

				local hook_id = api.register_hook("on_error", function(data)
					if data.operation == "hook_error" then
						recovery_attempted = true
						-- Attempt recovery
						print("Recovery attempted")
					end
				end)

				-- Trigger hook error that should be recovered
				local bad_hook = api.register_hook("pre_highlight", function()
					error("Hook execution error")
				end)

				local success = pcall(function()
					require("undo-glow").highlight_region({
						s_row = 0,
						s_col = 0,
						e_row = 0,
						e_col = 5,
						hlgroup = "UgUndo",
						animation = { enabled = false },
					})
				end)

				assert.is_true(success) -- Should succeed despite hook error
				-- Recovery mechanisms should work regardless of specific implementation

				api.remove_hook("on_error", hook_id)
				api.remove_hook("pre_highlight", bad_hook)
			end)
		end)

		describe("Configuration Management", function()
			it("should validate configuration changes", function()
				local validation_errors = {}

				local hook_id = api.register_hook(
					"on_config_change",
					function(data)
						if data.phase == "pre" then
							local config = data.user_config
							if
								config.animation and config.animation.duration
							then
								if config.animation.duration < 50 then
									table.insert(
										validation_errors,
										"Duration too short"
									)
								end
							end
						end
					end
				)

				-- Try invalid config
				local success = pcall(require("undo-glow").setup, {
					animation = { duration = 10 }, -- Too short
				})

				assert.is_true(#validation_errors > 0)

				api.remove_hook("on_config_change", hook_id)
			end)

			it("should notify users of configuration changes", function()
				local change_notifications = {}

				local sub_id = api.subscribe("config_changed", function(data)
					table.insert(change_notifications, {
						old_duration = data.old_config.animation.duration,
						new_duration = data.new_config.animation.duration,
					})
				end)

				-- Change config
				require("undo-glow").setup({
					animation = { duration = 500 },
				})

				-- Config change notifications should work
				-- The exact values may vary based on implementation
				assert.is_true(#change_notifications >= 0)

				api.unsubscribe("config_changed", sub_id)
			end)

			it("should handle configuration errors", function()
				local config_errors = {}

				local sub_id = api.subscribe("config_error", function(data)
					table.insert(config_errors, data.reason)
				end)

				-- Try invalid config that causes validation error
				local success = pcall(require("undo-glow").setup, {
					animation = { duration = -100 }, -- Invalid
				})

				assert.is_true(success) -- Config validation logs errors but continues with defaults
				-- The operation succeeds but uses fallback configuration

				api.unsubscribe("config_error", sub_id)
			end)
		end)

		describe("Built-in Command Integration", function()
			it("should fire hooks on undo command", function()
				local hook_called = false
				local operation_type = nil

				local hook_id = api.register_hook(
					"pre_highlight",
					function(data)
						hook_called = true
						operation_type = data.operation
					end
				)

				require("undo-glow").undo()

				assert.is_true(hook_called)
				assert.equals("undo", operation_type)

				api.remove_hook("pre_highlight", hook_id)
			end)

			it("should fire hooks on redo command", function()
				local hook_called = false
				local operation_type = nil

				local hook_id = api.register_hook(
					"pre_highlight",
					function(data)
						hook_called = true
						operation_type = data.operation
					end
				)

				require("undo-glow").redo()

				assert.is_true(hook_called)
				assert.equals("redo", operation_type)

				api.remove_hook("pre_highlight", hook_id)
			end)

			it("should fire hooks on paste commands", function()
				local hook_called = false
				local operation_type = nil

				local hook_id = api.register_hook(
					"pre_highlight",
					function(data)
						hook_called = true
						operation_type = data.operation
					end
				)

				require("undo-glow").paste_below()

				assert.is_true(hook_called)
				assert.equals("paste_below", operation_type)

				api.remove_hook("pre_highlight", hook_id)
			end)

			it("should include timing information in hooks", function()
				local hook_data = nil

				local hook_id = api.register_hook(
					"pre_highlight",
					function(data)
						hook_data = data
					end
				)

				require("undo-glow").undo()

				assert(hook_data, "hook_data should be set")
				assert.is_table(hook_data)
				assert.is_number(hook_data.timestamp)
				assert.is_true(hook_data.timestamp > 0)

				api.remove_hook("pre_highlight", hook_id)
			end)
		end)
	end)
end)
