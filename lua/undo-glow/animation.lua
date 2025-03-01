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

return M
