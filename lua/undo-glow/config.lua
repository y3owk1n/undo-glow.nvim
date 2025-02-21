---@type UndoGlow.Config
local config = {
	duration = 500,
	animation = true,
	animation_type = "fade",
	easing = require("undo-glow.easing").ease_in_out_cubic,
	fps = 120,
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
		paste_below = {
			hl = "UgPasteBelow",
			hl_color = require("undo-glow.color").default_paste_below,
		},
		paste_above = {
			hl = "UgPasteAbove",
			hl_color = require("undo-glow.color").default_paste_above,
		},
		search_next = {
			hl = "UgSearchNext",
			hl_color = require("undo-glow.color").default_search_next,
		},
		search_prev = {
			hl = "UgSearchPrev",
			hl_color = require("undo-glow.color").default_search_prev,
		},
	},
}

return config
