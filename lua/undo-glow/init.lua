---@module "undo-glow"

local M = {}

M.config = require("undo-glow.config")

---Setup function for undo-glow.
---Merges the user configuration with the default configuration and sets up the highlights.
---@param user_config? UndoGlow.Config Optional user configuration.
---@return nil
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

---Easing functions that are builtin.
M.easing = require("undo-glow.easing")

---Start animation function.
M.animate_start = require("undo-glow.animation").animate_start

---Undo command that highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.undo(opts)
	local commands = require("undo-glow.commands")
	return commands.undo(opts)
end

---Redo command that highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.redo(opts)
	local commands = require("undo-glow.commands")
	return commands.redo(opts)
end

---Yank command that highlights.
---For autocmd usage only.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.yank(opts)
	local commands = require("undo-glow.commands")
	return commands.yank(opts)
end

---Paste below command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.paste_below(opts)
	local commands = require("undo-glow.commands")
	return commands.paste_below(opts)
end

---Paste above command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.paste_above(opts)
	local commands = require("undo-glow.commands")
	return commands.paste_above(opts)
end

---Highlight current line after a search is performed.
---For autocmd usage only.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.search_cmd(opts)
	local commands = require("undo-glow.commands")
	return commands.search_cmd(opts)
end

---Search next command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.search_next(opts)
	local commands = require("undo-glow.commands")
	return commands.search_next(opts)
end

---Search prev command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.search_prev(opts)
	local commands = require("undo-glow.commands")
	return commands.search_prev(opts)
end

---Search star (*) command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.search_star(opts)
	local commands = require("undo-glow.commands")
	return commands.search_star(opts)
end

---Search star (#) command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.search_hash(opts)
	local commands = require("undo-glow.commands")
	return commands.search_hash(opts)
end

---Comment with `gc` in `n` and `x` mode with highlights.
---Requires `expr` = true in ``vim.keymap.set`
---@param opts? UndoGlow.CommandOpts Optional command option
---@return string|nil expression String for expression and nil for non-expression
function M.comment(opts)
	local commands = require("undo-glow.commands")
	return commands.comment(opts)
end

---Comment with `gc` in `o` mode. E.g. gcip, gcap, etc with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.comment_textobject(opts)
	local commands = require("undo-glow.commands")
	return commands.comment_textobject(opts)
end

---Comment lines with `gcc` with highlights.
---Requires `expr` = true in ``vim.keymap.set`
---@param opts? UndoGlow.CommandOpts Optional command option
---@return string expression String for expression
function M.comment_line(opts)
	local commands = require("undo-glow.commands")
	return commands.comment_line(opts)
end

---Cursor move command that highlights.
---For autocmd usage only.
---@param opts? UndoGlow.CommandOpts Optional command option
---@param ignored_ft? table<string> Optional filetypes to ignore
---@param steps_to_trigger? number Optional number of steps to trigger
---@return nil
function M.cursor_moved(opts, ignored_ft, steps_to_trigger)
	local commands = require("undo-glow.commands")
	return commands.cursor_moved(opts, ignored_ft, steps_to_trigger)
end

---Core API to highlight changes in the current buffer.
---@param opts? UndoGlow.HighlightChanges|UndoGlow.CommandOpts
---@return nil
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

---Core API to highlight a specified region in the current buffer.
---@param opts UndoGlow.HighlightRegion
---@return nil
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
