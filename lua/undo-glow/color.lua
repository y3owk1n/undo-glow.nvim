local M = {}

M.default_bg = "#000000"
M.default_fg = "#FFFFFF"
M.default_undo = { bg = "#FF5555" } -- Red
M.default_redo = { bg = "#50FA7B" } -- Green
M.default_yank = { bg = "#F1FA8C" } -- Yellow
M.default_paste = { bg = "#8BE9FD" } -- Cyan
M.default_search = { bg = "#BD93F9" } -- Purple
M.default_comment = { bg = "#FFB86C" } -- Orange
M.default_cursor = { bg = "#FF79C6" } -- Magenta

local hex_to_rgb_cache = {}
local rgb_to_hex_cache = {}
local rgb_to_hsl_cache = {}
local hsl_to_rgb_cache = {}
local blend_color_cache = {}
local normal_bg_cache = nil
local normal_fg_cache = nil

local MAX_CACHE_SIZE = 100

function M.clear_cache()
	hex_to_rgb_cache = {}
	rgb_to_hex_cache = {}
	rgb_to_hsl_cache = {}
	hsl_to_rgb_cache = {}
	blend_color_cache = {}
	normal_bg_cache = nil
	normal_fg_cache = nil
end

---Converts a hexadecimal color string to an RGB table.
---Examples: "#FFF" or "#FFFFFF"
---@param hex string The hexadecimal color string.
---@return UndoGlow.RGBColor rgb_color The RGB representation of the hex color.
function M.hex_to_rgb(hex)
	if hex_to_rgb_cache[hex] then
		return hex_to_rgb_cache[hex]
	end

	local clean_hex = hex:gsub("#", "")
	local result

	if #clean_hex == 3 then
		result = {
			r = tonumber(clean_hex:sub(1, 1) .. clean_hex:sub(1, 1), 16),
			g = tonumber(clean_hex:sub(2, 2) .. clean_hex:sub(2, 2), 16),
			b = tonumber(clean_hex:sub(3, 3) .. clean_hex:sub(3, 3), 16),
		}
	else
		result = {
			r = tonumber(clean_hex:sub(1, 2), 16),
			g = tonumber(clean_hex:sub(3, 4), 16),
			b = tonumber(clean_hex:sub(5, 6), 16),
		}
	end

	hex_to_rgb_cache[hex] = result
	if vim.tbl_count(hex_to_rgb_cache) > MAX_CACHE_SIZE then
		hex_to_rgb_cache = {}
		hex_to_rgb_cache[hex] = result
	end

	return hex_to_rgb_cache[hex]
end

---Converts an RGB table to a hexadecimal color string.
---@param rgb UndoGlow.RGBColor The RGB color table.
---@return string hex_code The hexadecimal representation of the color.
function M.rgb_to_hex(rgb)
	local key = string.format("%d,%d,%d", rgb.r, rgb.g, rgb.b)

	if rgb_to_hex_cache[key] then
		return rgb_to_hex_cache[key]
	end

	local hex_code = string.format("#%02X%02X%02X", rgb.r, rgb.g, rgb.b)

	rgb_to_hex_cache[key] = hex_code
	if vim.tbl_count(rgb_to_hex_cache) > MAX_CACHE_SIZE then
		rgb_to_hex_cache = {}
		rgb_to_hex_cache[key] = hex_code
	end

	return rgb_to_hex_cache[key]
end

---Converts an RGB table to an HSL table.
---@param rgb UndoGlow.RGBColor The RGB color table.
---@return UndoGlow.HSLColor hsl_color The HSL representation (h in degrees, s and l as fractions).
function M.rgb_to_hsl(rgb)
	local key = string.format("%d,%d,%d", rgb.r, rgb.g, rgb.b)
	if rgb_to_hsl_cache[key] then
		return rgb_to_hsl_cache[key]
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

	local result = { h = h, s = s, l = l }

	rgb_to_hsl_cache[key] = result
	if vim.tbl_count(rgb_to_hsl_cache) > MAX_CACHE_SIZE then
		rgb_to_hsl_cache = {}
		rgb_to_hsl_cache[key] = result
	end

	return rgb_to_hsl_cache[key]
end

---Converts an HSL table to an RGB table.
---@param hsl UndoGlow.HSLColor The HSL color table (h in degrees, s and l as fractions).
---@return UndoGlow.RGBColor rgb The RGB representation of the color.
function M.hsl_to_rgb(hsl)
	local h, s, l = hsl.h, hsl.s, hsl.l

	local key = string.format("%.3f,%.3f,%.3f", h, s, l)
	if hsl_to_rgb_cache[key] then
		return hsl_to_rgb_cache[key]
	end

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

	local result = {
		r = math.floor(r * 255 + 0.5),
		g = math.floor(g * 255 + 0.5),
		b = math.floor(b * 255 + 0.5),
	}
	hsl_to_rgb_cache[key] = result
	if vim.tbl_count(hsl_to_rgb_cache) > MAX_CACHE_SIZE then
		hsl_to_rgb_cache = {}
		hsl_to_rgb_cache[key] = result
	end

	return hsl_to_rgb_cache[key]
end

---Blends two RGB colors together based on an interpolation factor.
---@param c1 UndoGlow.RGBColor The starting color.
---@param c2 UndoGlow.RGBColor The ending color.
---@param t number (0-1) Interpolation factor.
---@return string hex_code The blended color as a hexadecimal string.
function M.blend_color(c1, c2, t)
	local key = string.format(
		"%d,%d,%d|%d,%d,%d|%.3f",
		c1.r,
		c1.g,
		c1.b,
		c2.r,
		c2.g,
		c2.b,
		t
	)

	if blend_color_cache[key] then
		return blend_color_cache[key]
	end

	local r = math.floor(c1.r + (c2.r - c1.r) * t + 0.5)
	local g = math.floor(c1.g + (c2.g - c1.g) * t + 0.5)
	local b = math.floor(c1.b + (c2.b - c1.b) * t + 0.5)

	local hex_code = M.rgb_to_hex({ r = r, g = g, b = b })

	blend_color_cache[key] = hex_code
	if vim.tbl_count(blend_color_cache) > MAX_CACHE_SIZE then
		blend_color_cache = {}
		blend_color_cache[key] = hex_code
	end

	return blend_color_cache[key]
end

---Retrieves the Normal highlight group's background color.
---@return string hex_code The Normal highlight group's background color as a hexadecimal string.
function M.get_normal_bg()
	if normal_bg_cache then
		return normal_bg_cache
	end

	local success, normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal" })

	if not success or not normal.bg then
		normal_bg_cache = M.default_bg
		return normal_bg_cache
	end

	normal_bg_cache = string.format("#%06X", normal.bg)
	return normal_bg_cache
end

---Retrieves the Normal highlight group's foreground color.
---@return string hex_code The Normal highlight group's foreground color as a hexadecimal string.
function M.get_normal_fg()
	if normal_fg_cache then
		return normal_fg_cache
	end

	local success, normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal" })

	if not success or not normal.fg then
		normal_fg_cache = M.default_fg
		return normal_fg_cache
	end

	normal_fg_cache = string.format("#%06X", normal.fg)
	return normal_fg_cache
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
