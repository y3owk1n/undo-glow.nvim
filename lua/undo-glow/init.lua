local M = {}

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
		cursor = true,
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
		cursor = "UgCursor",
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

--- re-exports all easing functions
M.easing = require("undo-glow.easing")

--- re-exports animate_start function only
M.animate_start = require("undo-glow.animation").animate_start

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

--- Cursor move command that highlights.
--- For autocmd usage only.
---@param opts? UndoGlow.CommandOpts
function M.cursor_moved(opts)
	local commands = require("undo-glow.commands")
	return commands.cursor_moved(opts)
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
