---@meta

---@class AssertIs
---@field ["nil"] fun(...): any
---@field truthy fun(...): any
---@field falsy fun(...): any
---@field number fun(...): any
---@field string fun(...): any
---@field table fun(...): any
---@field boolean fun(...): any
---@field ["function"] fun(...): any
---@field is_true fun(...): any
---@field is_false fun(...): any
---@field is_nil fun(...): any
---@field is_number fun(...): any
---@field is_boolean fun(...): any
---@field is_string fun(...): any
---@field is_table fun(...): any
---@field is_function fun(...): any
---@field is_truthy fun(...): any

---@class AssertAre
---@field same fun(...): any

---@class AssertLib
---@field is AssertIs
---@field are AssertAre
---@field equal fun(...): any
---@field equals fun(...): any
---@field matches fun(...): any
---@field spy table

-- Runtime stub with all fields so LSP recognizes them
assert = {
	is = {
		["nil"] = function(...) end,
		truthy = function(...) end,
		falsy = function(...) end,
		number = function(...) end,
		string = function(...) end,
		table = function(...) end,
		boolean = function(...) end,
		["function"] = function(...) end,
		is_true = function(...) end,
		is_false = function(...) end,
		is_nil = function(...) end,
		is_number = function(...) end,
		is_boolean = function(...) end,
		is_string = function(...) end,
		is_table = function(...) end,
		is_function = function(...) end,
		is_truthy = function(...) end,
	},
	are = {
		same = function(...) end,
	},
	equal = function(...) end,
	equals = function(...) end,
	matches = function(...) end,
	spy = {},
}
