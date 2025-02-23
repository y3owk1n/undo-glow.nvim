---@type UndoGlow.Config
local config = {
	duration = 500,
	animation = true,
	animation_type = "fade",
	easing = require("undo-glow.easing").in_out_cubic,
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
	},
}

return config
