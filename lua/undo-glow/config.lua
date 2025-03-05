---@type UndoGlow.Config
local config = {
	animation = {
		enabled = false,
		duration = 100,
		animation_type = "fade",
		fps = 120,
		easing = "in_out_cubic",
		window_scoped = false,
	},
	highlights = {
		undo = {
			hl = "UgUndo",
			hl_color = require("undo-glow.color").default_undo,
		},
		redo = {
			hl = "UgRedo",
			hl_color = require("undo-glow.color").default_redo,
		},
		yank = {
			hl = "UgYank",
			hl_color = require("undo-glow.color").default_yank,
		},
		paste = {
			hl = "UgPaste",
			hl_color = require("undo-glow.color").default_paste,
		},
		search = {
			hl = "UgSearch",
			hl_color = require("undo-glow.color").default_search,
		},
		comment = {
			hl = "UgComment",
			hl_color = require("undo-glow.color").default_comment,
		},
		cursor = {
			hl = "UgCursor",
			hl_color = require("undo-glow.color").default_cursor,
		},
	},
	priority = 4096, -- so that it will work with render-markdown.nvim
}

return config
