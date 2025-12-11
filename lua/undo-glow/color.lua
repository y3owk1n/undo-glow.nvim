---@mod undo-glow.nvim.color Color utilities
---@brief [[
---
---Color conversion and manipulation utilities with caching.
---
---@brief ]]

local M = {}

-- Color caches for performance optimization
local hex_to_rgb_cache = {}
local rgb_to_hex_cache = {}
local rgb_to_hsl_cache = {}
local hsl_to_rgb_cache = {}

-- Cache size limits to prevent memory leaks
local MAX_CACHE_SIZE = 1000

M.default_bg = "#000000"
M.default_fg = "#FFFFFF"
M.default_undo = { bg = "#FF5555" } -- Red
M.default_redo = { bg = "#50FA7B" } -- Green
M.default_yank = { bg = "#F1FA8C" } -- Yellow
M.default_paste = { bg = "#8BE9FD" } -- Cyan
M.default_search = { bg = "#BD93F9" } -- Purple
M.default_comment = { bg = "#FFB86C" } -- Orange
M.default_cursor = { bg = "#FF79C6" } -- Magenta

---Update cache size limit from configuration
---@param size number
function M.set_cache_size(size)
	MAX_CACHE_SIZE = size
end

---Helper function to create a cache key from a table
---@param tbl table The table to create a key from
---@return string cache_key The cache key
local function table_to_key(tbl)
	if not tbl then
		return "nil"
	end
	local parts = {}
	for k, v in pairs(tbl) do
		table.insert(parts, string.format("%s=%s", k, v))
	end
	table.sort(parts)
	return table.concat(parts, "|")
end

---Helper function to limit cache size
---@param cache table The cache table to limit
local function limit_cache_size(cache)
	local count = 0
	for _ in pairs(cache) do
		count = count + 1
	end
	if count > MAX_CACHE_SIZE then
		-- Clear half the cache when it gets too large
		local to_remove = {}
		local i = 1
		for k in pairs(cache) do
			if i % 2 == 0 then
				table.insert(to_remove, k)
			end
			i = i + 1
		end
		for _, k in ipairs(to_remove) do
			cache[k] = nil
		end
	end
end

---Converts a hexadecimal color string to an RGB table.
---Examples: "#FFF" or "#FFFFFF"
---@param hex string The hexadecimal color string.
---@return UndoGlow.RGBColor rgb_color The RGB representation of the hex color.
function M.hex_to_rgb(hex)
	-- Check cache first
	if hex_to_rgb_cache[hex] then
		local api = require("undo-glow.api")
		api.emit("color_cache_hit", {
			operation = "hex_to_rgb",
			input = hex,
			cached = true,
		})
		return hex_to_rgb_cache[hex]
	end

	local api = require("undo-glow.api")
	api.emit("color_conversion", {
		operation = "hex_to_rgb",
		input = hex,
	})

	local clean_hex = hex:gsub("#", "")
	local rgb_color

	local success, err = pcall(function()
		if #clean_hex == 3 then
			rgb_color = {
				r = tonumber(clean_hex:sub(1, 1) .. clean_hex:sub(1, 1), 16),
				g = tonumber(clean_hex:sub(2, 2) .. clean_hex:sub(2, 2), 16),
				b = tonumber(clean_hex:sub(3, 3) .. clean_hex:sub(3, 3), 16),
			}
		else
			rgb_color = {
				r = tonumber(clean_hex:sub(1, 2), 16),
				g = tonumber(clean_hex:sub(3, 4), 16),
				b = tonumber(clean_hex:sub(5, 6), 16),
			}
		end
	end)

	if not success then
		api.call_hook("on_error", {
			operation = "hex_to_rgb_conversion",
			error = err,
			input = hex,
		})
		return { r = 0, g = 0, b = 0 }
	end

	-- Cache the result
	hex_to_rgb_cache[hex] = rgb_color
	limit_cache_size(hex_to_rgb_cache)

	return rgb_color
end

---Converts an RGB table to a hexadecimal color string.
---@param rgb UndoGlow.RGBColor The RGB color table.
---@return string hex_code The hexadecimal representation of the color.
function M.rgb_to_hex(rgb)
	local cache_key = table_to_key(rgb)

	-- Check cache first
	if rgb_to_hex_cache[cache_key] then
		return rgb_to_hex_cache[cache_key]
	end

	local hex_code = string.format("#%02X%02X%02X", rgb.r, rgb.g, rgb.b)

	-- Cache the result
	rgb_to_hex_cache[cache_key] = hex_code
	limit_cache_size(rgb_to_hex_cache)

	return hex_code
end

---Converts an RGB table to an HSL table.
---@param rgb UndoGlow.RGBColor The RGB color table.
---@return UndoGlow.HSLColor hsl_color The HSL representation (h in degrees, s and l as fractions).
function M.rgb_to_hsl(rgb)
	local cache_key = table_to_key(rgb)

	-- Check cache first
	if rgb_to_hsl_cache[cache_key] then
		return rgb_to_hsl_cache[cache_key]
	end

	local r = rgb.r / 255
	local g = rgb.g / 255
	local b = rgb.b / 255

	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h, s, l = 0, 0, (max + min) / 2

	if max == min then
		-- Achromatic case: no hue or saturation.
		h = 0
		s = 0
	else
		local d = max - min
		if l > 0.5 then
			s = d / (2 - max - min)
		else
			s = d / (max + min)
		end

		if max == r then
			h = (g - b) / d + (g < b and 6 or 0)
		elseif max == g then
			h = (b - r) / d + 2
		else -- max == b
			h = (r - g) / d + 4
		end
		h = h * 60
	end

	local hsl_color = { h = h, s = s, l = l }

	-- Cache the result
	rgb_to_hsl_cache[cache_key] = hsl_color
	limit_cache_size(rgb_to_hsl_cache)

	return hsl_color
end

---Converts an HSL table to an RGB table.
---@param hsl UndoGlow.HSLColor The HSL color table (h in degrees, s and l as fractions).
---@return UndoGlow.RGBColor rgb The RGB representation of the color.
function M.hsl_to_rgb(hsl)
	local h, s, l = hsl.h, hsl.s, hsl.l

	local r, g, b

	if s == 0 then
		-- Achromatic: r, g, and b are equal.
		r = l
		g = l
		b = l
	else
		local function hue2rgb(p, q, t)
			if t < 0 then
				t = t + 1
			end
			if t > 1 then
				t = t - 1
			end
			if t < 1 / 6 then
				return p + (q - p) * 6 * t
			end
			if t < 1 / 2 then
				return q
			end
			if t < 2 / 3 then
				return p + (q - p) * (2 / 3 - t) * 6
			end
			return p
		end

		local q = l < 0.5 and (l * (1 + s)) or (l + s - l * s)
		local p = 2 * l - q
		local h_norm = h / 360

		r = hue2rgb(p, q, h_norm + 1 / 3)
		g = hue2rgb(p, q, h_norm)
		b = hue2rgb(p, q, h_norm - 1 / 3)
	end

	local rgb = {
		r = math.floor(r * 255 + 0.5),
		g = math.floor(g * 255 + 0.5),
		b = math.floor(b * 255 + 0.5),
	}

	return rgb
end

---Blends two RGB colors together based on an interpolation factor.
---@param c1 UndoGlow.RGBColor The starting color.
---@param c2 UndoGlow.RGBColor The ending color.
---@param t number (0-1) Interpolation factor.
---@return string hex_code The blended color as a hexadecimal string.
function M.blend_color(c1, c2, t)
	local r = math.floor(c1.r + (c2.r - c1.r) * t + 0.5)
	local g = math.floor(c1.g + (c2.g - c1.g) * t + 0.5)
	local b = math.floor(c1.b + (c2.b - c1.b) * t + 0.5)

	local hex_code = M.rgb_to_hex({ r = r, g = g, b = b })

	return hex_code
end

---Retrieves the Normal highlight group's background color.
---@return string hex_code The Normal highlight group's background color as a hexadecimal string.
function M.get_normal_bg()
	local success, normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal" })
	local fallback =
		require("undo-glow.config").config.fallback_for_transparency

	if not success or not normal.bg then
		return (fallback and fallback.bg) or M.default_bg
	end

	return string.format("#%06X", normal.bg)
end

---Retrieves the Normal highlight group's foreground color.
---@return string hex_code The Normal highlight group's foreground color as a hexadecimal string.
function M.get_normal_fg()
	local success, normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal" })
	local fallback =
		require("undo-glow.config").config.fallback_for_transparency

	if not success or not normal.fg then
		return (fallback and fallback.fg) or M.default_fg
	end

	return string.format("#%06X", normal.fg)
end

---Initializes colors based on the current highlight group details.
---@param current_hlgroup_detail vim.api.keyset.hl_info The current highlight group details.
---@return UndoGlow.HlColor colors The initial colors table containing bg and fg.
function M.init_colors(current_hlgroup_detail)
	local init_color = {
		bg = nil,
		fg = nil,
	}

	if not current_hlgroup_detail.bg then
		init_color.bg = M.default_undo.bg
	else
		init_color.bg = string.format("#%06X", current_hlgroup_detail.bg)
	end

	if not current_hlgroup_detail.fg then
		init_color.fg = nil
	else
		init_color.fg = string.format("#%06X", current_hlgroup_detail.fg)
	end

	return init_color
end

return M
