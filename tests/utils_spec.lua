---@module 'luassert'

local utils = require("undo-glow.utils")
local spy = require("luassert.spy")
local config = require("undo-glow.config")

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
		local bufnr

		before_each(function()
			bufnr = vim.api.nvim_create_buf(false, true) -- Create a new buffer for testing
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
				"Hello World!",
				"Another Hello World!",
				"No More!",
			})
		end)

		after_each(function()
			vim.api.nvim_buf_delete(bufnr, { force = true }) -- Clean up buffer
		end)
		it("should return same coordinates if in range", function()
			local s_row, s_col, e_row, e_col =
				utils.sanitize_coords(bufnr, 1, 1, 1, 3)
			assert.equals(1, s_row)
			assert.equals(1, s_col)
			assert.equals(1, e_row)
			assert.equals(3, e_col)
		end)

		it("should clamp negative s_row and s_col", function()
			local s_row, s_col, e_row, e_col =
				utils.sanitize_coords(bufnr, -1, -5, 0, 50)
			assert.equals(0, s_row)
			assert.equals(0, s_col)
		end)

		it("should clamp s_row and e_row to the line count", function()
			local s_row, s_col, e_row, e_col =
				utils.sanitize_coords(bufnr, 5, 5, 20, 20)
			assert.equals(3, s_row) -- Last valid row
			assert.equals(3, e_row) -- Last valid row
		end)

		it("should ensure e_row is not before s_row", function()
			local s_row, s_col, e_row, e_col =
				utils.sanitize_coords(bufnr, 2, 3, 1, 5)
			assert.are_equal(s_row >= e_row, true)
		end)

		it("should clamp e_col to the length of the line", function()
			local s_row, s_col, e_row, e_col =
				utils.sanitize_coords(bufnr, 1, 5, 1, 50)
			assert.equals(20, e_col) -- "Another Hello World!" length
		end)

		it("should clamp both start and end columns properly", function()
			local s_row, s_col, e_row, e_col =
				utils.sanitize_coords(bufnr, 1, -10, 1, 50)
			assert.equals(0, s_col)
			assert.equals(20, e_col) -- "Another Hello World!" length
		end)

		it("should work correctly for a single character line", function()
			vim.api.nvim_buf_set_lines(bufnr, 3, 4, false, { "X" })
			local s_row, s_col, e_row, e_col =
				utils.sanitize_coords(bufnr, 3, 5, 3, 10)
			assert.equals(3, s_row)
			assert.equals(1, s_col) -- Max valid column is 1
			assert.equals(3, e_row)
			assert.equals(1, e_col) -- Max valid column is 1
		end)

		it("should handle empty lines correctly", function()
			vim.api.nvim_buf_set_lines(bufnr, 1, 2, false, { "" }) -- Replace line 1 with empty line
			local s_row, s_col, e_row, e_col =
				utils.sanitize_coords(bufnr, 1, 5, 1, 10)
			assert.equals(1, s_row)
			assert.equals(0, s_col)
			assert.equals(1, e_row)
			assert.equals(0, e_col) -- Empty line has length 0
		end)
	end)

	-- describe("highlight_range", function()
	-- 	local bufnr
	--
	-- 	before_each(function()
	-- 		bufnr = vim.api.nvim_create_buf(false, true) -- Create a new buffer for testing
	-- 		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
	-- 			"This is a test line",
	-- 			"Another test line",
	-- 			"Yet another line",
	-- 		})
	-- 	end)
	--
	-- 	after_each(function()
	-- 		vim.api.nvim_buf_delete(bufnr, { force = true }) -- Clean up buffer
	-- 	end)
	--
	-- 	it("adds a highlight correctly", function()
	-- 		local hlgroup = "Visual"
	-- 		---@type UndoGlow.HandleHighlight
	-- 		local opts = {
	-- 			bufnr = bufnr,
	-- 			config = {
	-- 				priority = 4096,
	-- 			},
	-- 			state = {
	-- 				force_edge = false,
	-- 				should_detach = false,
	-- 				current_hlgroup = hlgroup,
	-- 			},
	-- 			s_row = 0,
	-- 			s_col = 5,
	-- 			e_row = 0,
	-- 			e_col = 10,
	-- 		}
	--
	-- 		local extmark_id = utils.highlight_range(opts, hlgroup)
	--
	-- 		local extmark = vim.api.nvim_buf_get_extmark_by_id(
	-- 			bufnr,
	-- 			utils.ns,
	-- 			extmark_id,
	-- 			{ details = true }
	-- 		)
	-- 		assert.equals(extmark[3].hl_group, hlgroup)
	-- 		assert.equals(extmark[3].end_row, opts.e_row)
	-- 		assert.equals(extmark[3].end_col, opts.e_col)
	-- 	end)
	--
	-- 	it("handles force_edge correctly", function()
	-- 		local hlgroup = "Visual"
	-- 		---@type UndoGlow.HandleHighlight
	-- 		local opts = {
	-- 			bufnr = bufnr,
	-- 			config = {
	-- 				priority = 4096,
	-- 			},
	-- 			state = {
	-- 				force_edge = true,
	-- 				should_detach = false,
	-- 				current_hlgroup = hlgroup,
	-- 			},
	-- 			s_row = 0,
	-- 			s_col = 5,
	-- 			e_row = 0,
	-- 			e_col = 10,
	-- 		}
	--
	-- 		local extmark_id = utils.highlight_range(opts, hlgroup)
	--
	-- 		local extmark = vim.api.nvim_buf_get_extmark_by_id(
	-- 			bufnr,
	-- 			utils.ns,
	-- 			extmark_id,
	-- 			{ details = true }
	-- 		)
	--
	-- 		assert.equals(extmark[3].hl_group, hlgroup)
	-- 		assert.equals(extmark[3].end_row, opts.e_row)
	-- 		assert.equals(extmark[3].end_col, opts.e_col)
	-- 		assert.not_nil(extmark[3].virt_text)
	-- 	end)
	-- end)

	describe("handle_highlight", function()
		local opts
		local bufnr
		before_each(function()
			bufnr = vim.api.nvim_create_buf(false, true) -- Create a new buffer for testing
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
				"This is a test line",
				"Another test line",
				"Yet another line",
			})

			opts = {
				bufnr = bufnr,
				s_row = 0,
				s_col = 5,
				e_row = 0,
				e_col = 10,
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
			-- Spy on functions within the utils module.
			spy.on(utils, "highlight_range")
			spy.on(utils, "animate_or_clear_highlights")
		end)

		after_each(function()
			vim.api.nvim_buf_delete(bufnr, { force = true }) -- Clean up buffer
		end)

		it(
			"should handle highlight by calling animate_or_clear_highlights",
			function()
				utils.handle_highlight(opts)
				assert.spy(utils.animate_or_clear_highlights).was_called()
				assert.is_true(opts.state.should_detach)
			end
		)

		it("should do nothing if the buffer is not valid", function()
			opts.bufnr = 999 -- set to a weird number
			utils.handle_highlight(opts)
			assert.spy(utils.animate_or_clear_highlights).was_not_called()
		end)
	end)

	describe("get_search_region", function()
		local bufnr

		before_each(function()
			bufnr = vim.api.nvim_create_buf(false, true) -- Create a new buffer for testing
			vim.api.nvim_set_current_buf(bufnr)
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
				"Hello World!",
				"Search for this pattern",
				"Another line of text",
			})
		end)

		after_each(function()
			vim.api.nvim_buf_delete(bufnr, { force = true }) -- Clean up buffer
		end)

		it("should return nil if no search pattern is set", function()
			vim.fn.setreg("/", "")
			local result = utils.get_search_region()
			assert.is_nil(result)
		end)

		it(
			"should return correct match region when cursor is inside a match",
			function()
				vim.fn.setreg("/", "Search")
				vim.api.nvim_win_set_cursor(0, { 2, 5 })
				local result = utils.get_search_region()
				assert.is_not_nil(result)
				assert.equals(1, result.s_row)
				assert.equals(0, result.s_col)
				assert.equals(1, result.e_row)
				assert.equals(6, result.e_col)
			end
		)

		it("should return first match if cursor is before any match", function()
			vim.fn.setreg("/", "Hello")
			vim.api.nvim_win_set_cursor(0, { 1, 1 })
			local result = utils.get_search_region()
			assert.is_not_nil(result)
			assert.equals(0, result.s_row)
			assert.equals(0, result.s_col)
			assert.equals(0, result.e_row)
			assert.equals(5, result.e_col)
		end)

		it("should return nil if no match is found", function()
			vim.fn.setreg("/", "Nonexistent")
			vim.api.nvim_win_set_cursor(0, { 2, 0 })
			local result = utils.get_search_region()
			assert.is_nil(result)
		end)
	end)

	describe("get_search_star_region", function()
		local bufnr

		before_each(function()
			bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(bufnr)
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
				"Hello World!",
				"Search for this pattern",
				"Another line of text",
			})
		end)

		after_each(function()
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end)

		it("should return nil if no search pattern is set", function()
			vim.fn.setreg("/", "")
			local result = utils.get_current_search_match_region()
			assert.is_nil(result)
		end)

		it(
			"should return correct match region when pattern is found",
			function()
				vim.fn.setreg("/", "pattern")
				vim.api.nvim_win_set_cursor(0, { 2, 10 })
				local result = utils.get_current_search_match_region()
				assert.is_not_nil(result)
				assert.equals(1, result.s_row)
				assert.equals(16, result.s_col)
				assert.equals(1, result.e_row)
				assert.equals(23, result.e_col)
			end
		)

		it(
			"should return correct match region when pattern is at the start",
			function()
				vim.fn.setreg("/", "Hello")
				vim.api.nvim_win_set_cursor(0, { 1, 0 })
				local result = utils.get_current_search_match_region()
				assert.is_not_nil(result)
				assert.equals(0, result.s_row)
				assert.equals(0, result.s_col)
				assert.equals(0, result.e_row)
				assert.equals(5, result.e_col)
			end
		)

		it("should return nil if no match is found", function()
			vim.fn.setreg("/", "NotFound")
			vim.api.nvim_win_set_cursor(0, { 2, 0 })
			local result = utils.get_current_search_match_region()
			assert.is_nil(result)
		end)
	end)

	describe("animate_or_clear_highlights", function()
		local opts, hlgroup, extmark_ids, start_bg, start_fg

		before_each(function()
			---@type UndoGlow.HandleHighlight
			opts = {
				bufnr = vim.api.nvim_create_buf(false, true),
				config = {
					priority = 4096,
				},
				state = {
					force_edge = false,
					should_detach = false,
					current_hlgroup = hlgroup,
					animation = {
						enabled = false,
						duration = 100,
						animation_type = function() end,
					},
				},
				s_row = 0,
				s_col = 5,
				e_row = 0,
				e_col = 10,
			}

			hlgroup = "TestHighlight"
			extmark_ids = { 1 }
			start_bg = "#ff0000"
			start_fg = "#ffffff"
		end)

		after_each(function()
			vim.api.nvim_buf_delete(opts.bufnr, { force = true })
		end)

		it(
			"should defer clearing highlight if animation is disabled",
			function()
				local spy = spy.new(function() end)
				vim.defer_fn = spy
				vim.api.nvim_buf_del_extmark = spy
				utils.animate_or_clear_highlights(
					opts,
					hlgroup,
					extmark_ids,
					start_bg,
					start_fg
				)
				assert.spy(vim.api.nvim_buf_del_extmark).was_called()
			end
		)

		it("should call animation function if enabled", function()
			opts.state.animation.enabled = true
			opts.state.animation.animation_type = spy.new(function() end)

			extmark_ids = {}

			utils.animate_or_clear_highlights(
				opts,
				hlgroup,
				extmark_ids,
				start_bg,
				start_fg
			)
			assert.spy(opts.state.animation.animation_type).was_called()
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
			assert.is_nil(result.force_edge)
		end)
		it(
			"should merge command options with defaults if opts is empty table",
			function()
				local opts = {}
				local result = utils.merge_command_opts("TestHL", opts)
				assert.equals("TestHL", result.hlgroup)
				assert.is_table(result.animation)
				-- The merged animation table should have the keys forced to nil.
				assert.is_nil(result.animation.enabled)
				assert.is_nil(result.animation.animation_type)
				assert.is_nil(result.animation.duration)
				assert.is_nil(result.animation.easing)
				assert.is_nil(result.animation.fps)
				assert.is_nil(result.force_edge)
			end
		)
		it("should merge command options with defaults if opts is 0", function()
			local opts = 0
			local result = utils.merge_command_opts("TestHL", opts)
			assert.equals("TestHL", result.hlgroup)
			assert.is_table(result.animation)
			-- The merged animation table should have the keys forced to nil.
			assert.is_nil(result.animation.enabled)
			assert.is_nil(result.animation.animation_type)
			assert.is_nil(result.animation.duration)
			assert.is_nil(result.animation.easing)
			assert.is_nil(result.animation.fps)
			assert.is_nil(result.force_edge)
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
		before_each(function()
			-- Inject a test configuration
			config.config = {
				animation = {
					enabled = true,
					duration = 150,
					easing = function(x)
						return x
					end,
					animation_type = "jitter",
					fps = 30,
					window_scoped = false,
				},
			}
		end)

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

	describe("create_namespace", function()
		local bufnr, current_win, other_win

		before_each(function()
			-- Create a new buffer and windows for testing.
			bufnr = vim.api.nvim_create_buf(false, true)
			-- Open the buffer in a new split to simulate a window.
			vim.cmd("split")
			current_win = vim.api.nvim_get_current_win()

			-- Create a second window and load the same buffer.
			vim.cmd("vsplit")
			other_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(other_win, bufnr)
		end)

		after_each(function()
			vim.api.nvim_buf_delete(bufnr, { force = true })
			vim.cmd("silent only")
			current_win = nil
			other_win = nil
		end)

		it("returns default namespace when window_scoped is false", function()
			local ns = utils.create_namespace(bufnr, false)
			assert.are.equal(utils.ns, ns)
		end)

		it(
			"creates and returns a window-scoped namespace when the current window shows the buffer",
			function()
				vim.api.nvim_set_current_win(current_win)
				vim.api.nvim_win_set_buf(current_win, bufnr)
				local ns = utils.create_namespace(bufnr, true)

				assert.is_number(ns)
				-- Validate that the namespace is stored in our module table.
				assert.is_truthy(utils.win_namespaces[current_win])
				assert.are.equal(utils.win_namespaces[current_win], ns)
			end
		)

		it(
			"returns nil when window_scoped is true and the current window does not show the buffer",
			function()
				local new_buf = vim.api.nvim_create_buf(false, true)

				vim.api.nvim_win_set_buf(current_win, bufnr)
				local ns = utils.create_namespace(new_buf, true)
				assert.is_nil(ns)
				vim.api.nvim_buf_delete(new_buf, { force = true })
			end
		)
	end)
end)
