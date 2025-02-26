---@module 'luassert'

local utils = require("undo-glow.utils")
local spy = require("luassert.spy")

describe("undo-glow.utils", function()
	describe("get_unique_hlgroup", function()
		it(
			"should return a unique highlight group string based on a base",
			function()
				local base = "TestGroup"
				local hl1 = utils.get_unique_hlgroup(base)
				local hl2 = utils.get_unique_hlgroup(base)
				assert.is_string(hl1)
				assert.matches("^" .. base .. "_%d+$", hl1)
				assert.not_equal(hl1, hl2)
			end
		)
	end)

	describe("sanitize_coords", function()
		local buf = 1
		local lines = { "Hello", "World", "!" }

		before_each(function()
			vim.api.nvim_buf_line_count = function(bufnr)
				return #lines
			end
			vim.api.nvim_buf_get_lines = function(bufnr, start, stop, strict)
				local result = {}
				for i = start + 1, math.min(stop, #lines) do
					table.insert(result, lines[i])
				end
				return result
			end
		end)

		it("should return same coordinates if in range", function()
			local s_row, s_col, e_row, e_col =
				utils.sanitize_coords(buf, 1, 1, 1, 3)
			assert.equals(1, s_row)
			assert.equals(1, s_col)
			assert.equals(1, e_row)
			assert.equals(3, e_col)
		end)

		it("should clamp negative s_row and s_col", function()
			local s_row, s_col, e_row, e_col =
				utils.sanitize_coords(buf, -1, -5, 0, 10)
			-- For line "Hello" (length 5): s_row clamped to 0, s_col to 0, and e_col to 5.
			assert.equals(0, s_row)
			assert.equals(0, s_col)
			assert.equals(0, e_row)
			assert.equals(5, e_col)
		end)

		it("should clamp s_row and e_row to the line count", function()
			local s_row, s_col, e_row, e_col =
				utils.sanitize_coords(buf, 5, 2, 10, 10)
			-- With 3 lines, s_row and e_row should be clamped to 3 and the line retrieved is empty.
			assert.equals(3, s_row)
			assert.equals(0, s_col)
			assert.equals(3, e_row)
			assert.equals(0, e_col)
		end)
	end)

	describe("highlight_range", function()
		local buf = 1
		before_each(function()
			vim.api.nvim_buf_set_extmark = function(
				bufnr,
				ns,
				s_row,
				s_col,
				opts
			)
				return 42 -- Dummy extmark id.
			end
			vim.api.nvim_buf_line_count = function(bufnr)
				return 3
			end
			vim.api.nvim_buf_get_lines = function(bufnr, start, stop, strict)
				return { "Dummy" }
			end
		end)

		it("should call sanitize_coords and return an extmark id", function()
			local extmark_id = utils.highlight_range(buf, "TestHL", 0, 0, 0, 5)
			assert.equals(42, extmark_id)
		end)
	end)

	describe("handle_highlight", function()
		local opts
		before_each(function()
			opts = {
				bufnr = 1,
				s_row = 0,
				s_col = 0,
				e_row = 0,
				e_col = 5,
				state = {
					current_hlgroup = "TestHL",
					animation = { enabled = false },
				},
				config = {
					animation = {
						enabled = false,
						duration = 100,
						animation_type = "fade",
						easing = "linear",
						fps = 60,
					},
				},
			}
			vim.api.nvim_buf_is_valid = function(bufnr)
				return true
			end
			-- Spy on functions within the utils module.
			spy.on(utils, "highlight_range")
			spy.on(utils, "animate_or_clear_highlights")
		end)

		it(
			"should handle highlight by calling animate_or_clear_highlights",
			function()
				utils.handle_highlight(opts)
				assert.spy(utils.highlight_range).was_called()
				assert.spy(utils.animate_or_clear_highlights).was_called()
				assert.is_true(opts.state.should_detach)
			end
		)

		it("should do nothing if the buffer is not valid", function()
			vim.api.nvim_buf_is_valid = function(bufnr)
				return false
			end
			-- Removed spy.reset calls as they are not available.
			utils.handle_highlight(opts)
			assert.spy(utils.highlight_range).was_not_called()
			assert.spy(utils.animate_or_clear_highlights).was_not_called()
		end)
	end)

	describe("get_search_region", function()
		before_each(function()
			vim.api.nvim_get_current_buf = function()
				return 1
			end
			vim.api.nvim_win_get_cursor = function(win)
				return { 1, 3 }
			end
			vim.fn = vim.fn or {}
			vim.fn.getreg = function(reg)
				return "World"
			end
			vim.api.nvim_buf_get_lines = function(bufnr, start, stop, strict)
				return { "Hello World" }
			end
		end)

		it("should return a region that matches the search pattern", function()
			local region = utils.get_search_region()
			assert.is_table(region)
			-- "Hello World": "World" starts at character 7 (Lua's string.find returns 7,11)
			-- s_row is cursor row - 1 = 0; s_col = 7 - 1 = 6; e_col = 11.
			assert.equals(0, region.s_row)
			assert.equals(6, region.s_col)
			assert.equals(0, region.e_row)
			assert.equals(11, region.e_col)
		end)

		it("should return nil if search register is empty", function()
			vim.fn.getreg = function(reg)
				return ""
			end
			local region = utils.get_search_region()
			assert.is_nil(region)
		end)
	end)

	describe("get_search_star_region", function()
		before_each(function()
			vim.api.nvim_get_current_buf = function()
				return 1
			end
			vim.api.nvim_win_get_cursor = function(win)
				return { 1, 0 }
			end
			vim.fn = vim.fn or {}
			vim.fn.getreg = function(reg)
				return "Hello"
			end
			vim.api.nvim_buf_get_lines = function(bufnr, start, stop, strict)
				return { "Hello World" }
			end
			-- Stub vim.regex to simulate matching.
			vim.regex = function(pattern)
				return {
					match_str = function(line)
						return 0 -- simulate match at beginning (0-indexed)
					end,
				}
			end
			vim.fn.matchstr = function(line, pattern)
				return "Hello"
			end
		end)

		it("should return a region for search star", function()
			local region = utils.get_search_star_region()
			assert.is_table(region)
			-- Expect s_row=0, s_col=0, e_row=0, and e_col = 0 + length("Hello") = 5.
			assert.equals(0, region.s_row)
			assert.equals(0, region.s_col)
			assert.equals(0, region.e_row)
			assert.equals(5, region.e_col)
		end)

		it("should return nil if no match is found", function()
			vim.regex = function(pattern)
				return {
					match_str = function(line)
						return nil
					end,
				}
			end
			local region = utils.get_search_star_region()
			assert.is_nil(region)
		end)
	end)

	describe("animate_or_clear_highlights", function()
		local state, config
		before_each(function()
			state = {
				animation = {
					enabled = true,
					duration = 100,
					animation_type = "fade",
					easing = function(x)
						return x
					end,
					fps = 60,
				},
				should_detach = false,
			}

			state = require("undo-glow.utils").create_state(state)

			config = {} -- dummy config

			-- Stub color functions (already stubbed above, but ensuring they exist here)
			package.loaded["undo-glow.color"].get_normal_bg = function()
				return "#000000"
			end
			package.loaded["undo-glow.color"].get_normal_fg = function()
				return "#ffffff"
			end
			package.loaded["undo-glow.color"].hex_to_rgb = function(hex)
				return hex
			end

			-- Ensure vim.defer_fn calls the function immediately
			vim.defer_fn = function(fn, timeout)
				fn()
			end
			vim.api.nvim_buf_is_valid = function(bufnr)
				return true
			end
			vim.api.nvim_buf_del_extmark = function(bufnr, ns, extmark_id)
				return true
			end

			spy.on(vim, "defer_fn")
		end)

		it("should animate highlights when animation is enabled", function()
			state.animation.enabled = true
			local extmark_id = 123
			utils.animate_or_clear_highlights(
				1,
				state,
				"TestHL",
				extmark_id,
				"#aaaaaa",
				"#bbbbbb",
				config
			)
			-- The animation function in our stub marks the opts as called.
			assert.is_true(state.should_detach)
		end)

		it("should clear highlights when animation is disabled", function()
			state.animation.enabled = false
			local extmark_id = 123
			local del_extmark_spy = spy.on(vim.api, "nvim_buf_del_extmark")
			utils.animate_or_clear_highlights(
				1,
				state,
				"TestHL",
				extmark_id,
				"#aaaaaa",
				"#bbbbbb",
				config
			)
			assert.spy(vim.defer_fn).was_called()
			assert.spy(del_extmark_spy).was_called()
			assert.is_true(state.should_detach)
		end)
	end)

	describe("merge_command_opts", function()
		it("should merge command options with defaults", function()
			local opts = { animation = { enabled = true } }
			local result = utils.merge_command_opts("TestHL", opts)
			assert.equals("TestHL", result.hlgroup)
			assert.is_table(result.animation)
			-- The merged animation table should have the keys forced to nil.
			assert.equals(result.animation.enabled, true)
			assert.is_nil(result.animation.animation_type)
			assert.is_nil(result.animation.duration)
			assert.is_nil(result.animation.easing)
			assert.is_nil(result.animation.fps)
		end)
	end)

	describe("create_state", function()
		it("should create a state from given opts and config", function()
			local opts = {
				hlgroup = "CustomHL",
				animation = { enabled = true, duration = 200 },
			}
			local state = utils.create_state(opts)
			assert.equals("CustomHL", state.current_hlgroup)
			assert.equals(true, state.animation.enabled)
			assert.equals(200, state.animation.duration)
			-- animation_type falls back to config if not provided in opts.animation.
			-- assert.equals("blink", state.animation.animation_type)
		end)

		it("should substitute easing string to function", function()
			local opts = {
				hlgroup = "CustomHL",
				animation = {
					enabled = true,
					duration = 200,
					easing = "out_in_cubic",
				},
			}
			local state = utils.create_state(opts)
			assert.is_function(state.animation.easing)
		end)

		it("should substitute animation string to function", function()
			local opts = {
				hlgroup = "CustomHL",
				animation = {
					enabled = true,
					duration = 200,
					animation_type = "jitter",
				},
			}
			local state = utils.create_state(opts)
			assert.is_function(state.animation.animation_type)
		end)

		it("should set non configured to nil", function()
			local opts = {
				hlgroup = "CustomHL",
				animation = {},
			}
			local state = utils.create_state(opts)
			assert.is_nil(state.animation.enabled)
			assert.is_nil(state.animation.animation_type)
			assert.is_nil(state.animation.duration)
			assert.is_nil(state.animation.easing)
			assert.is_nil(state.animation.fps)
		end)
	end)

	describe("validate_state_for_highlight", function()
		it("should fill missing state animation values from config", function()
			local opts = {
				bufnr = 1,
				state = {
					current_hlgroup = "TestHL",
					animation = {
						enabled = nil,
						duration = nil,
						easing = nil,
						fps = nil,
					},
				},
				config = {
					animation = {
						enabled = true,
						duration = 150,
						easing = function(x)
							return x
						end,
						animation_type = "jitter",
						fps = 30,
					},
				},
			}
			local validated = utils.validate_state_for_highlight(opts)
			assert.equals(true, validated.state.animation.enabled)
			assert.equals(150, validated.state.animation.duration)
			assert.is_function(validated.state.animation.easing)
			assert.is_function(validated.state.animation.animation_type)
			assert.equals(30, validated.state.animation.fps)
		end)
	end)

	describe("get_easing", function()
		it("pass in function and should return function", function()
			local easing = utils.get_easing(function(opts)
				return 1
			end)

			assert.is_function(easing)
		end)

		it("pass in string and should return function", function()
			local easing = utils.get_easing("linear")

			assert.is_function(easing)
		end)

		it("any other opts will be nill", function()
			local easing_empty = utils.get_easing()
			local easing_wrong_string = utils.get_easing("hello")

			assert.is_nil(easing_empty)
			assert.is_nil(easing_wrong_string)
		end)
	end)

	describe("get_animation_type", function()
		it("pass in function and should return function", function()
			local animation_type = utils.get_animation_type(function(opts) end)

			assert.is_function(animation_type)
		end)

		it("pass in string and should return function", function()
			local animation_type = utils.get_animation_type("fade")

			assert.is_function(animation_type)
		end)

		it("any other opts will be nill", function()
			local animation_type_empty = utils.get_animation_type()
			local animation_type_wrong_string =
				utils.get_animation_type("hello")

			assert.is_nil(animation_type_empty)
			assert.is_nil(animation_type_wrong_string)
		end)
	end)
end)
