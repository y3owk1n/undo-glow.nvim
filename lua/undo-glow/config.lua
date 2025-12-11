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
---	performance = {
---		color_cache_size = 1000, -- Maximum cached color conversions
---		debounce_delay = 50, -- Milliseconds to debounce rapid operations
---		animation_skip_unchanged = true, -- Skip redraws when highlights haven't changed
---	},
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
	performance = {
		-- Color conversion caching
		color_cache_size = 1000, -- Maximum cached color conversions
		-- Debouncing settings
		debounce_delay = 50, -- Milliseconds to debounce rapid operations
		-- Animation optimization
		animation_skip_unchanged = true, -- Skip redraws when highlights haven't changed
	},
}

---@private
---Validates user configuration
---@param user_config UndoGlow.Config
---@return boolean
local function validate_config(user_config)
	local validate = require("undo-glow.validate")

	-- Validate animation config
	if
		user_config.animation
		and not validate.validate_animation_config(user_config.animation)
	then
		return false
	end

	-- Validate highlights config
	if
		user_config.highlights
		and not validate.validate_highlight_config(user_config.highlights)
	then
		return false
	end

	-- Validate priority
	if
		user_config.priority ~= nil
		and not validate.is_number(user_config.priority, "priority", 0, 65535)
	then
		return false
	end

	return true
end

---@private
---Setup function for undo-glow.
---Merges the user configuration with the default configuration and sets up the highlights.
---@param user_config? UndoGlow.Config Optional user configuration.
---@return nil
function M.setup(user_config)
	user_config = user_config or {}

	-- Validate user config before merging
	if not validate_config(user_config) then
		require("undo-glow.log").error("Invalid configuration provided. Using defaults.")
		M.config = vim.tbl_deep_extend("force", {}, defaults)
		return
	end

	M.config = vim.tbl_deep_extend("force", defaults, user_config)

	-- Apply performance settings
	if M.config.performance then
		local color = require("undo-glow.color")
		local debounce = require("undo-glow.debounce")

		if M.config.performance.color_cache_size then
			color.set_cache_size(M.config.performance.color_cache_size)
		end

		if M.config.performance.debounce_delay then
			debounce.set_default_delay(M.config.performance.debounce_delay)
		end
	end

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
