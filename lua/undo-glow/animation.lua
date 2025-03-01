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
	if vim.api.nvim_buf_is_valid(opts.bufnr) and opts.extmark_id then
		vim.api.nvim_buf_del_extmark(
			opts.bufnr,
			require("undo-glow.utils").ns,
			opts.extmark_id
		)
	end
	vim.cmd("hi clear " .. opts.hlgroup)
end

---Starts an animation.
---Repeatedly calls the provided animation function with a progress value between 0 and 1 until the animation completes.
---@param opts UndoGlow.Animation The animation options.
---@param animate_fn fun(progress: number): UndoGlow.HlColor|nil A function that receives the current progress (0 = start, 1 = end) and return the hl colors or nothing.
---@return nil
function M.animate_start(opts, animate_fn)
	local start_time = vim.uv.hrtime()
	local interval = 1000 / opts.state.animation.fps
	local timer = vim.uv.new_timer()

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

					if progress >= 1 then
						M.animate_clear(opts, timer)
						return
					end

					local hl_opts = animate_fn(progress)

					if hl_opts then
						vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
					end
				end)

				if not success then
					vim.notify(
						"UndoGlow: " .. tostring(err),
						vim.log.levels.ERROR
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
	M.animate_start(opts, function(_)
		---@param rgb UndoGlow.RGBColor
		---@return string hex
		local function jitter_color(rgb)
			local function clamp(val)
				return math.max(0, math.min(255, val))
			end

			local converted_rgb = {
				r = clamp(rgb.r + math.random(-15, 15)),
				g = clamp(rgb.g + math.random(-15, 15)),
				b = clamp(rgb.b + math.random(-15, 15)),
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
	local ns = require("undo-glow.utils").ns
	local coords = vim.api.nvim_buf_get_extmark_by_id(
		opts.bufnr,
		ns,
		opts.extmark_id,
		{ details = true }
	)
	if not coords or #coords == 0 then
		return
	end

	local original_row = coords[1]
	local original_col = coords[2]
	local preserved_opts = coords[3] or {}

	-- These should not be set in extmark, will cause error
	preserved_opts["ns_id"] = nil
	preserved_opts["virt_text_pos"] = nil

	if preserved_opts.end_row - original_row > 1 then
		vim.notify(
			"UndoGlow: slide_right does not support multiple lines",
			vim.log.levels.WARN
		)
		return false
	end

	M.animate_start(opts, function(progress)
		local new_opts = vim.tbl_deep_extend(
			"force",
			preserved_opts,
			{ id = opts.extmark_id }
		)
		local line = vim.api.nvim_buf_get_lines(
			buf,
			original_row,
			original_row + 1,
			false
		)[1] or ""

		-- For the extmark's base, use the byte length of the line.
		local line_end = #line
		-- For virt_text anchoring, use display width.
		local line_display = vim.fn.strdisplaywidth(line)
		local win_width = vim.api.nvim_win_get_width(0)

		local new_base, new_vt_anchor

		if
			preserved_opts.virt_text
			and type(preserved_opts.virt_text) == "table"
		then
			-- Calculate how far the base can move.
			local base_move = math.max(0, line_end - original_col)
			-- Calculate the extra space for virt_text.
			local pad = math.max(0, win_width - line_display)
			local total_move = base_move + pad
			local threshold = total_move > 0 and (base_move / total_move) or 1

			if progress <= threshold then
				-- Phase 1: slide base from original_col to line_end.
				local frac = progress / threshold
				new_base = original_col + math.floor(base_move * frac)
				new_vt_anchor = line_display -- keep anchor fixed
			else
				-- Phase 2: keep base fixed at line_end and slide virt_text anchor.
				new_base = line_end
				local frac = (progress - threshold) / (1 - threshold)
				new_vt_anchor = line_display + math.floor(pad * frac)
			end
			new_opts.virt_text_win_col = new_vt_anchor
		else
			-- Without virt_text, simply slide the base.
			local base_move = math.max(0, line_end - original_col)
			new_base = original_col + math.floor(base_move * progress)
		end

		-- Clamp new_base to be within [0, line_end].
		if new_base < 0 then
			new_base = 0
		end
		if new_base > line_end then
			new_base = line_end
		end

		vim.api.nvim_buf_set_extmark(buf, ns, original_row, new_base, new_opts)

		return {
			bg = require("undo-glow.color").rgb_to_hex(opts.start_bg),
			fg = opts.start_fg and require("undo-glow.color").rgb_to_hex(
				opts.start_fg
			) or nil,
		}
	end)
end

---Simulates a reverse slide (left) effect by moving the extmark horizontally in reverse.
---This animation only support single line, multiple lines highlight will default to fade
---@param opts UndoGlow.Animation The animation options.
---@return boolean|nil status Return `false` to fallback to fade
function M.animate.slide_reverse(opts)
	local ns = require("undo-glow.utils").ns
	local buf = opts.bufnr
	local coords = vim.api.nvim_buf_get_extmark_by_id(
		buf,
		ns,
		opts.extmark_id,
		{ details = true }
	)
	if not coords or #coords == 0 then
		return
	end

	local original_row = coords[1]
	local original_col = coords[2] -- byte index of start
	local preserved_opts = coords[3] or {}

	-- These should not be set in extmark, will cause error
	preserved_opts["ns_id"] = nil
	preserved_opts["virt_text_pos"] = nil

	if preserved_opts.end_row - original_row > 1 then
		vim.notify(
			"UndoGlow: slide_left does not support multiple lines",
			vim.log.levels.WARN
		)
		return false
	end

	M.animate_start(opts, function(progress)
		local new_opts = vim.tbl_deep_extend(
			"force",
			preserved_opts,
			{ id = opts.extmark_id }
		)
		local line = vim.api.nvim_buf_get_lines(
			buf,
			original_row,
			original_row + 1,
			false
		)[1] or ""
		local line_end = #line -- maximum valid base (byte length)
		local line_display = vim.fn.strdisplaywidth(line) -- visible width of the text
		local win_width = vim.api.nvim_win_get_width(0)

		local new_base, new_vt_anchor

		if
			preserved_opts.virt_text
			and type(preserved_opts.virt_text) == "table"
		then
			local base_move = math.max(0, line_end - original_col)
			local vt_move = math.max(0, win_width - line_display)
			-- Total movement distance is sum of vt_move and base_move.
			local T = (vt_move > 0 and (vt_move / (vt_move + base_move))) or 0

			if progress <= T then
				-- Phase 1: Animate virt_text anchor.
				-- Base remains fixed at the line_end.
				new_base = line_end
				local frac = progress / T
				new_vt_anchor = win_width - math.floor(vt_move * frac)
			else
				-- Phase 2: Virt_text anchor is fixed at line_display.
				new_vt_anchor = line_display
				local frac = (progress - T) / (1 - T)
				new_base = line_end - math.floor(base_move * frac)
			end
			new_opts.virt_text_win_col = new_vt_anchor
		else
			-- No virt_text: simply animate the base from line_end to original_col.
			local base_move = math.max(0, line_end - original_col)
			new_base = line_end - math.floor(base_move * progress)
		end

		-- Clamp new_base within valid range.
		if new_base < 0 then
			new_base = 0
		end
		if new_base > line_end then
			new_base = line_end
		end

		vim.api.nvim_buf_set_extmark(buf, ns, original_row, new_base, new_opts)

		return {
			bg = require("undo-glow.color").rgb_to_hex(opts.start_bg),
			fg = opts.start_fg and require("undo-glow.color").rgb_to_hex(
				opts.start_fg
			) or nil,
		}
	end)
end

return M
