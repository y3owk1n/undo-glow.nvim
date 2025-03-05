---@module 'luassert'

local animation = require("undo-glow.animation")
local utils = require("undo-glow.utils")
local color = require("undo-glow.color")
local uv = vim.uv or vim.loop

describe("undo-glow.animation", function()
	local bufnr, ns, hlgroup

	before_each(function()
		bufnr = vim.api.nvim_create_buf(false, true)
		ns = utils.ns
		hlgroup = "TestHL"
	end)

	after_each(function()
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
		vim.cmd("hi clear " .. hlgroup)
	end)

	describe("animate_clear", function()
		it("should stop and close the timer", function()
			local timer = uv.new_timer()
			timer:start(1000, 1000, function() end)
			local opts = { bufnr = bufnr, extmark_id = 1, hlgroup = hlgroup }
			animation.animate_clear(opts, timer)
			assert.is_false(timer:is_active(), "Timer should be stopped")
		end)

		it("should delete extmark if valid table", function()
			local extmark_ids = {}
			local extmark_id = vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})
			table.insert(extmark_ids, extmark_id)
			local opts =
				{ bufnr = bufnr, extmark_ids = extmark_ids, hlgroup = hlgroup }
			local timer = uv.new_timer()
			animation.animate_clear(opts, timer)

			local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
			assert.equal(0, #marks, "Extmark should be deleted")
		end)

		it("should delete extmark if valid table of key value pair", function()
			local extmark_id = vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})
			local extmark_id2 =
				vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})
			local extmark_id3 =
				vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})

			local extmark_ids = {
				[1] = extmark_id,
				[2] = extmark_id2,
				[3] = extmark_id3,
			}

			local opts =
				{ bufnr = bufnr, extmark_ids = extmark_ids, hlgroup = hlgroup }
			local timer = uv.new_timer()
			animation.animate_clear(opts, timer)

			local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
			assert.equal(0, #marks, "Extmark should be deleted")
		end)

		it(
			"should delete extmark if valid and key value pair with integer table",
			function()
				local extmark_id =
					vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})
				local extmark_id2 =
					vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})
				local extmark_id3 =
					vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})
				local extmark_id4 =
					vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})

				local extmark_ids = {
					[2] = extmark_id,
					[3] = extmark_id2,
					[4] = extmark_id3,
					extmark_id4,
				}

				local opts = {
					bufnr = bufnr,
					extmark_ids = extmark_ids,
					hlgroup = hlgroup,
				}
				local timer = uv.new_timer()
				animation.animate_clear(opts, timer)

				local marks =
					vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
				assert.equal(0, #marks, "Extmark should be deleted")
			end
		)

		it("should clear the highlight group", function()
			vim.api.nvim_set_hl(0, hlgroup, { bg = "#FF0000" })
			local opts = { hlgroup = hlgroup, bufnr = bufnr }
			local timer = uv.new_timer()
			animation.animate_clear(opts, timer)
			local hl = vim.api.nvim_get_hl(0, { name = hlgroup })
			assert.is_nil(hl.background, "Highlight should be cleared")
		end)
	end)

	describe("animate_start", function()
		it("should handle animation completion", function()
			local opts = {
				bufnr = bufnr,
				duration = 10, -- Short duration for testing
				hlgroup = hlgroup,
				state = { animation = { fps = 60 } },
				start_bg = { r = 255, g = 0, b = 0 },
				end_bg = { r = 0, g = 0, b = 0 },
				extmark_ids = {},
			}

			local extmark_id = vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {})
			table.insert(opts.extmark_ids, extmark_id)

			local animate_fn = function(progress)
				return {
					bg = color.blend_color(
						opts.start_bg,
						opts.end_bg,
						progress
					),
				}
			end

			animation.animate_start(opts, animate_fn)
			vim.wait(20, function() end) -- Wait for animation to finish

			-- Verify cleanup
			local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
			local hl = vim.api.nvim_get_hl(0, { name = opts.hlgroup })
			assert.equal(
				0,
				#marks,
				"Extmark should be deleted after completion"
			)
			assert.is_nil(
				hl.background,
				"Highlight should be cleared after completion"
			)
		end)
	end)
end)
