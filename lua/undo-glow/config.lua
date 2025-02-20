local config = {
	duration = 500,
	animation = true,
	easing = require("undo-glow.easing").ease_in_out_cubic,
	fps = 120,
	undo_hl = "UgUndo",
	redo_hl = "UgRedo",
	undo_hl_color = require("undo-glow.color").default_undo,
	redo_hl_color = require("undo-glow.color").default_redo,
}

return config
