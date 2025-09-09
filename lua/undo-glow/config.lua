---@mod undo-glow.nvim.config Configurations
---@brief [[
---
---Example Configuration:
---
--->
---{
---	animation = {
---		enabled = false,
---		duration = 100,
---		animation_type = "fade",
---		fps = 120,
---		easing = "in_out_cubic",
---		window_scoped = false,
---	},
---	fallback_for_transparency = {
---		bg = "#000000",
---		fg = "#FFFFFF",
---	},
---	highlights = {
---		undo = {
---			hl = "UgUndo",
---			hl_color = require("undo-glow.color").default_undo,
---		},
---		redo = {
---			hl = "UgRedo",
---			hl_color = require("undo-glow.color").default_redo,
---		},
---		yank = {
---			hl = "UgYank",
---			hl_color = require("undo-glow.color").default_yank,
---		},
---		paste = {
---			hl = "UgPaste",
---			hl_color = require("undo-glow.color").default_paste,
---		},
---		search = {
---			hl = "UgSearch",
---			hl_color = require("undo-glow.color").default_search,
---		},
---		comment = {
---			hl = "UgComment",
---			hl_color = require("undo-glow.color").default_comment,
---		},
---		cursor = {
---			hl = "UgCursor",
---			hl_color = require("undo-glow.color").default_cursor,
---		},
---	},
---	priority = 4096, -- so that it will work with render-markdown.nvim
---}
---<
---
---@brief ]]

local M = {}

---User-provided config, merged with defaults
---@type UndoGlow.Config
M.config = {}

---@private
---@type UndoGlow.Config
local defaults = {
	animation = {
		enabled = false,
		duration = 100,
		animation_type = "fade",
		fps = 120,
		easing = "in_out_cubic",
		window_scoped = false,
	},
	fallback_for_transparency = {},
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

---@private
---Setup function for undo-glow.
---Merges the user configuration with the default configuration and sets up the highlights.
---@param user_config? UndoGlow.Config Optional user configuration.
---@return nil
function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", defaults, user_config or {})

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

return M
