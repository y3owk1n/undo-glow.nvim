local M = {}

---@class UndoGlow.Config
---@field duration number In ms
---@field animation boolean
---@field easing function A function that takes a number (0-1) and returns a number (0-1) for easing.
---@field fps number
---@field undo_hl string If not "UgUndo" then copy the to color to UgUndo or fallback to default
---@field redo_hl string If not "UgRedo" then copy the to color to UgRedo or fallback to default
---@field undo_hl_color? UndoGlow.HlColor
---@field redo_hl_color? UndoGlow.HlColor

---@class UndoGlow.HlColor
---@field bg string
---@field fg? string

---@class UndoGlow.State
---@field current_hlgroup string
---@field should_detach boolean

---@class UndoGlow.RGBColor
---@field r integer Red (0-255)
---@field g integer Green (0-255)
---@field b integer Blue (0-255)

---@class UndoGlow.AttachAndRunOpts
---@field hlgroup string
---@field cmd? function

M.config = require("undo-glow.config")
M.easing = require("undo-glow.easing")

local highlights = require("undo-glow.highlight")
local callback = require("undo-glow.callback")

-- Helper to attach to a buffer with a local state.
---@param opts UndoGlow.AttachAndRunOpts
function M.attach_and_run(opts)
	local bufnr = vim.api.nvim_get_current_buf()

	---@type UndoGlow.State
	local state = { should_detach = false, current_hlgroup = opts.hlgroup }

	vim.api.nvim_buf_attach(bufnr, false, {
		on_bytes = function(...)
			return callback.on_bytes_wrapper(state, M.config, ...)
		end,
	})

	if opts.cmd then
		opts.cmd()
	end
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
