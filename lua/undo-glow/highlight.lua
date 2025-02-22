local M = {}

---@param name string Highlight name
---@param color UndoGlow.HlColor
function M.set_highlight(name, color)
	if vim.fn.hlexists(name) == 0 then
		vim.api.nvim_set_hl(0, name, color)
	end
end

---@param from string Highlight name
---@param to string Highlight name
---@param color UndoGlow.HlColor
function M.link_highlight(from, to, color)
	local toHl = vim.api.nvim_get_hl(0, { name = to })

	local bg = color.bg
	local fg = color.fg

	if toHl.bg then
		bg = string.format("#%06X", toHl.bg)
	end

	if toHl.fg then
		fg = string.format("#%06X", toHl.fg)
	end

	M.set_highlight(from, {
		bg = bg,
		fg = fg,
	})
end

---@param target_hlgroup string
---@param config_hl string
---@param config_hl_color UndoGlow.HlColor
function M.setup_highlight(target_hlgroup, config_hl, config_hl_color)
	if config_hl ~= target_hlgroup then
		M.link_highlight(target_hlgroup, config_hl, config_hl_color)
	else
		M.set_highlight(config_hl, config_hl_color)
	end
end

---@param hlgroup string
---@return vim.api.keyset.hl_info
function M.resolve_hlgroup(hlgroup)
	local seen = {}
	while hlgroup do
		if seen[hlgroup] then
			break
		end
		seen[hlgroup] = true

		local hl = vim.api.nvim_get_hl(0, { name = hlgroup })
		if not hl.link then
			return hl
		end
		hlgroup = hl.link
	end
	return {}
end

return M
