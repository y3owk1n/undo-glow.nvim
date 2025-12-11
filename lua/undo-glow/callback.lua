local M = {}

---Callback to track changes
---@param state UndoGlow.State State
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

	-- Use debouncing to prevent excessive highlighting during rapid operations
	local debounce = require("undo-glow.debounce")
	local debounce_key = string.format("highlight_%d", bufnr)

	local debounced_highlight = debounce.debounce(function()
		local success, err = pcall(function()
			---@type UndoGlow.HandleHighlight
			local handle_highlight_opts = {
				bufnr = bufnr,
				state = state,
				s_row = s_row,
				s_col = s_col,
				e_row = end_row,
				e_col = end_col,
			}

			require("undo-glow.utils").handle_highlight(handle_highlight_opts)
		end)

		if not success then
			-- Graceful degradation: log error but don't crash
			require("undo-glow.log").error(
				"Failed to highlight changes: " .. tostring(err)
			)
		end
	end, 50, debounce_key) -- 50ms debounce delay

	vim.schedule(debounced_highlight)
	return false
end

return M
