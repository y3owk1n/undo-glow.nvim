local M = {}

---@param t number (0-1) Interpolation factor
---@return number
function M.ease_out_quad(t)
	return 1 - (1 - t) * (1 - t)
end

---@param t number (0-1) Interpolation factor
---@return number
function M.ease_in_out_cubic(t)
	if t < 0.5 then
		return 4 * t * t * t
	else
		return 1 - math.pow(-2 * t + 2, 3) / 2
	end
end

---@param t number (0-1) Interpolation factor
---@return number
function M.ease_out_cubic(t)
	return 1 - math.pow(1 - t, 3)
end

---@param t number (0-1) Interpolation factor
---@return number
function M.ease_in_sine(t)
	return 1 - math.cos((t * math.pi) / 2)
end

return M
