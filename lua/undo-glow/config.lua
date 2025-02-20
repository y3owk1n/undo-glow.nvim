---@type UndoGlow.Config
local config = {
	duration = 500,
	animation = true,
	animation_type = "fade",
	easing = require("undo-glow.easing").ease_in_out_cubic,
	fps = 120,
	undo_hl = "UgUndo",
	redo_hl = "UgRedo",
	yank_hl = "UgYank",
	paste_below_hl = "UgPasteBelow",
	paste_above_hl = "UgPasteAbove",
	search_next_hl = "UgSearchNext",
	search_prev_hl = "UgSearchPrev",
	undo_hl_color = require("undo-glow.color").default_undo,
	redo_hl_color = require("undo-glow.color").default_redo,
	yank_hl_color = require("undo-glow.color").default_yank,
	paste_below_hl_color = require("undo-glow.color").default_paste_below,
	paste_above_hl_color = require("undo-glow.color").default_paste_above,
	search_next_hl_color = require("undo-glow.color").default_search_next,
	search_prev_hl_color = require("undo-glow.color").default_search_prev,
}

return config
