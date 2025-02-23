--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
--

--[[
Disclaimer for Robert Penner's Easing Equations license:

TERMS OF USE - EASING EQUATIONS

Open source under the BSD License.

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local M = {}

local sin = math.sin
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt
local abs = math.abs
local asin = math.asin

---@param opts UndoGlow.EasingOpts
---@return integer
function M.linear(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	return c * t / d + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_quad(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d
	return c * t * t + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_quad(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d
	return -c * t * (t - 2) + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_out_quad(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_in_quad(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t < d / 2 then
		return M.out_quad({
			time = t * 2,
			begin = b,
			change = c / 2,
			duration = d,
		})
	else
		return M.in_quad({
			time = t * 2 - d,
			begin = b + c / 2,
			change = c / 2,
			duration = d,
		})
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_cubic(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d
	return c * t * t * t + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_cubic(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d - 1
	return c * (t * t * t + 1) + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_out_cubic(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t + b
	else
		t = t - 2
		return c / 2 * (t * t * t + 2) + b
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_in_cubic(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t < d / 2 then
		return M.out_cubic({
			time = t * 2,
			begin = b,
			change = c / 2,
			duration = d,
		})
	else
		return M.in_cubic({
			time = t * 2 - d,
			begin = b + c / 2,
			change = c / 2,
			duration = d,
		})
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_quart(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d
	return c * t ^ 4 + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_quart(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d - 1
	return -c * (t ^ 4 - 1) + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_out_quart(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d * 2
	if t < 1 then
		return c / 2 * t ^ 4 + b
	else
		t = t - 2
		return -c / 2 * (t ^ 4 - 2) + b
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_in_quart(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t < d / 2 then
		return M.out_quart({
			time = t * 2,
			begin = b,
			change = c / 2,
			duration = d,
		})
	else
		return M.in_quart({
			time = t * 2 - d,
			begin = b + c,
			change = c / 2,
			duration = d,
		})
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_quint(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d
	return c * t ^ 5 + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_quint(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d - 1
	return c * (t ^ 5 + 1) + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_out_quint(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d * 2
	if t < 1 then
		return c / 2 * t ^ 5 + b
	else
		t = t - 2
		return c / 2 * (t ^ 5 + 2) + b
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_in_quint(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t < d / 2 then
		return M.out_quint({
			time = t * 2,
			begin = b,
			change = c / 2,
			duration = d,
		})
	else
		return M.in_quint({
			time = t * 2 - d,
			begin = b + c / 2,
			change = c / 2,
			duration = d,
		})
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_sine(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	return -c * cos(t / d * (pi / 2)) + c + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_sine(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	return c * sin(t / d * (pi / 2)) + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_out_sine(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_in_sine(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t < d / 2 then
		return M.out_sine({
			time = t * 2,
			begin = b,
			change = c / 2,
			duration = d,
		})
	else
		return M.in_sine({
			time = t * 2 - d,
			begin = b + c / 2,
			change = c / 2,
			duration = d,
		})
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_expo(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t == 0 then
		return b or 0
	else
		return c * 2 ^ (10 * (t / d - 1)) + b - c * 0.001
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_expo(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t == d then
		return b + c
	else
		return c * 1.001 * (1 - 2 ^ (-10 * t / d)) + b
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_out_expo(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t == 0 then
		return b or 0
	end
	if t == d then
		return b + c
	end
	t = t / d * 2
	if t < 1 then
		return c / 2 * 2 ^ (10 * (t - 1)) + b - c * 0.0005
	else
		t = t - 1
		return c / 2 * 1.0005 * (2 - 2 ^ (-10 * t)) + b
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_in_expo(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t < d / 2 then
		return M.out_expo({
			time = t * 2,
			begin = b,
			change = c / 2,
			duration = d,
		})
	else
		return M.out_expo({
			time = t * 2 - d,
			begin = b + c / 2,
			change = c / 2,
			duration = d,
		})
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_circ(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d
	return -c * (sqrt(1 - t ^ 2) - 1) + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_circ(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d - 1
	return c * sqrt(1 - t ^ 2) + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_out_circ(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	t = t / d * 2
	if t < 1 then
		return -c / 2 * (sqrt(1 - t * t) - 1) + b
	else
		t = t - 2
		return c / 2 * (sqrt(1 - t * t) + 1) + b
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_in_circ(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t < d / 2 then
		return M.out_circ({
			time = t * 2,
			begin = b,
			change = c / 2,
			duration = d,
		})
	else
		return M.in_circ({
			time = (t * 2) - d,
			begin = b + c / 2,
			change = c / 2,
			duration = d,
		})
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_elastic(opts)
	local t, b, c, d, a, p =
		opts.time,
		opts.begin,
		opts.change,
		opts.duration,
		opts.amplitude,
		opts.period

	if t == 0 then
		return b or 0
	end

	t = t / d

	if t == 1 then
		return b + c
	end

	if not p then
		p = d * 0.3
	end

	local s

	if not a or a < abs(c or 1) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c / a)
	end

	t = t - 1

	return -(a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_elastic(opts)
	local t, b, c, d, a, p =
		opts.time,
		opts.begin,
		opts.change,
		opts.duration,
		opts.amplitude,
		opts.period

	if t == 0 then
		return b or 0
	end

	t = t / d

	if t == 1 then
		return b + c
	end

	if not p then
		p = d * 0.3
	end

	local s

	if not a or a < abs(c or 1) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c / a)
	end

	return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_out_elastic(opts)
	local t, b, c, d, a, p =
		opts.time,
		opts.begin,
		opts.change,
		opts.duration,
		opts.amplitude,
		opts.period

	if t == 0 then
		return b or 0
	end

	t = t / d * 2

	if t == 2 then
		return b + c
	end

	if not p then
		p = d * (0.3 * 1.5)
	end
	if not a then
		a = 0
	end

	local s

	if not a or a < abs(c or 1) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c / a)
	end

	if t < 1 then
		t = t - 1
		return -0.5 * (a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
	else
		t = t - 1
		return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p) * 0.5 + c + b
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_in_elastic(opts)
	local t, b, c, d, a, p =
		opts.time,
		opts.begin,
		opts.change,
		opts.duration,
		opts.amplitude,
		opts.period

	if t < d / 2 then
		return M.out_elastic({
			time = t * 2,
			begin = b,
			change = c / 2,
			duration = d,
			amplitude = a,
			period = p,
		})
	else
		return M.in_elastic({
			time = (t * 2) - d,
			begin = b + c / 2,
			change = c / 2,
			duration = d,
			amplitude = a,
			period = p,
		})
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_back(opts)
	local t, b, c, d, s =
		opts.time, opts.begin, opts.change, opts.duration, opts.overshoot

	if not s then
		s = 1.70158
	end
	t = t / d
	return c * t * t * ((s + 1) * t - s) + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_back(opts)
	local t, b, c, d, s =
		opts.time, opts.begin, opts.change, opts.duration, opts.overshoot

	if not s then
		s = 1.70158
	end
	t = t / d - 1
	return c * (t * t * ((s + 1) * t + s) + 1) + b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_out_back(opts)
	local t, b, c, d, s =
		opts.time, opts.begin, opts.change, opts.duration, opts.overshoot
	if not s then
		s = 1.70158
	end
	s = s * 1.525
	t = t / d * 2
	if t < 1 then
		return c / 2 * (t * t * ((s + 1) * t - s)) + b
	else
		t = t - 2
		return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_in_back(opts)
	local t, b, c, d, s =
		opts.time, opts.begin, opts.change, opts.duration, opts.overshoot
	if t < d / 2 then
		return M.out_back({
			time = t * 2,
			begin = b,
			change = c / 2,
			duration = d,
			overshoot = s,
		})
	else
		return M.in_back({
			time = (t * 2) - d,
			begin = b + c / 2,
			change = c / 2,
			duration = d,
			overshoot = s,
		})
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_bounce(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration

	t = t / d
	if t < 1 / 2.75 then
		return c * (7.5625 * t * t) + b
	elseif t < 2 / 2.75 then
		t = t - (1.5 / 2.75)
		return c * (7.5625 * t * t + 0.75) + b
	elseif t < 2.5 / 2.75 then
		t = t - (2.25 / 2.75)
		return c * (7.5625 * t * t + 0.9375) + b
	else
		t = t - (2.625 / 2.75)
		return c * (7.5625 * t * t + 0.984375) + b
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_bounce(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	return c
		- M.out_bounce({
			time = d - t,
			begin = 0,
			change = c,
			duration = d,
		})
		+ b
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.in_out_bounce(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t < d / 2 then
		return M.in_bounce({
			time = t * 2,
			begin = 0,
			change = c,
			duration = d,
		}) * 0.5 + b
	else
		return M.out_bounce({
			time = t * 2 - d,
			begin = 0,
			change = c,
			duration = d,
		}) * 0.5 + c * 0.5 + b
	end
end

---@param opts UndoGlow.EasingOpts
---@return integer
function M.out_in_bounce(opts)
	local t, b, c, d = opts.time, opts.begin, opts.change, opts.duration
	if t < d / 2 then
		return M.out_bounce({
			time = t * 2,
			begin = b,
			change = c / 2,
			duration = d,
		})
	else
		return M.in_bounce({
			time = (t * 2) - d,
			begin = b + c / 2,
			change = c / 2,
			duration = d,
		})
	end
end

return M
