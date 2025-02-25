local M = {}
---@alias UndoGlow.AnimationType "fade" | "blink" | "pulse" | "jitter"
---@alias UndoGlow.EasingString "linear" | "in_quad" | "out_quad" | "in_out_quad" | "out_in_quad" | "in_cubic" | "out_cubic" | "in_out_cubic" | "out_in_cubic" | "in_quart" | "out_quart" | "in_out_quart" | "out_in_quart" | "in_quint" | "out_quint" | "in_out_quint" | "out_in_quint" | "in_sine" | "out_sine" | "in_out_sine" | "out_in_sine" | "in_expo" | "out_expo" | "in_out_expo" | "out_in_expo" | "in_circ" | "out_circ" | "in_out_circ" | "out_in_circ" | "in_elastic" | "out_elastic" | "in_out_elastic" | "out_in_elastic" | "in_back" | "out_back" | "in_out_back" | "out_in_back" | "in_bounce" | "out_bounce" | "in_out_bounce" | "out_in_bounce"
---@alias UndoGlow.EasingFn fun(opts: UndoGlow.EasingOpts): integer

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
---@field animation_type? UndoGlow.AnimationType
---@field easing? UndoGlow.EasingString | UndoGlow.EasingFn A easing string or function that computes easing.
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

M.easing = require("undo-glow.easing")
M.config = require("undo-glow.config")

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
		require("undo-glow.highlight").setup_highlight(
			target,
			highlight.hl,
			highlight.hl_color
		)
	end
end

------- Public API -------

--- Undo command that highlights.
---@param opts? UndoGlow.CommandOpts
function M.undo(opts)
	local commands = require("undo-glow.commands")
	return commands.undo(opts)
end

--- Redo command that highlights.
---@param opts? UndoGlow.CommandOpts
function M.redo(opts)
	local commands = require("undo-glow.commands")
	return commands.redo(opts)
end

--- Yank command that highlights.
--- For autocmd usage only.
---@param opts? UndoGlow.CommandOpts
function M.yank(opts)
	local commands = require("undo-glow.commands")
	return commands.yank(opts)
end

--- Paste below command with highlights.
---@param opts? UndoGlow.CommandOpts
function M.paste_below(opts)
	local commands = require("undo-glow.commands")
	return commands.paste_below(opts)
end

--- Paste above command with highlights.
---@param opts? UndoGlow.CommandOpts
function M.paste_above(opts)
	local commands = require("undo-glow.commands")
	return commands.paste_above(opts)
end

--- Search next command with highlights.
---@param opts? UndoGlow.CommandOpts
function M.search_next(opts)
	local commands = require("undo-glow.commands")
	return commands.search_next(opts)
end

--- Search prev command with highlights.
---@param opts? UndoGlow.CommandOpts
function M.search_prev(opts)
	local commands = require("undo-glow.commands")
	return commands.search_prev(opts)
end

--- Search prev command with highlights.
---@param opts? UndoGlow.CommandOpts
function M.search_star(opts)
	local commands = require("undo-glow.commands")
	return commands.search_star(opts)
end

--- Comment with `gc` in `n` and `x` mode with highlights.
--- Requires `expr` = true in ``vim.keymap.set`
---@param opts? UndoGlow.CommandOpts
function M.comment(opts)
	local commands = require("undo-glow.commands")
	return commands.comment(opts)
end

--- Comment with `gc` in `o` mode. E.g. gcip, gcap, etc with highlights.
---@param opts? UndoGlow.CommandOpts
function M.comment_textobject(opts)
	local commands = require("undo-glow.commands")
	return commands.comment_textobject(opts)
end

--- Comment lines with `gcc` with highlights.
--- Requires `expr` = true in ``vim.keymap.set`
---@param opts? UndoGlow.CommandOpts
function M.comment_line(opts)
	local commands = require("undo-glow.commands")
	return commands.comment_line(opts)
end

--- Core API to highlight changes in the current buffer.
---@param opts? UndoGlow.HighlightChanges|UndoGlow.CommandOpts
function M.highlight_changes(opts)
	local bufnr = vim.api.nvim_get_current_buf()

	local state = require("undo-glow.utils").create_state(opts)

	vim.api.nvim_buf_attach(bufnr, false, {
		on_bytes = function(...)
			return require("undo-glow.callback").on_bytes_wrapper(
				state,
				M.config,
				...
			)
		end,
	})
end

--- Core API to highlight a specified region in the current buffer.
--- @param opts UndoGlow.HighlightRegion
function M.highlight_region(opts)
	local bufnr = vim.api.nvim_get_current_buf()

	local state = require("undo-glow.utils").create_state(opts)

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

		require("undo-glow.utils").handle_highlight(handle_highlight_opts)
	end)
end

return M
