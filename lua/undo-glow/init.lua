local M = {}

local ns = vim.api.nvim_create_namespace("undo-glow")

-- Default configuration
---@class UndoGlow.Config
---@field duration number In ms
---@field undo_hl string
---@field redo_hl string
---@field undo_hl_color vim.api.keyset.highlight
---@field redo_hl_color vim.api.keyset.highlight
M.config = {
	duration = 300,
	undo_hl = "UgUndo",
	redo_hl = "UgRedo",
	undo_hl_color = { bg = "#FF5555", fg = "#000000" },
	redo_hl_color = { bg = "#50FA7B", fg = "#000000" },
}

---@param name string Highlight name
---@param color vim.api.keyset.highlight
local function set_highlight(name, color)
	if vim.fn.hlexists(name) == 0 then
		vim.api.nvim_set_hl(0, name, color)
	end
end

-- Highlight a range in the buffer
---@param bufnr integer Buffer number
---@param hlgroup string Highlight group
---@param s_row integer Start row
---@param s_col integer Start column
---@param e_row integer End row
---@param e_col integer End column
local function highlight_range(bufnr, hlgroup, s_row, s_col, e_row, e_col)
	if s_row == e_row then
		vim.api.nvim_buf_add_highlight(bufnr, ns, hlgroup, s_row, s_col, e_col)
	else
		vim.api.nvim_buf_add_highlight(bufnr, ns, hlgroup, s_row, s_col, -1)
		for l = s_row + 1, e_row - 1 do
			vim.api.nvim_buf_add_highlight(bufnr, ns, hlgroup, l, 0, -1)
		end
		vim.api.nvim_buf_add_highlight(bufnr, ns, hlgroup, e_row, 0, e_col)
	end
end

--- Callback to track changes
---@param state{should_detach:boolean,current_hlgroup: string} State
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
local function on_bytes_wrapper(
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

	vim.schedule(function()
		if vim.api.nvim_buf_is_valid(bufnr) then
			highlight_range(
				bufnr,
				state.current_hlgroup,
				s_row,
				s_col,
				end_row,
				end_col
			)
		end
	end)
	return false
end

-- Clear highlights after a duration
---@param bufnr integer Buffer number
---@param state{should_detach:boolean,current_hlgroup: string} State
local function clear_highlights(bufnr, state)
	vim.defer_fn(function()
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
		end
		state.should_detach = true
	end, M.config.duration)
end

-- Helper to attach to a buffer with a local state.
---@param bufnr integer
---@param cmd 'undo'|'redo'
local function attach_and_run(bufnr, cmd, hlgroup)
	local state = { should_detach = false }
	state.current_hlgroup = hlgroup

	vim.api.nvim_buf_attach(bufnr, false, {
		on_bytes = function(...)
			return on_bytes_wrapper(state, ...)
		end,
	})

	vim.cmd(cmd)

	clear_highlights(bufnr, state)
end

function M.undo()
	local bufnr = vim.api.nvim_get_current_buf()
	attach_and_run(bufnr, "undo", M.config.undo_hl)
end

function M.redo()
	local bufnr = vim.api.nvim_get_current_buf()
	attach_and_run(bufnr, "redo", M.config.redo_hl)
end

---@param user_config? UndoGlow.Config
function M.setup(user_config)
	M.config = vim.tbl_extend("force", M.config, user_config or {})

	set_highlight(M.config.undo_hl, M.config.undo_hl_color)
	set_highlight(M.config.redo_hl, M.config.redo_hl_color)
end

return M
