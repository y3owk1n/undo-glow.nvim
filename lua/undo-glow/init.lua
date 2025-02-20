local M = {}
---@alias AnimationType "fade" | "blink" | "pulse" | "jitter"

---@class UndoGlow.Config
---@field duration? number Highlight duration in ms
---@field animation? boolean Turn on or off for animation
---@field animation_type? AnimationType
---@field easing? function A function that takes a number (0-1) and returns a number (0-1) for easing.
---@field fps? number Normally either 60 / 120, up to you
---@field undo_hl? string If not "UgUndo" then copy the to color to UgUndo or fallback to default
---@field redo_hl? string If not "UgRedo" then copy the to color to UgRedo or fallback to default
---@field undo_hl_color? UndoGlow.HlColor
---@field redo_hl_color? UndoGlow.HlColor

---@class UndoGlow.HlColor
---@field bg string
---@field fg? string

---@class UndoGlow.State
---@field current_hlgroup string
---@field should_detach boolean
---@field animation_type? AnimationType

---@class UndoGlow.RGBColor
---@field r integer Red (0-255)
---@field g integer Green (0-255)
---@field b integer Blue (0-255)

---@class UndoGlow.AttachAndRunOpts
---@field hlgroup string
---@field cmd? function
---@field animation_type? AnimationType

---@class UndoGlow.HighlightRegion
---@field hlgroup string
---@field animation_type? AnimationType
---@field s_row integer Start row
---@field s_col integer Start column
---@field e_row integer End row
---@field e_col integer End column

---@class UndoGlow.Animation
---@field bufnr integer Buffer number
---@field hlgroup string
---@field extmark_id integer
---@field start_bg UndoGlow.RGBColor
---@field end_bg UndoGlow.RGBColor
---@field start_fg? UndoGlow.RGBColor
---@field end_fg? UndoGlow.RGBColor
---@field duration integer
---@field config UndoGlow.Config

---@class UndoGlow.HandleHighlight
---@field bufnr integer Buffer number
---@field config UndoGlow.Config
---@field state UndoGlow.State State
---@field s_row integer Start row
---@field s_col integer Start column
---@field e_row integer End row
---@field e_col integer End column

M.config = require("undo-glow.config")
M.easing = require("undo-glow.easing")

local highlights = require("undo-glow.highlight")
local callback = require("undo-glow.callback")
local utils = require("undo-glow.utils")

-- Helper to attach to a buffer with a local state.
---@param opts UndoGlow.AttachAndRunOpts
function M.attach_and_run(opts)
	local bufnr = vim.api.nvim_get_current_buf()

	---@type UndoGlow.State
	local state = {
		should_detach = false,
		current_hlgroup = opts.hlgroup,
		animation_type = opts.animation_type or M.config.animation_type,
	}

	vim.api.nvim_buf_attach(bufnr, false, {
		on_bytes = function(...)
			return callback.on_bytes_wrapper(state, M.config, ...)
		end,
	})

	if opts.cmd then
		opts.cmd()
	end
end

--- Highlight a specified region in the current buffer.
--- This API can be used for yanking or any other use case where you want to
--- temporarily highlight a region without modifying the text.
--- @param opts UndoGlow.HighlightRegion
function M.highlight_region(opts)
	local bufnr = vim.api.nvim_get_current_buf()

	---@type UndoGlow.State
	local state = {
		should_detach = false,
		current_hlgroup = opts.hlgroup,
		animation_type = opts.animation_type or M.config.animation_type,
	}

	vim.schedule(function()
		---@type UndoGlow.HandleHighlight
		local handle_highlight_opts = {
			bufnr = bufnr,
			config = M.config,
			state = state,
			s_row = opts.s_row,
			s_col = opts.s_col,
			e_row = opts.e_row,
			e_col = opts.e_col,
		}

		utils.handle_highlight(handle_highlight_opts)
	end)
end

function M.undo()
	M.attach_and_run({
		hlgroup = "UgUndo",
		cmd = function()
			vim.cmd("undo")
		end,
	})
end

function M.redo()
	M.attach_and_run({
		hlgroup = "UgRedo",
		cmd = function()
			vim.cmd("redo")
		end,
	})
end

---@param user_config? UndoGlow.Config
function M.setup(user_config)
	M.config = vim.tbl_extend("force", M.config, user_config or {})

	if M.config.undo_hl ~= "UgUndo" then
		highlights.link_highlight(
			"UgUndo",
			M.config.undo_hl,
			M.config.undo_hl_color
		)
	else
		highlights.set_highlight(M.config.undo_hl, M.config.undo_hl_color)
	end

	if M.config.redo_hl ~= "UgRedo" then
		highlights.link_highlight(
			"UgRedo",
			M.config.redo_hl,
			M.config.redo_hl_color
		)
	else
		highlights.set_highlight(M.config.undo_hl, M.config.undo_hl_color)
	end
end

return M
