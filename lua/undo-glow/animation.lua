local M = {}

M.animate = {}

---Function to clear the animation when complete
---@param opts UndoGlow.Animation The animation options.
---@param timer uv.uv_timer_t The timer instance used for animation.
---@return nil
function M.animate_clear(opts, timer)
	timer:stop()
	if not vim.uv.is_closing(timer) then
		timer:close()
	end
	if vim.api.nvim_buf_is_valid(opts.bufnr) and opts.extmark_ids then
		local ids = opts.extmark_ids
		if not vim.islist(ids) then
			local list = {}
			for _, id in pairs(ids) do
				table.insert(list, id)
			end
			ids = list
		end

		for _, id in ipairs(ids) do
			pcall(vim.api.nvim_buf_del_extmark, opts.bufnr, opts.ns, id)
		end
	end
	vim.cmd("hi clear " .. opts.hlgroup)
end

---Starts an animation.
---Repeatedly calls the provided animation function with a progress value between 0 and 1 until the animation completes.
---@param opts UndoGlow.Animation The animation options.
---@param animate_fn fun(progress: number, end_animation: function): UndoGlow.HlColor|nil A function that receives the current progress (0 = start, 1 = end) and return the hl colors or nothing.
---@return nil
function M.animate_start(opts, animate_fn)
	local start_time = vim.uv.hrtime()
	local interval = 1000 / opts.state.animation.fps
	local timer = vim.uv.new_timer()
	local last_hl_opts = nil -- Track last highlight options to avoid unnecessary redraws

	if timer then
		timer:start(
			0,
			interval,
			vim.schedule_wrap(function()
				local success, err = pcall(function()
					local now = vim.uv.hrtime()
					local elapsed = (now - start_time) / 1e6 -- convert from ns to ms

					local progress =
						math.max(0, math.min(1, elapsed / opts.duration))

					local animation_ended = false

					if progress >= 1 and not animation_ended then
						M.animate_clear(opts, timer)
						animation_ended = true
						return
					end

					local hl_opts = animate_fn(progress, function()
						M.animate_clear(opts, timer)
						animation_ended = true
					end)

					-- Only update highlight if it has actually changed to avoid unnecessary redraws
					if
						hl_opts and not vim.deep_equal(hl_opts, last_hl_opts)
					then
						vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
						last_hl_opts = vim.deepcopy(hl_opts)
					end
				end)

				if not success then
					require("undo-glow.log").error(
						"Animation error: " .. tostring(err)
					)
					timer:stop()
					if not vim.uv.is_closing(timer) then
						timer:close()
					end
					vim.cmd("hi clear " .. opts.hlgroup)
				end
			end)
		)
	end
end

---Fades out a highlight group from a start color to the normal background.
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.fade(opts)
	local extmark_opts = require("undo-glow.utils").create_extmark_opts({
		bufnr = opts.bufnr,
		hlgroup = opts.hlgroup,
		s_row = opts.coordinates.s_row,
		s_col = opts.coordinates.s_col,
		e_row = opts.coordinates.e_row,
		e_col = opts.coordinates.e_col,
		priority = require("undo-glow.config").config.priority,
		force_edge = opts.state.force_edge,
		window_scoped = opts.state.animation.window_scoped,
	})

	local extmark_id = vim.api.nvim_buf_set_extmark(
		opts.bufnr,
		opts.ns,
		opts.coordinates.s_row,
		opts.coordinates.s_col,
		extmark_opts
	)

	table.insert(opts.extmark_ids, extmark_id)

	M.animate_start(opts, function(progress)
		local eased = opts.state.animation.easing({
			time = progress,
			begin = 0,
			change = 1,
			duration = 1,
		})

		return {
			bg = require("undo-glow.color").blend_color(
				opts.start_bg,
				opts.end_bg,
				eased
			),
			fg = (opts.start_fg and opts.end_fg)
					and require("undo-glow.color").blend_color(
						opts.start_fg,
						opts.end_fg,
						eased
					)
				or nil,
		}
	end)
end

---Fades in a highlight group from the normal background to the start color.
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.fade_reverse(opts)
	local extmark_opts = require("undo-glow.utils").create_extmark_opts({
		bufnr = opts.bufnr,
		hlgroup = opts.hlgroup,
		s_row = opts.coordinates.s_row,
		s_col = opts.coordinates.s_col,
		e_row = opts.coordinates.e_row,
		e_col = opts.coordinates.e_col,
		priority = require("undo-glow.config").config.priority,
		force_edge = opts.state.force_edge,
		window_scoped = opts.state.animation.window_scoped,
	})

	local extmark_id = vim.api.nvim_buf_set_extmark(
		opts.bufnr,
		opts.ns,
		opts.coordinates.s_row,
		opts.coordinates.s_col,
		extmark_opts
	)

	table.insert(opts.extmark_ids, extmark_id)

	M.animate_start(opts, function(progress)
		local eased = opts.state.animation.easing({
			time = progress,
			begin = 0,
			change = 1,
			duration = 1,
		})
		return {
			bg = require("undo-glow.color").blend_color(
				opts.end_bg, -- starting with normal background
				opts.start_bg, -- blending toward the original highlight color
				eased
			),
			fg = (opts.start_fg and opts.end_fg)
					and require("undo-glow.color").blend_color(
						opts.end_fg,
						opts.start_fg,
						eased
					)
				or nil,
		}
	end)
end

---Blinks a highlight group by alternating between the start and end colors.
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.blink(opts)
	local extmark_opts = require("undo-glow.utils").create_extmark_opts({
		bufnr = opts.bufnr,
		hlgroup = opts.hlgroup,
		s_row = opts.coordinates.s_row,
		s_col = opts.coordinates.s_col,
		e_row = opts.coordinates.e_row,
		e_col = opts.coordinates.e_col,
		priority = require("undo-glow.config").config.priority,
		force_edge = opts.state.force_edge,
		window_scoped = opts.state.animation.window_scoped,
	})

	local extmark_id = vim.api.nvim_buf_set_extmark(
		opts.bufnr,
		opts.ns,
		opts.coordinates.s_row,
		opts.coordinates.s_col,
		extmark_opts
	)

	table.insert(opts.extmark_ids, extmark_id)

	M.animate_start(opts, function(progress)
		local blink_period = 200
		local phase = (progress * opts.duration % blink_period)
			< (blink_period / 2)

		if phase then
			return {
				bg = require("undo-glow.color").rgb_to_hex(opts.start_bg),
				fg = opts.start_fg and require("undo-glow.color").rgb_to_hex(
					opts.start_fg
				) or nil,
			}
		else
			return {
				bg = require("undo-glow.color").rgb_to_hex(opts.end_bg),
				fg = opts.end_fg and require("undo-glow.color").rgb_to_hex(
					opts.end_fg
				) or nil,
			}
		end
	end)
end

---Applies a jitter effect to a highlight group by randomly altering the colors.
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.jitter(opts)
	local extmark_opts = require("undo-glow.utils").create_extmark_opts({
		bufnr = opts.bufnr,
		hlgroup = opts.hlgroup,
		s_row = opts.coordinates.s_row,
		s_col = opts.coordinates.s_col,
		e_row = opts.coordinates.e_row,
		e_col = opts.coordinates.e_col,
		priority = require("undo-glow.config").config.priority,
		force_edge = opts.state.force_edge,
		window_scoped = opts.state.animation.window_scoped,
	})

	local extmark_id = vim.api.nvim_buf_set_extmark(
		opts.bufnr,
		opts.ns,
		opts.coordinates.s_row,
		opts.coordinates.s_col,
		extmark_opts
	)

	table.insert(opts.extmark_ids, extmark_id)

	M.animate_start(opts, function(_)
		---@param rgb UndoGlow.RGBColor
		---@return string hex
		local function jitter_color(rgb)
			local function clamp(val)
				return math.max(0, math.min(255, val))
			end

			local converted_rgb = {
				r = clamp(rgb.r + math.random(-30, 30)),
				g = clamp(rgb.g + math.random(-30, 30)),
				b = clamp(rgb.b + math.random(-30, 30)),
			}

			return require("undo-glow.color").rgb_to_hex(converted_rgb)
		end

		return {
			bg = jitter_color(opts.start_bg),
			fg = opts.start_fg and jitter_color(opts.start_fg) or nil,
		}
	end)
end

---Pulses a highlight group by rhythmically blending the start and end colors.
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.pulse(opts)
	local extmark_opts = require("undo-glow.utils").create_extmark_opts({
		bufnr = opts.bufnr,
		hlgroup = opts.hlgroup,
		s_row = opts.coordinates.s_row,
		s_col = opts.coordinates.s_col,
		e_row = opts.coordinates.e_row,
		e_col = opts.coordinates.e_col,
		priority = require("undo-glow.config").config.priority,
		force_edge = opts.state.force_edge,
		window_scoped = opts.state.animation.window_scoped,
	})

	local extmark_id = vim.api.nvim_buf_set_extmark(
		opts.bufnr,
		opts.ns,
		opts.coordinates.s_row,
		opts.coordinates.s_col,
		extmark_opts
	)

	table.insert(opts.extmark_ids, extmark_id)

	M.animate_start(opts, function(progress)
		local systolic_duration = 0.5

		local t = 0

		if progress < systolic_duration then
			t = (progress / systolic_duration) ^ 2.0
		else
			t = 1
				- ((progress - systolic_duration) / (1 - systolic_duration))
					^ 0.5
		end

		return {
			bg = require("undo-glow.color").blend_color(
				opts.start_bg,
				opts.end_bg,
				t
			),
			fg = opts.start_fg
					and opts.end_fg
					and require("undo-glow.color").blend_color(
						opts.start_fg,
						opts.end_fg,
						t
					)
				or nil,
		}
	end)
end

---Applies a spring effect that overshoots the target color before settling.
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.spring(opts)
	local extmark_opts = require("undo-glow.utils").create_extmark_opts({
		bufnr = opts.bufnr,
		hlgroup = opts.hlgroup,
		s_row = opts.coordinates.s_row,
		s_col = opts.coordinates.s_col,
		e_row = opts.coordinates.e_row,
		e_col = opts.coordinates.e_col,
		priority = require("undo-glow.config").config.priority,
		force_edge = opts.state.force_edge,
		window_scoped = opts.state.animation.window_scoped,
	})

	local extmark_id = vim.api.nvim_buf_set_extmark(
		opts.bufnr,
		opts.ns,
		opts.coordinates.s_row,
		opts.coordinates.s_col,
		extmark_opts
	)

	table.insert(opts.extmark_ids, extmark_id)

	M.animate_start(opts, function(progress)
		local t = math.sin(
			progress * math.pi * (0.2 + 2.5 * progress * progress * progress)
		) * (1 - progress) + progress

		return {
			bg = require("undo-glow.color").blend_color(
				opts.start_bg,
				opts.end_bg,
				t
			),
			fg = opts.start_fg
					and opts.end_fg
					and require("undo-glow.color").blend_color(
						opts.start_fg,
						opts.end_fg,
						t
					)
				or nil,
		}
	end)
end

---Gradually desaturates the highlight color.
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.desaturate(opts)
	local extmark_opts = require("undo-glow.utils").create_extmark_opts({
		bufnr = opts.bufnr,
		hlgroup = opts.hlgroup,
		s_row = opts.coordinates.s_row,
		s_col = opts.coordinates.s_col,
		e_row = opts.coordinates.e_row,
		e_col = opts.coordinates.e_col,
		priority = require("undo-glow.config").config.priority,
		force_edge = opts.state.force_edge,
		window_scoped = opts.state.animation.window_scoped,
	})

	local extmark_id = vim.api.nvim_buf_set_extmark(
		opts.bufnr,
		opts.ns,
		opts.coordinates.s_row,
		opts.coordinates.s_col,
		extmark_opts
	)

	table.insert(opts.extmark_ids, extmark_id)

	M.animate_start(opts, function(progress)
		---@param rgb UndoGlow.RGBColor
		---@return string hex
		local function desaturate(rgb)
			local hsl = require("undo-glow.color").rgb_to_hsl(rgb)
			hsl.s = hsl.s * (1 - progress) -- reduce saturation over time
			local desaturated_rgb = require("undo-glow.color").hsl_to_rgb(hsl)
			return require("undo-glow.color").rgb_to_hex(desaturated_rgb)
		end

		return {
			bg = desaturate(opts.start_bg),
			fg = opts.start_fg and opts.end_fg and desaturate(opts.start_fg)
				or nil,
		}
	end)
end

---Applies a strobe effect by rapidly toggling between the start and end colors.
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.strobe(opts)
	local extmark_opts = require("undo-glow.utils").create_extmark_opts({
		bufnr = opts.bufnr,
		hlgroup = opts.hlgroup,
		s_row = opts.coordinates.s_row,
		s_col = opts.coordinates.s_col,
		e_row = opts.coordinates.e_row,
		e_col = opts.coordinates.e_col,
		priority = require("undo-glow.config").config.priority,
		force_edge = opts.state.force_edge,
		window_scoped = opts.state.animation.window_scoped,
	})

	local extmark_id = vim.api.nvim_buf_set_extmark(
		opts.bufnr,
		opts.ns,
		opts.coordinates.s_row,
		opts.coordinates.s_col,
		extmark_opts
	)

	table.insert(opts.extmark_ids, extmark_id)

	M.animate_start(opts, function(progress)
		local use_start = math.floor(progress * 10) % 2 == 0
		if use_start then
			return {
				bg = require("undo-glow.color").rgb_to_hex(opts.start_bg),
				fg = opts.start_fg and require("undo-glow.color").rgb_to_hex(
					opts.start_fg
				) or nil,
			}
		else
			return {
				bg = require("undo-glow.color").rgb_to_hex(opts.end_bg),
				fg = opts.end_fg and require("undo-glow.color").rgb_to_hex(
					opts.end_fg
				) or nil,
			}
		end
	end)
end

---Simulates a zoom effect by quickly increasing brightness and then returning to normal.
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.zoom(opts)
	local extmark_opts = require("undo-glow.utils").create_extmark_opts({
		bufnr = opts.bufnr,
		hlgroup = opts.hlgroup,
		s_row = opts.coordinates.s_row,
		s_col = opts.coordinates.s_col,
		e_row = opts.coordinates.e_row,
		e_col = opts.coordinates.e_col,
		priority = require("undo-glow.config").config.priority,
		force_edge = opts.state.force_edge,
		window_scoped = opts.state.animation.window_scoped,
	})

	local extmark_id = vim.api.nvim_buf_set_extmark(
		opts.bufnr,
		opts.ns,
		opts.coordinates.s_row,
		opts.coordinates.s_col,
		extmark_opts
	)

	table.insert(opts.extmark_ids, extmark_id)

	M.animate_start(opts, function(progress)
		local t = math.sin(progress * math.pi)
		local brightness = 1 + 0.5 * t
		local function adjust_brightness(rgb)
			return {
				r = math.min(255, math.floor(rgb.r * brightness)),
				g = math.min(255, math.floor(rgb.g * brightness)),
				b = math.min(255, math.floor(rgb.b * brightness)),
			}
		end
		local zoom_bg = adjust_brightness(opts.start_bg)
		local zoom_fg = opts.start_fg and adjust_brightness(opts.start_fg)
			or nil

		return {
			bg = require("undo-glow.color").rgb_to_hex(zoom_bg),
			fg = zoom_fg and require("undo-glow.color").rgb_to_hex(zoom_fg)
				or nil,
		}
	end)
end

---Simulates a rainbow effect by cycling through hues.
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.rainbow(opts)
	local extmark_opts = require("undo-glow.utils").create_extmark_opts({
		bufnr = opts.bufnr,
		hlgroup = opts.hlgroup,
		s_row = opts.coordinates.s_row,
		s_col = opts.coordinates.s_col,
		e_row = opts.coordinates.e_row,
		e_col = opts.coordinates.e_col,
		priority = require("undo-glow.config").config.priority,
		force_edge = opts.state.force_edge,
		window_scoped = opts.state.animation.window_scoped,
	})

	local extmark_id = vim.api.nvim_buf_set_extmark(
		opts.bufnr,
		opts.ns,
		opts.coordinates.s_row,
		opts.coordinates.s_col,
		extmark_opts
	)

	table.insert(opts.extmark_ids, extmark_id)

	M.animate_start(opts, function(progress)
		local hue = progress * 360 -- cycle through hues
		local rgb =
			require("undo-glow.color").hsl_to_rgb({ h = hue, s = 1, l = 0.5 })
		return {
			bg = require("undo-glow.color").rgb_to_hex(rgb),
			fg = opts.start_fg,
		}
	end)
end

---Simulates a slide (right) effect by moving the extmark horizontally.
---This animation only support single line, multiple lines highlight will default to fade
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.slide(opts)
	local buf = opts.bufnr
	local ns = opts.ns

	local is_multiline_with_zero_start_end = opts.coordinates.e_row
			> opts.coordinates.s_row
		and opts.coordinates.e_row - opts.coordinates.s_row > 1
		and opts.coordinates.s_col == 0
		and opts.coordinates.e_col == 0

	local is_multiline_with_exact_coords = opts.coordinates.e_row
			> opts.coordinates.s_row
		and opts.coordinates.e_col > 0

	local is_multiline = is_multiline_with_zero_start_end
		or is_multiline_with_exact_coords

	if not is_multiline then
		-- try to match the cursorline style if single line
		local success, normal =
			pcall(vim.api.nvim_get_hl, 0, { name = "CursorLine" })

		opts.end_bg = success
				and normal.bg
				and require("undo-glow.color").hex_to_rgb(
					string.format("#%06X", normal.bg)
				)
			or opts.end_bg

		local extmark_opts = require("undo-glow.utils").create_extmark_opts({
			bufnr = buf,
			hlgroup = opts.hlgroup,
			s_row = opts.coordinates.s_row,
			s_col = opts.coordinates.s_col,
			e_row = opts.coordinates.e_row,
			e_col = opts.coordinates.e_col,
			priority = require("undo-glow.config").config.priority,
			force_edge = opts.state.force_edge,
			window_scoped = opts.state.animation.window_scoped,
		})

		local created_extmark_status, created_extmark_result = pcall(
			vim.api.nvim_buf_set_extmark,
			buf,
			ns,
			opts.coordinates.s_row,
			opts.coordinates.s_col,
			extmark_opts
		)
		if not created_extmark_status then
			return -- abort if extmark creation fails
		end

		table.insert(opts.extmark_ids, created_extmark_result)

		local original_row = opts.coordinates.s_row
		local original_col = opts.coordinates.s_col

		M.animate_start(opts, function(progress, end_animation)
			local eased = opts.state.animation.easing({
				time = progress,
				begin = 0,
				change = 1,
				duration = 1,
			})

			local new_opts = vim.tbl_deep_extend(
				"force",
				extmark_opts,
				{ id = opts.extmark_ids[1] }
			)
			local success_lines, lines = pcall(
				vim.api.nvim_buf_get_lines,
				buf,
				original_row,
				original_row + 1,
				false
			)

			local line = (success_lines and lines[1] or "") or ""

			line = require("undo-glow.utils").ensure_string(line)

			local line_end = opts.coordinates.e_col

			if opts.coordinates.e_col == 0 then
				line_end = #line
			end
			local line_display = vim.fn.strdisplaywidth(line)

			local win_width = vim.api.nvim_win_get_width(0)
			local is_force_edge = (
				type(opts.state.force_edge) == "boolean"
				and opts.state.force_edge == true
			)
			local base_move = math.max(0, line_end - original_col)
			local pad = math.max(0, win_width - line_display)
			local total_move = base_move + (is_force_edge and pad or 0)
			local total_progress = math.floor(total_move * progress)

			--- HACK: see if it's full width, force the coordinates
			if
				opts.coordinates.s_col == 0
				and opts.coordinates.e_col == 0
				and opts.coordinates.e_row - opts.coordinates.s_row ~= 0
			then
				new_opts.end_row = opts.coordinates.e_row - 1
			end

			if total_progress <= line_end then
				if is_force_edge then
					new_opts.end_col =
						math.min(line_end, original_col + total_progress)
				else
					new_opts.end_col = original_col + total_progress
				end
				new_opts.virt_text = nil
				new_opts.virt_text_win_col = nil
			else
				new_opts.end_col = line_end
				if is_force_edge then
					new_opts.virt_text_win_col = extmark_opts.virt_text_win_col
					new_opts.virt_text = {
						{
							string.rep(" ", total_progress - base_move),
							opts.hlgroup,
						},
					}
				end
			end

			local update_extmark_status = pcall(
				vim.api.nvim_buf_set_extmark,
				buf,
				ns,
				original_row,
				original_col,
				new_opts
			)

			if not update_extmark_status then
				end_animation()
			end

			return {
				bg = require("undo-glow.color").blend_color(
					opts.start_bg,
					opts.end_bg,
					eased
				),
				fg = (opts.start_fg and opts.end_fg) and require(
					"undo-glow.color"
				).blend_color(opts.start_fg, opts.end_fg, eased) or nil,
			}
		end)
	else
		opts.extmark_ids = {}
		local win_width = vim.api.nvim_win_get_width(0)

		if opts.coordinates.e_col == 0 then
			opts.coordinates.e_row = opts.coordinates.e_row - 1
		end

		-- Create an extmark for each row in the region.
		for row = opts.coordinates.s_row, opts.coordinates.e_row do
			local s_col = (row == opts.coordinates.s_row)
					and opts.coordinates.s_col
				or 0
			local e_col = (row == opts.coordinates.e_row)
					and opts.coordinates.e_col
				or 0

			local success_lines, lines =
				pcall(vim.api.nvim_buf_get_lines, buf, row, row + 1, false)
			local line = (success_lines and lines[1] or "") or ""

			if e_col == 0 then
				e_col = #line
			end

			local extmark_opts =
				require("undo-glow.utils").create_extmark_opts({
					bufnr = buf,
					hlgroup = opts.hlgroup,
					s_row = row,
					s_col = s_col,
					e_row = row,
					e_col = e_col,
					priority = require("undo-glow.config").config.priority,
					force_edge = opts.state.force_edge,
					window_scoped = opts.state.animation.window_scoped,
				})

			local created_extmark_status, created_extmark_result = pcall(
				vim.api.nvim_buf_set_extmark,
				buf,
				ns,
				row,
				s_col,
				extmark_opts
			)

			if not created_extmark_status then
				return false -- fallback to fade if extmark creation fails
			end

			opts.extmark_ids[row] = created_extmark_result
		end

		M.animate_start(opts, function(progress)
			local eased = opts.state.animation.easing({
				time = progress,
				begin = 0,
				change = 1,
				duration = 1,
			})

			for row = opts.coordinates.s_row, opts.coordinates.e_row do
				local s_col = (row == opts.coordinates.s_row)
						and opts.coordinates.s_col
					or 0
				local target_e_col = (row == opts.coordinates.e_row)
						and opts.coordinates.e_col
					or 0

				local success_lines, lines =
					pcall(vim.api.nvim_buf_get_lines, buf, row, row + 1, false)
				local line = (success_lines and lines[1] or "") or ""

				line = require("undo-glow.utils").ensure_string(line)

				local line_display = vim.fn.strdisplaywidth(line)
				if target_e_col == 0 then
					target_e_col = #line
				end

				local is_force_edge = (
					type(opts.state.force_edge) == "boolean"
					and opts.state.force_edge == true
				)
				local base_move = math.max(0, target_e_col - s_col)
				local pad = math.max(0, win_width - line_display)
				local total_move = base_move + (is_force_edge and pad or 0)
				local total_progress = math.floor(total_move * progress)

				local new_opts = {
					hl_group = opts.hlgroup,
					end_row = row,
					priority = require("undo-glow.config").config.priority,
				}

				if total_progress <= target_e_col then
					if is_force_edge then
						new_opts.end_col =
							math.min(target_e_col, s_col + total_progress)
					else
						new_opts.end_col = s_col + total_progress
					end
					new_opts.virt_text = nil
					new_opts.virt_text_win_col = nil
				else
					new_opts.end_col = target_e_col
					if is_force_edge then
						local extmark_opts =
							require("undo-glow.utils").create_extmark_opts({
								bufnr = buf,
								hlgroup = opts.hlgroup,
								s_row = row,
								s_col = s_col,
								e_row = row,
								e_col = target_e_col,
								priority = require("undo-glow.config").config.priority,
								force_edge = opts.state.force_edge,
							})
						new_opts.virt_text_win_col =
							extmark_opts.virt_text_win_col
						new_opts.virt_text = {
							{
								string.rep(" ", total_progress - base_move),
								opts.hlgroup,
							},
						}
					end
				end

				local update_extmark_status, update_extmark_result = pcall(
					vim.api.nvim_buf_set_extmark,
					buf,
					ns,
					row,
					s_col,
					vim.tbl_extend(
						"force",
						new_opts,
						{ id = opts.extmark_ids[row] }
					)
				)

				if not update_extmark_status then
					vim.notify(
						"[UndoGlow] Error updating extmark: "
							.. update_extmark_result,
						vim.log.levels.ERROR
					)
				end
			end

			return {
				bg = require("undo-glow.color").blend_color(
					opts.start_bg,
					opts.end_bg,
					eased
				),
				fg = (opts.start_fg and opts.end_fg) and require(
					"undo-glow.color"
				).blend_color(opts.start_fg, opts.end_fg, eased) or nil,
			}
		end)
	end
end

return M
