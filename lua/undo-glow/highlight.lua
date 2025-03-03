local M = {}

local hl_exists_cache = {}
local resolved_hl_cache = {}
local MAX_CACHE_SIZE = 100

---Check if a highlight exists with caching
---@param name string The name of the highlight group
---@return boolean exists Whether the highlight exists
local function hl_exists(name)
	if hl_exists_cache[name] == nil then
		hl_exists_cache[name] = (vim.fn.hlexists(name) == 1)

		if vim.tbl_count(hl_exists_cache) > MAX_CACHE_SIZE then
			hl_exists_cache = {}
			hl_exists_cache[name] = (vim.fn.hlexists(name) == 1)
		end
	end
	return hl_exists_cache[name]
end

---Sets a highlight group if it does not exist.
---@param name string The name of the highlight group.
---@param color UndoGlow.HlColor The highlight color options (bg, fg, etc.).
function M.set_highlight(name, color)
	if not hl_exists(name) then
		vim.api.nvim_set_hl(0, name, color)
		hl_exists_cache[name] = true

		if resolved_hl_cache[name] then
			resolved_hl_cache[name] = nil
		end
	end
end

---Links one highlight group to another by fetching the target group's colors.
---If the target highlight group defines colors, they are formatted and applied to the source.
---@param from string The source highlight group name.
---@param to string The target highlight group name.
---@param color UndoGlow.HlColor The default color settings.
function M.link_highlight(from, to, color)
	local success, toHl = pcall(vim.api.nvim_get_hl, 0, { name = to })

	if not success or not toHl then
		M.set_highlight(from, color)
		return
	end

	local new_color = {
		bg = toHl.bg and string.format("#%06X", toHl.bg) or color.bg,
		fg = toHl.fg and string.format("#%06X", toHl.fg) or color.fg,
	}

	M.set_highlight(from, new_color)

	if resolved_hl_cache[from] then
		resolved_hl_cache[from] = nil
	end
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

	hl_exists_cache[target_hlgroup] = true
	hl_exists_cache[config_hl] = true
	resolved_hl_cache[target_hlgroup] = nil
	resolved_hl_cache[config_hl] = nil
end

---Resolves a highlight group by following its links until a concrete definition is found.
---@param hlgroup string The starting highlight group name.
---@return vim.api.keyset.hl_info resolved_hl_info The final resolved highlight group details.
function M.resolve_hlgroup(hlgroup)
	if resolved_hl_cache[hlgroup] then
		return vim.deepcopy(resolved_hl_cache[hlgroup])
	end

	local seen = {}
	local current_group = hlgroup

	while current_group do
		if seen[current_group] then
			break
		end
		seen[current_group] = true

		local success, hl =
			pcall(vim.api.nvim_get_hl, 0, { name = current_group })

		if not success or not hl then
			break
		end

		if not hl.link then
			resolved_hl_cache[hlgroup] = hl

			if vim.tbl_count(resolved_hl_cache) > MAX_CACHE_SIZE then
				local preserved = {}
				local count = 0
				for k, v in pairs(resolved_hl_cache) do
					if count < MAX_CACHE_SIZE / 2 then
						preserved[k] = v
						count = count + 1
					else
						break
					end
				end
				resolved_hl_cache = preserved
				resolved_hl_cache[hlgroup] = hl
			end

			return vim.deepcopy(hl)
		end

		current_group = hl.link
	end

	local empty_result = {}
	resolved_hl_cache[hlgroup] = empty_result
	return empty_result
end

return M
