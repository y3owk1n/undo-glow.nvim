local M = {}

M.animate = {}

---Function to clear the animation when complete
---@param opts UndoGlow.Animation The animation options.
---@param timer uv.uv_timer_t The timer instance used for animation.
---@return nil
local function animate_clear(opts, timer)
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

--- Starts an animation.
--- Repeatedly calls the provided animation function with a progress value between 0 and 1 until the animation completes.
--- @param opts UndoGlow.Animation The animation options.
--- @param animate_fn fun(progress: number): nil A function that receives the current progress (0 = start, 1 = end).
--- @return nil
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
						animate_clear(opts, timer)
						return
					end

					animate_fn(progress)
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

--- Fades out a highlight group from a start color to the normal background.
--- @param opts UndoGlow.Animation The animation options.
--- @return nil
function M.animate.fade(opts)
	M.animate_start(opts, function(progress)
		local eased = opts.state.animation.easing({
			time = progress,
			begin = 0,
			change = 1,
			duration = 1,
		})

		local blended_bg = require("undo-glow.color").blend_color(
			opts.start_bg,
			opts.end_bg,
			eased
		)
		local blended_fg = opts.start_fg
				and opts.end_fg
				and require("undo-glow.color").blend_color(
					opts.start_fg,
					opts.end_fg,
					eased
				)
			or nil

		local hl_opts = { bg = blended_bg }
		if blended_fg then
			hl_opts.fg = blended_fg
		end

		vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
	end)
end

--- Blinks a highlight group by alternating between the start and end colors.
--- @param opts UndoGlow.Animation The animation options.
--- @return nil
function M.animate.blink(opts)
	M.animate_start(opts, function(progress)
		local blink_period = 200
		local phase = (progress * opts.duration % blink_period)
			< (blink_period / 2)

		if phase then
			local hl_opts =
				{ bg = require("undo-glow.color").rgb_to_hex(opts.start_bg) }
			if opts.start_fg then
				hl_opts.fg =
					require("undo-glow.color").rgb_to_hex(opts.start_fg)
			end
			vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
		else
			local hl_opts =
				{ bg = require("undo-glow.color").rgb_to_hex(opts.end_bg) }
			if opts.start_fg then
				hl_opts.fg = require("undo-glow.color").rgb_to_hex(opts.end_fg)
			end
			vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
		end
	end)
end

--- Applies a jitter effect to a highlight group by randomly altering the colors.
--- @param opts UndoGlow.Animation The animation options.
--- @return nil
function M.animate.jitter(opts)
	M.animate_start(opts, function(_)
		local function jitter_color(rgb)
			local function clamp(val)
				return math.max(0, math.min(255, val))
			end
			return {
				r = clamp(rgb.r + math.random(-15, 15)),
				g = clamp(rgb.g + math.random(-15, 15)),
				b = clamp(rgb.b + math.random(-15, 15)),
			}
		end

		local jitter_bg = jitter_color(opts.start_bg)
		local jitter_fg = opts.start_fg and jitter_color(opts.start_fg) or nil

		local hl_opts =
			{ bg = require("undo-glow.color").rgb_to_hex(jitter_bg) }
		if jitter_fg then
			hl_opts.fg = require("undo-glow.color").rgb_to_hex(jitter_fg)
		end

		vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
	end)
end

--- Pulses a highlight group by rhythmically blending the start and end colors.
--- @param opts UndoGlow.Animation The animation options.
--- @return nil
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

		local blended_bg = require("undo-glow.color").blend_color(
			opts.start_bg,
			opts.end_bg,
			t
		)
		local blended_fg = opts.start_fg
				and opts.end_fg
				and require("undo-glow.color").blend_color(
					opts.start_fg,
					opts.end_fg,
					t
				)
			or nil

		local hl_opts = { bg = blended_bg }
		if blended_fg then
			hl_opts.fg = blended_fg
		end

		vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
	end)
end

--- Applies a spring effect that overshoots the target color before settling.
--- @param opts UndoGlow.Animation The animation options.
--- @return nil
function M.animate.spring(opts)
	M.animate_start(opts, function(progress)
		local t = math.sin(
			progress * math.pi * (0.2 + 2.5 * progress * progress * progress)
		) * (1 - progress) + progress

		local blended_bg = require("undo-glow.color").blend_color(
			opts.start_bg,
			opts.end_bg,
			t
		)
		local blended_fg = opts.start_fg
				and opts.end_fg
				and require("undo-glow.color").blend_color(
					opts.start_fg,
					opts.end_fg,
					t
				)
			or nil

		local hl_opts = { bg = blended_bg }
		if blended_fg then
			hl_opts.fg = blended_fg
		end
		vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
	end)
end

--- Gradually desaturates the highlight color.
--- Requires: rgb_to_hsl and hsl_to_rgb functions in your color module.
--- @param opts UndoGlow.Animation The animation options.
--- @return nil
function M.animate.desaturate(opts)
	M.animate_start(opts, function(progress)
		local function desaturate(rgb)
			local hsl = require("undo-glow.color").rgb_to_hsl(rgb)
			hsl.s = hsl.s * (1 - progress) -- reduce saturation over time
			local desaturated_rgb = require("undo-glow.color").hsl_to_rgb(hsl)
			return desaturated_rgb
		end

		local desat_bg = desaturate(opts.start_bg)
		local hl_opts = { bg = require("undo-glow.color").rgb_to_hex(desat_bg) }
		if opts.start_fg then
			local desat_fg = desaturate(opts.start_fg)
			hl_opts.fg = require("undo-glow.color").rgb_to_hex(desat_fg)
		end
		vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
	end)
end

return M
