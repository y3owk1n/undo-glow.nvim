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
	logging = {
		-- Log level: "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "OFF"
		level = "INFO", -- Default log level
		-- Output destinations
		notify = true, -- Show logs in Neovim notifications
		file = false, -- Write logs to file
		file_path = nil, -- Custom log file path (auto-generated if nil)
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

	-- Call pre-config hook
	local api = require("undo-glow.api")
	api.call_hook(
		"on_config_change",
		{ phase = "pre", user_config = user_config }
	)

	-- Validate user config before merging
	if not validate_config(user_config) then
		require("undo-glow.log").error(
			"Invalid configuration provided. Using defaults."
		)
		M.config = vim.tbl_deep_extend("force", {}, defaults)

		-- Emit config error event
		api.emit(
			"config_error",
			{ reason = "validation_failed", user_config = user_config }
		)
		return
	end

	local old_config = M.config
	M.config = vim.tbl_deep_extend("force", defaults, user_config)

	-- Configure logging outputs
	if M.config.logging then
		local log = require("undo-glow.log")
		log.set_outputs(
			M.config.logging.notify,
			M.config.logging.file,
			M.config.logging.file and M.config.logging.file_path or nil
		)
		if M.config.logging.level then
			local level_map = {
				TRACE = log.levels.TRACE,
				DEBUG = log.levels.DEBUG,
				INFO = log.levels.INFO,
				WARN = log.levels.WARN,
				ERROR = log.levels.ERROR,
				OFF = log.levels.OFF,
			}
			log.set_level(
				level_map[M.config.logging.level:upper()] or log.levels.INFO
			)
		end
	end

	-- Emit config change event
	api.emit(
		"config_changed",
		{ old_config = old_config, new_config = M.config }
	)

	-- Apply performance settings with validation
	if M.config.performance then
		local color = require("undo-glow.color")
		local debounce = require("undo-glow.debounce")

		-- Validate and apply color cache size
		local cache_size = M.config.performance.color_cache_size
		if cache_size and type(cache_size) == "number" and cache_size > 0 then
			color.set_cache_size(cache_size)
		end

		-- Validate and apply debounce delay
		local debounce_delay = M.config.performance.debounce_delay
		if
			debounce_delay
			and type(debounce_delay) == "number"
			and debounce_delay > 0
		then
			debounce.set_default_delay(debounce_delay)
		end
	end

	-- Apply logging settings with validation
	if M.config.logging then
		local log = require("undo-glow.log")
		local level_map = {
			TRACE = log.levels.TRACE,
			DEBUG = log.levels.DEBUG,
			INFO = log.levels.INFO,
			WARN = log.levels.WARN,
			ERROR = log.levels.ERROR,
			OFF = log.levels.OFF,
		}

		-- Validate and apply log level
		local level = M.config.logging.level
		if level and level_map[level] then
			log.set_level(level_map[level])
		end

		-- Configure output destinations with validation
		local notify = M.config.logging.notify
		local file = M.config.logging.file
		local file_path = M.config.logging.file_path

		log.set_outputs(
			notify ~= false, -- Default to true if not explicitly false
			file == true, -- Only enable file logging if explicitly true
			file_path -- Use provided path or default
		)
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

	-- Call post-config hook
	api.call_hook("on_config_change", { phase = "post", config = M.config })
end

return M
