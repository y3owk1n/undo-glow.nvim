local utils = require("undo-glow.utils")
local animation = require("undo-glow.animation")
local colors = require("undo-glow.color")
local highlights = require("undo-glow.highlight")

local M = {}

--- Callback to track changes
---@param state UndoGlow.State State
---@param config UndoGlow.Config
---@param _err any Error
---@param bufnr integer Buffer number
---@param _changedtick any Changed tick
---@param s_row integer Start row
---@param s_col integer Start column
---@param _byte_offset any Byte offset
---@param _old_er any Old end row
---@param _old_ec any Old end column
---@param _old_off any Old offset
---@param new_er integer New end row
---@param new_ec integer New end column
---@param _new_off any New offset
---@return boolean
function M.on_bytes_wrapper(
	state,
	config,
	_err,
	bufnr,
	_changedtick,
	s_row,
	s_col,
	_byte_offset,
	_old_er,
	_old_ec,
	_old_off,
	new_er,
	new_ec,
	_new_off
)
	if state.should_detach then
		return true
	end

	-- Calculate the ending position.
	local end_row, end_col
	if new_er == 0 then
		-- Single-line change: new_ec is relative to the start column.
		end_row = s_row
		end_col = s_col + new_ec
	else
		-- Multi-line change: new_er is the number of lines added,
		-- and new_ec is the absolute column on the last line.
		end_row = s_row + new_er
		end_col = new_ec
	end

	vim.schedule(function()
		if vim.api.nvim_buf_is_valid(bufnr) then
			-- If animation is off, use the existing hlgroup else use unique hlgroups.
			-- Unique hlgroups is needed for animated version, because we will be changing the hlgroup colors during
			-- animation.
			local unique_hlgroup = config.animation
					and utils.get_unique_hlgroup(state.current_hlgroup)
				or state.current_hlgroup

			local current_hlgroup_detail =
				vim.api.nvim_get_hl(0, { name = state.current_hlgroup })

			local bg = nil
			local fg = nil

			if not current_hlgroup_detail.bg then
				bg = colors.default_undo.bg
			else
				bg = string.format("#%06X", current_hlgroup_detail.bg)
			end

			if not current_hlgroup_detail.fg then
				fg = nil
			else
				fg = string.format("#%06X", current_hlgroup_detail.fg)
			end

			local init_color = {
				bg = bg,
				fg = fg,
			}

			local extmark_id = utils.highlight_range(
				bufnr,
				unique_hlgroup,
				s_row,
				s_col,
				end_row,
				end_col
			)

			animation.clear_highlights(
				bufnr,
				state,
				unique_hlgroup,
				extmark_id,
				init_color.bg,
				init_color.fg,
				config
			)
		end
	end)
	return false
end

return M
