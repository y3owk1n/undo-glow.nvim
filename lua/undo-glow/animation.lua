local colors = require("undo-glow.color")
local utils = require("undo-glow.utils")

local M = {}

M.animate = {}

-- Animate the fadeout of a highlight group from a start color to the Normal background
---@param opts UndoGlow.Animation
function M.animate.fade(opts)
	local start_time = vim.uv.hrtime()
	local interval = 1000 / opts.config.fps
	local timer = vim.uv.new_timer()

	if timer then
		timer:start(
			0,
			interval,
			vim.schedule_wrap(function()
				local success, err = pcall(function()
					local now = vim.uv.hrtime()
					local elapsed = (now - start_time) / 1e6 -- convert from ns to ms
					local t = math.min(elapsed / opts.duration, 1)
					local eased = opts.config.easing(t)

					local blended_bg =
						colors.blend_color(opts.start_bg, opts.end_bg, eased)
					local blended_fg = opts.start_fg
							and opts.end_fg
							and colors.blend_color(
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

					if t >= 1 then
						timer:stop()
						if not vim.uv.is_closing(timer) then
							timer:close()
						end
						if
							vim.api.nvim_buf_is_valid(opts.bufnr)
							and opts.extmark_id
						then
							vim.api.nvim_buf_del_extmark(
								opts.bufnr,
								utils.ns,
								opts.extmark_id
							)
						end
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
				end
			end)
		)
	end
end

---@param opts UndoGlow.Animation
function M.animate.blink(opts)
	local start_time = vim.uv.hrtime()
	local interval = 1000 / opts.config.fps
	local timer = vim.uv.new_timer()

	if timer then
		timer:start(
			0,
			interval,
			vim.schedule_wrap(function()
				local success, err = pcall(function()
					local now = vim.uv.hrtime()
					local elapsed = (now - start_time) / 1e6 -- in ms

					if elapsed >= opts.duration then
						timer:stop()
						if not vim.uv.is_closing(timer) then
							timer:close()
						end
						if
							vim.api.nvim_buf_is_valid(opts.bufnr)
							and opts.extmark_id
						then
							vim.api.nvim_buf_del_extmark(
								opts.bufnr,
								utils.ns,
								opts.extmark_id
							)
						end
						return
					end

					local blink_period = 200
					local phase = (elapsed % blink_period) < (blink_period / 2)

					if phase then
						local hl_opts =
							{ bg = colors.rgb_to_hex(opts.start_bg) }
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

				if not success then
					vim.notify(
						"UndoGlow: " .. tostring(err),
						vim.log.levels.ERROR
					)
					timer:stop()
					if not vim.uv.is_closing(timer) then
						timer:close()
					end
				end
			end)
		)
	end
end

---@param opts UndoGlow.Animation
function M.animate.jitter(opts)
	local start_time = vim.uv.hrtime()
	local interval = 1000 / opts.config.fps
	local timer = vim.uv.new_timer()

	if timer then
		timer:start(
			0,
			interval,
			vim.schedule_wrap(function()
				local success, err = pcall(function()
					local now = vim.uv.hrtime()
					local elapsed = (now - start_time) / 1e6 -- in ms

					if elapsed >= opts.duration then
						timer:stop()
						if not vim.uv.is_closing(timer) then
							timer:close()
						end
						if
							vim.api.nvim_buf_is_valid(opts.bufnr)
							and opts.extmark_id
						then
							vim.api.nvim_buf_del_extmark(
								opts.bufnr,
								utils.ns,
								opts.extmark_id
							)
						end
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
					local jitter_fg = opts.start_fg
							and jitter_color(opts.start_fg)
						or nil

					local hl_opts = { bg = colors.rgb_to_hex(jitter_bg) }
					if jitter_fg then
						hl_opts.fg = colors.rgb_to_hex(jitter_fg)
					end

					vim.api.nvim_set_hl(0, opts.hlgroup, hl_opts)
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
				end
			end)
		)
	end
end

---@param opts UndoGlow.Animation
function M.animate.pulse(opts)
	local start_time = vim.uv.hrtime()
	local interval = 1000 / opts.config.fps
	local timer = vim.uv.new_timer()

	if timer then
		timer:start(
			0,
			interval,
			vim.schedule_wrap(function()
				local success, err = pcall(function()
					local now = vim.uv.hrtime()
					local elapsed = (now - start_time) / 1e6 -- convert ns to ms
					local t = 0.5
						* (
							1
							- math.cos(2 * math.pi * (elapsed / opts.duration))
						)
					local eased = opts.config.easing(t)

					local blended_bg =
						colors.blend_color(opts.start_bg, opts.end_bg, eased)
					local blended_fg = opts.start_fg
							and opts.end_fg
							and colors.blend_color(
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

					-- Stop after total duration has elapsed
					if elapsed >= opts.duration then
						timer:stop()
						if not vim.uv.is_closing(timer) then
							timer:close()
						end
						if
							vim.api.nvim_buf_is_valid(opts.bufnr)
							and opts.extmark_id
						then
							vim.api.nvim_buf_del_extmark(
								opts.bufnr,
								utils.ns,
								opts.extmark_id
							)
						end
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
				end
			end)
		)
	end
end

-- Animate or clear highlights after a duration
---@param bufnr integer Buffer number
---@param state UndoGlow.State State
---@param hlgroup string Unique highlight group name
---@param extmark_id integer
---@param start_bg string The starting background color (hex)
---@param start_fg? string The starting foreground color (hex)
---@param config UndoGlow.Config
function M.clear_highlights(
	bufnr,
	state,
	hlgroup,
	extmark_id,
	start_bg,
	start_fg,
	config
)
	local end_bg = colors.get_normal_bg()
	local end_fg = colors.get_normal_fg()

	if config.animation then
		local animation_opts = {
			bufnr = bufnr,
			hlgroup = hlgroup,
			extmark_id = extmark_id,
			start_bg = colors.hex_to_rgb(start_bg),
			end_bg = colors.hex_to_rgb(end_bg),
			start_fg = start_fg and colors.hex_to_rgb(start_fg) or nil,
			end_fg = start_fg and colors.hex_to_rgb(end_fg) or nil,
			duration = config.duration,
			config = config,
		}

		M.animate[state.animation_type](animation_opts)
	else
		vim.defer_fn(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_del_extmark(bufnr, utils.ns, extmark_id)
			end
		end, config.duration)
	end

	state.should_detach = true
end

return M
