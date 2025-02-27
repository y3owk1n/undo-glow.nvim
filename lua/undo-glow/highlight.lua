local M = {}

---Sets a highlight group if it does not exist.
---@param name string The name of the highlight group.
---@param color UndoGlow.HlColor The highlight color options (bg, fg, etc.).
function M.set_highlight(name, color)
	if vim.fn.hlexists(name) == 0 then
		vim.api.nvim_set_hl(0, name, color)
	end
end

---Links one highlight group to another by fetching the target group's colors.
---If the target highlight group defines colors, they are formatted and applied to the source.
---@param from string The source highlight group name.
---@param to string The target highlight group name.
---@param color UndoGlow.HlColor The default color settings.
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

---Sets up a highlight group based on configuration.
---If the configured highlight group differs from the target, the groups are linked;
---otherwise, the highlight is set directly.
---@param target_hlgroup string The target highlight group name.
---@param config_hl string The configured highlight group name.
---@param config_hl_color UndoGlow.HlColor The configured highlight color options.
function M.setup_highlight(target_hlgroup, config_hl, config_hl_color)
	if config_hl ~= target_hlgroup then
		M.link_highlight(target_hlgroup, config_hl, config_hl_color)
	else
		M.set_highlight(config_hl, config_hl_color)
	end
end

---Resolves a highlight group by following its links until a concrete definition is found.
---@param hlgroup string The starting highlight group name.
---@return vim.api.keyset.hl_info resolved_hl_info The final resolved highlight group details.
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
