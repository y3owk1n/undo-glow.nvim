local colors = require("undo-glow.color")
local utils = require("undo-glow.utils")

local M = {}

M.animate = {}

---@param opts UndoGlow.Animation
---@param animateFn function
local function animate_wrapper(opts, animateFn)
	local start_time = vim.uv.hrtime()
	local interval = 1000 / opts.config.fps
	local timer = vim.uv.new_timer()

	if timer then
		timer:start(
			0,
			interval,
			vim.schedule_wrap(function()
				local success, err = pcall(function()
					animateFn(timer, start_time)
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

-- Animate the fadeout of a highlight group from a start color to the Normal background
---@param opts UndoGlow.Animation
function M.animate.fade(opts)
	animate_wrapper(opts, function(timer, start_time)
		local now = vim.uv.hrtime()
		local elapsed = (now - start_time) / 1e6 -- convert from ns to ms
		local t = math.min(elapsed / opts.duration, 1)
		local eased = opts.config.easing(t)

		local blended_bg = colors.blend_color(opts.start_bg, opts.end_bg, eased)
		local blended_fg = opts.start_fg
				and opts.end_fg
				and colors.blend_color(opts.start_fg, opts.end_fg, eased)
			or nil

		local hl_opts = { bg = blended_bg }
		if blended_fg then
			hl_opts.fg = blended_fg
		end

		vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)

		if t >= 1 then
			timer:stop()
			if not vim.uv.is_closing(timer) then
				timer:close()
			end
			if vim.api.nvim_buf_is_valid(opts.bufnr) and opts.extmark_id then
				vim.api.nvim_buf_del_extmark(
					opts.bufnr,
					utils.ns,
					opts.extmark_id
				)
			end

			vim.cmd("hi clear " .. opts.hlgroup)
		end
	end)
end

---@param opts UndoGlow.Animation
function M.animate.blink(opts)
	animate_wrapper(opts, function(timer, start_time)
		local now = vim.uv.hrtime()
		local elapsed = (now - start_time) / 1e6 -- in ms

		if elapsed >= opts.duration then
			timer:stop()
			if not vim.uv.is_closing(timer) then
				timer:close()
			end
			if vim.api.nvim_buf_is_valid(opts.bufnr) and opts.extmark_id then
				vim.api.nvim_buf_del_extmark(
					opts.bufnr,
					utils.ns,
					opts.extmark_id
				)
			end
			vim.cmd("hi clear " .. opts.hlgroup)
			return
		end

		local blink_period = 200
		local phase = (elapsed % blink_period) < (blink_period / 2)

		if phase then
			local hl_opts = { bg = colors.rgb_to_hex(opts.start_bg) }
			if opts.start_fg then
				hl_opts.fg = colors.rgb_to_hex(opts.start_fg)
			end
			vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
		else
			local hl_opts = { bg = colors.rgb_to_hex(opts.end_bg) }
			if opts.start_fg then
				hl_opts.fg = colors.rgb_to_hex(opts.end_fg)
			end
			vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
		end
	end)
end

---@param opts UndoGlow.Animation
function M.animate.jitter(opts)
	animate_wrapper(opts, function(timer, start_time)
		local now = vim.uv.hrtime()
		local elapsed = (now - start_time) / 1e6 -- in ms

		if elapsed >= opts.duration then
			timer:stop()
			if not vim.uv.is_closing(timer) then
				timer:close()
			end
			if vim.api.nvim_buf_is_valid(opts.bufnr) and opts.extmark_id then
				vim.api.nvim_buf_del_extmark(
					opts.bufnr,
					utils.ns,
					opts.extmark_id
				)
			end
			vim.cmd("hi clear " .. opts.hlgroup)
			return
		end

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

		local hl_opts = { bg = colors.rgb_to_hex(jitter_bg) }
		if jitter_fg then
			hl_opts.fg = colors.rgb_to_hex(jitter_fg)
		end

		vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
	end)
end

---@param opts UndoGlow.Animation
function M.animate.pulse(opts)
	animate_wrapper(opts, function(timer, start_time)
		local now = vim.uv.hrtime()
		local elapsed = (now - start_time) / 1e6 -- convert ns to ms
		local t = 0.5 * (1 - math.cos(2 * math.pi * (elapsed / opts.duration)))
		local eased = opts.config.easing(t)

		local blended_bg = colors.blend_color(opts.start_bg, opts.end_bg, eased)
		local blended_fg = opts.start_fg
				and opts.end_fg
				and colors.blend_color(opts.start_fg, opts.end_fg, eased)
			or nil

		local hl_opts = { bg = blended_bg }
		if blended_fg then
			hl_opts.fg = blended_fg
		end

		vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)

		-- Stop after total duration has elapsed
		if elapsed >= opts.duration then
			timer:stop()
			if not vim.uv.is_closing(timer) then
				timer:close()
			end
			if vim.api.nvim_buf_is_valid(opts.bufnr) and opts.extmark_id then
				vim.api.nvim_buf_del_extmark(
					opts.bufnr,
					utils.ns,
					opts.extmark_id
				)
			end
			vim.cmd("hi clear " .. opts.hlgroup)
		end
	end)
end

return M
