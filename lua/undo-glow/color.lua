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

-- Utility functions for color manipulation and easing
---@param hex string
---@return UndoGlow.RGBColor
function M.hex_to_rgb(hex)
	hex = hex:gsub("#", "")

	if #hex == 3 then
		return {
			r = tonumber(hex:sub(1, 1) .. hex:sub(1, 1), 16),
			g = tonumber(hex:sub(2, 2) .. hex:sub(2, 2), 16),
			b = tonumber(hex:sub(3, 3) .. hex:sub(3, 3), 16),
		}
	end

	return {
		r = tonumber(hex:sub(1, 2), 16),
		g = tonumber(hex:sub(3, 4), 16),
		b = tonumber(hex:sub(5, 6), 16),
	}
end
---@param rgb UndoGlow.RGBColor
---@return string
function M.rgb_to_hex(rgb)
	return string.format("#%02X%02X%02X", rgb.r, rgb.g, rgb.b)
end

---@param c1 UndoGlow.RGBColor
---@param c2 UndoGlow.RGBColor
---@param t number (0-1) Interpolation factor
---@return string
function M.blend_color(c1, c2, t)
	local r = math.floor(c1.r + (c2.r - c1.r) * t + 0.5)
	local g = math.floor(c1.g + (c2.g - c1.g) * t + 0.5)
	local b = math.floor(c1.b + (c2.b - c1.b) * t + 0.5)
	return M.rgb_to_hex({ r = r, g = g, b = b })
end

---@return string
function M.get_normal_bg()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
	if normal.bg then
		return string.format("#%06X", normal.bg)
	else
		return M.default_bg
	end
end

---@return string
function M.get_normal_fg()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
	if normal.fg then
		return string.format("#%06X", normal.fg)
	else
		return M.default_fg
	end
end

---@param current_hlgroup_detail vim.api.keyset.hl_info
---@return UndoGlow.HlColor
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
