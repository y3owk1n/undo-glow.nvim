local colors = require("undo-glow.color")
local utils = require("undo-glow.utils")

local M = {}

-- Animate the fadeout of a highlight group from a start color to the Normal background
---@param bufnr integer Buffer number
---@param hlgroup string
---@param extmark_id integer
---@param start_bg UndoGlow.RGBColor
---@param end_bg UndoGlow.RGBColor
---@param start_fg? UndoGlow.RGBColor
---@param end_fg? UndoGlow.RGBColor
---@param duration integer
---@param config UndoGlow.Config
function M.animate_fadeout(
	bufnr,
	hlgroup,
	extmark_id,
	start_bg,
	end_bg,
	start_fg,
	end_fg,
	duration,
	config
)
	local start_time = vim.uv.hrtime()
	local interval = 1000 / config.fps
	local timer = vim.uv.new_timer()

	if timer then
		timer:start(
			0,
			interval,
			vim.schedule_wrap(function()
				local success, err = pcall(function()
					local now = vim.uv.hrtime()
					local elapsed = (now - start_time) / 1e6 -- convert from ns to ms
					local t = math.min(elapsed / duration, 1)
					local eased = config.easing(t)

					local blended_bg =
						colors.blend_color(start_bg, end_bg, eased)
					local blended_fg = start_fg
							and end_fg
							and colors.blend_color(start_fg, end_fg, eased)
						or nil

					local hl_opts = { bg = blended_bg }
					if blended_fg then
						hl_opts.fg = blended_fg
					end

					vim.api.nvim_set_hl(0, hlgroup, hl_opts)

					if t >= 1 then
						timer:stop()
						if not vim.uv.is_closing(timer) then
							timer:close()
						end
						if vim.api.nvim_buf_is_valid(bufnr) and extmark_id then
							vim.api.nvim_buf_del_extmark(
								bufnr,
								utils.ns,
								extmark_id
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
					timer:close()
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
		M.animate_fadeout(
			bufnr,
			hlgroup,
			extmark_id,
			colors.hex_to_rgb(start_bg),
			colors.hex_to_rgb(end_bg),
			start_fg and colors.hex_to_rgb(start_fg) or nil,
			start_fg and colors.hex_to_rgb(end_fg) or nil,
			config.duration,
			config
		)
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
