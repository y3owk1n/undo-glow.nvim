local M = {}
---@alias AnimationType "fade" | "blink" | "pulse" | "jitter"

---@class UndoGlow.Config
---@field animation? UndoGlow.Config.Animation
---@field highlights? table<"undo" | "redo" | "yank" | "paste" | "search" | "comment", { hl: string, hl_color: UndoGlow.HlColor }>

---@class UndoGlow.EasingOpts
---@field time integer Elapsed time
---@field begin? integer Begin
---@field change? integer Change == ending - beginning
---@field duration? integer Duration (total time)
---@field amplitude? integer Amplitude
---@field period? integer Period
---@field overshoot? integer Overshoot

---@class UndoGlow.Config.Animation
---@field enabled? boolean Turn on or off for animation
---@field duration? number Highlight duration in ms
---@field animation_type? AnimationType
---@field easing? fun(opts: UndoGlow.EasingOpts): integer A function that computes easing.
---@field fps? number Normally either 60 / 120, up to you

---@class UndoGlow.HlColor
---@field bg string
---@field fg? string

---@class UndoGlow.State
---@field current_hlgroup string
---@field should_detach boolean
---@field animation? UndoGlow.Config.Animation

---@class UndoGlow.RGBColor
---@field r integer Red (0-255)
---@field g integer Green (0-255)
---@field b integer Blue (0-255)

---@class UndoGlow.CommandOpts
---@field hlgroup? string
---@field animation? UndoGlow.Config.Animation

---@class UndoGlow.HighlightChanges : UndoGlow.CommandOpts

---@class UndoGlow.HighlightRegion : UndoGlow.CommandOpts,UndoGlow.RowCol

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
---@field state UndoGlow.State

---@class UndoGlow.HandleHighlight : UndoGlow.RowCol
---@field bufnr integer Buffer number
---@field config UndoGlow.Config
---@field state UndoGlow.State State

---@class UndoGlow.RowCol
---@field s_row integer Start row
---@field s_col integer Start column
---@field e_row integer End row
---@field e_col integer End column

M.config = require("undo-glow.config")
M.easing = require("undo-glow.easing")

M.undo = require("undo-glow.commands").undo
M.redo = require("undo-glow.commands").redo
M.yank = require("undo-glow.commands").yank
M.paste_below = require("undo-glow.commands").paste_below
M.paste_above = require("undo-glow.commands").paste_above
M.search_next = require("undo-glow.commands").search_next
M.search_prev = require("undo-glow.commands").search_prev
M.search_star = require("undo-glow.commands").search_star
M.comment = require("undo-glow.commands").comment
M.comment_textobject = require("undo-glow.commands").comment_textobject
M.comment_line = require("undo-glow.commands").comment_line

local highlights = require("undo-glow.highlight")
local callback = require("undo-glow.callback")
local utils = require("undo-glow.utils")

-- Helper to attach to a buffer with a local state.
---@param opts? UndoGlow.HighlightChanges|UndoGlow.CommandOpts
function M.highlight_changes(opts)
	local bufnr = vim.api.nvim_get_current_buf()

	local state = utils.create_state(opts, M.config)

	vim.api.nvim_buf_attach(bufnr, false, {
		on_bytes = function(...)
			return callback.on_bytes_wrapper(state, M.config, ...)
		end,
	})
end

--- Highlight a specified region in the current buffer.
--- This API can be used for yanking or any other use case where you want to
--- temporarily highlight a region without modifying the text.
--- @param opts UndoGlow.HighlightRegion
function M.highlight_region(opts)
	local bufnr = vim.api.nvim_get_current_buf()

	local state = utils.create_state(opts, M.config)

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

---@param user_config? UndoGlow.Config
function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

	local valid_keys = {
		undo = true,
		redo = true,
		yank = true,
		paste = true,
		search = true,
		comment = true,
	}

	for key in pairs(M.config.highlights) do
		if not valid_keys[key] then
			M.config.highlights[key] = nil
		end
	end

	local target_map = {
		undo = "UgUndo",
		redo = "UgRedo",
		yank = "UgYank",
		paste = "UgPaste",
		search = "UgSearch",
		comment = "UgComment",
	}

	for key, highlight in pairs(M.config.highlights) do
		local target = target_map[key]
		highlights.setup_highlight(target, highlight.hl, highlight.hl_color)
	end
end

return M
