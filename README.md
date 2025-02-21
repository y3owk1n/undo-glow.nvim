# undo-glow.nvim

Make your undo and redo in neovim glows! This plugin does not setup or hijack the keymaps but provides api for you to hook into.

## Previews

### Undo

<https://github.com/user-attachments/assets/60d0cb17-78fb-414f-ab7f-870397b13d5e>

### Redo

<https://github.com/user-attachments/assets/4fd54266-b116-4da3-8fee-186b44baf6a5>

### Yank

<https://github.com/user-attachments/assets/1c55324a-1a1a-4bdd-b766-cc7ad4972b1b>

### Search

<https://github.com/user-attachments/assets/9c99e635-e4d7-490a-8ae6-ca2749656f57>

### Comment

<https://github.com/user-attachments/assets/624db7db-6b50-437b-a92c-966ad2246d70>

## Motivation

This project is inspired by [highlight-undo.nvim](https://github.com/tzachar/highlight-undo.nvim) and I had been using the project for some time.

However, on and off the plugins will break my existing configuration due to some code changes from the source. Hence i created this 100+ line of code simple plugin that only does 1 thing, highlight the changes whenever I perform undo or redo.

For this project, there is no autocmd that being setup, but just pure lua function as an API to hook into your configuration.

## Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Easing](#easing)
- [API](#api)
- [Contributing](#contributing)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- undo-glow.lua
return {
 "y3owk1n/undo-glow.nvim",
 opts = {} -- your configuration
}
```

If you are using other package managers you need to call `setup`:

```lua
require("undo-glow").setup({
  -- your configuration
})
```

## Configuration

Here is the default configuration:

```lua
---@alias AnimationType "fade" | "blink" | "pulse" | "jitter"

---@class UndoGlow.Config
---@field duration? number In ms
---@field animation? boolean
---@field animation_type? AnimationType
---@field easing? function A function that takes a number (0-1) and returns a number (0-1) for easing.
---@field fps? number
---@field highlights? table<"undo" | "redo" | "yank" | "paste" | "search" | "comment", { hl: string, hl_color: UndoGlow.HlColor }>

---@class UndoGlow.HlColor
---@field bg string Background color
---@field fg? string Optional for text color (Without this, it will just remain the existing text color as it is)
{
 duration = 500, -- in ms
 animation = true, -- whether to turn on or off for animation
 animation_type = "fade", -- default to "fade"
 fps = 120, -- change the fps, normally either 60 / 120
 easing = M.easing.ease_in_out_cubic, -- see more at easing section on how to change and create your own
 highlights = { -- Any keys other than these defaults will be ignored and omitted
  undo = {
   hl = "UgUndo", -- This will not set new hlgroup, if it's not "UgUndo", we will try to grab the colors of specified hlgroup and apply to "UgUndo"
   hl_color = { bg = "#FF5555" }, -- Ugly red color
  },
  redo = {
   hl = "UgRedo", -- Same as above
   hl_color = { bg = "#50FA7B" }, -- Ugly green color
  },
  yank = {
   hl = "UgYank", -- Same as above
   hl_color = { bg = "#F1FA8C" }, -- Ugly yellow color
  },
  paste = {
   hl = "UgPaste", -- Same as above
   hl_color = { bg = "#8BE9FD" }, -- Ugly cyan color
  },
  search = {
   hl = "UgSearch", -- Same as above
   hl_color = { bg = "#BD93F9" }, -- Ugly purple color
  },
  comment = {
   hl = "UgComment", -- Same as above
   hl_color = { bg = "#FFB86C" }, -- Ugly purple color
  },
 },
}
```

## Easing

### Builtin easing API

```lua
require("undo-glow").easing.ease_in_out_cubic() -- default
require("undo-glow").easing.ease_out_quad()
require("undo-glow").easing.ease_out_cubic()
require("undo-glow").easing.ease_in_sine()
```

Feel free to send in PR for more interesting easings

### Changing easing from configuration with builtin

```lua
-- configuration opts
{
 ...rest
 easing = require("undo-glow").easing.ease_in_sine()
 ...rest
}
```

### Custom easing functions

```lua
{
 ...rest
---@param t number (0-1) Interpolation factor
---@return number
 easing = function(t)
  return 1 - math.cos((t * math.pi) / 2)
 end,
 ...rest
}
```

## API

```lua
require("undo-glow").undo() -- Undo command with highlights

require("undo-glow").redo() -- Redo command with highlights

require("undo-glow").yank() -- Yank with highlights. This is not a command, use this in autocmd only

require("undo-glow").paste_below() -- Paste below command with highlights

require("undo-glow").paste_above() -- Paste above command with highlights

require("undo-glow").search_next() -- Search next command with highlights

require("undo-glow").search_prev() -- Search prev command with highlights

require("undo-glow").search_star() -- Search current word with "*" with highlights

require("undo-glow").comment() -- Comment with `gc` in `n` and `x` mode

require("undo-glow").comment_textobject() -- Comment with `gc` in `o` mode. E.g. gcip, gcap, etc

require("undo-glow").comment_line() -- Comment lines with `gcc`.

---@class UndoGlow.HighlightChanges
---@field hlgroup string
---@field animation_type? AnimationType -- Overwrites animation_type from config

---@param opts UndoGlow.HighlightChanges
require("undo-glow").highlight_changes(opts) -- API to highlight text changes

---@class UndoGlow.HighlightRegion
---@field hlgroup string
---@field animation_type? AnimationType -- Overwrites animation_type from config
---@field s_row integer Start row
---@field s_col integer Start column
---@field e_row integer End row
---@field e_col integer End column

--- @param opts UndoGlow.HighlightRegion Options for highlighting the region:
require("undo-glow").highlight_region(opts) -- API to highlight certain region without text changes
```

You can set it up anywhere you like, Commonly at the keymap level directly. For example:

```lua
vim.keymap.set("n", "u", require("undo-glow").undo, { noremap = true, desc = "Undo with highlight" })
vim.keymap.set("n", "<C-r>", require("undo-glow").redo, { noremap = true, desc = "Redo with highlight" })
vim.keymap.set("n", "p", require("undo-glow").paste_below, { noremap = true, desc = "Paste below with highlight" })
vim.keymap.set("n", "P", require("undo-glow").paste_above, { noremap = true, desc = "Paste above with highlight" })
vim.keymap.set("n", "n", require("undo-glow").search_next, { noremap = true, desc = "Search next with highlight" })
vim.keymap.set("n", "N", require("undo-glow").search_prev, { noremap = true, desc = "Search previous with highlight" })
vim.keymap.set("n", "*", require("undo-glow").search_star, { noremap = true, desc = "Search * with highlight" })
vim.keymap.set({ "n", "x" }, "gc", require("undo-glow").comment, { expr = true, desc = "Toggle comment with highlight" })
vim.keymap.set("o", "gc", require("undo-glow").comment_text_object, { expr = true, desc = "Comment textobject with highlight" })
vim.keymap.set("n", "gcc", require("undo-glow").comment_line, { expr = true, desc = "Toggle comment line with highlight" })

vim.api.nvim_create_autocmd("TextYankPost", {
 desc = "Highlight when yanking (copying) text",
 callback = require("undo-glow").yank,
})
```

### Creating custom command to highlight changes

E.g. undo, redo, etc

```lua
function some_action()
 require("undo-glow").highlight_changes({
  hlgroup = "hlgroup",
 })
 do_something_here() -- some action that will cause text changes
end

--- then you can use it to bind to anywhere just like before. Undo and redo command are fundamentally doing the same thing.
vim.keymap.set("n", "key_that_you_like", some_action, { silent = true })

--- Example of undo function
function undo()
 require("undo-glow").highlight_changes({
  hlgroup = "UgUndo",
 })
 vim.cmd("undo")
end
````

Feel free to send a PR if you think there are some good actions that can be merged into the source.

### Creating custom command that highlights without text changes

E.g. search next, search previous, yank, etc

```lua
function some_action()
 -- Do some calculation here and get the region coordinates that you want to highlight as below
 -- s_row integer
 -- s_col integer
 -- e_row integer
 -- e_col integer
 local region = get_region()

 -- And then pass those coordinates to the highlight_region function
 require("undo-glow").highlight_region({
  hlgroup = "hlgroup",
  s_row = region.s_row,
  s_col = region.s_col,
  e_row = region.e_row,
  e_col = region.e_col,
 })
end

--- then you can use it to bind to anywhere just like before. Undo and redo command are fundamentally doing the same thing.
vim.keymap.set("n", "key_that_you_like", some_action, { silent = true })

--- Example of yank function
function yank()
 local pos = vim.fn.getpos("'[")
 local pos2 = vim.fn.getpos("']")
 require("undo-glow").highlight_region({
  hlgroup = "UgYank",
  s_row = pos[2] - 1,
  s_col = pos[3] - 1,
  e_row = pos2[2] - 1,
  e_col = pos2[3],
 })
end
````

Feel free to send a PR if you think there are some good actions that can be merged into the source.

### Creating an autocmd that will highlight anything when textChanged

I personally don't use autocmd for `TextChanged`. Use at your own risk!

```lua
-- Also add `BufReadPost` so that it will also highlight for first changes
vim.api.nvim_create_autocmd({ "BufReadPost", "TextChanged" }, {
 pattern = "*",
 callback = function()
  -- Either provide a list of ignored filetypes
  local ignored_filetypes = { "mason", "snacks_picker_list", "lazy" }
  if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
   return
  end

  -- or just use buftype to ignore all other type
  if vim.bo.buftype ~= "" then
   return
  end

  -- then run undo-glow with your desired hlgroup
  vim.schedule(function()
   require("undo-glow").highlight_changes({
    hlgroup = "UgUndo",
   })
  end)
 end,
})
```

> As per docs for `TextChanged`, `Careful: This is triggered very often, don't do anything that the user does not expect or that is slow.`, so please becareful about this. I have been using this for a while, and everything seems working fine.

Feel free to send a PR if you think anything can be improved to better support autocmd,

### Highlight Yank Text

> This is already included as presets, just to show how you can do it yourself

```lua
vim.api.nvim_create_autocmd("TextYankPost", {
 desc = "Highlight when yanking (copying) text",
 callback = function()
  local pos = vim.fn.getpos("'[")
  local pos2 = vim.fn.getpos("']")
  require("undo-glow").highlight_region({
   hlgroup = "UgUndo",
   s_row = pos[2] - 1,
   s_col = pos[3] - 1,
   e_row = pos2[2] - 1,
   e_col = pos2[3],
  })
 end,
})
```

### Highlight Pasted Text

> This is already included as presets, just to show how you can do it yourself

```lua
vim.keymap.set("n", "p", function()
 require("undo-glow").highlight_changes({
  hlgroup = "UgUndo",
 })
 vim.cmd("normal! p")
end, { noremap = true })

vim.keymap.set("n", "P", function()
 require("undo-glow").highlight_changes({
  hlgroup = "UgUndo",
 })
 vim.cmd("normal! P")
end, { noremap = true })
```

### Highlight search text next and previous

> This is already included as presets, just to show how you can do it yourself

```lua
-- Use `n` for next and `N` for previous
vim.keymap.set("n", "n", function()
 vim.cmd("normal! n") -- Use `n` for next and `N` for previous
 local bufnr = vim.api.nvim_get_current_buf()
 local cursor = vim.api.nvim_win_get_cursor(0)
 local row = cursor[1] - 1
 local col = cursor[2]

 local search_pattern = vim.fn.getreg("/")
 if search_pattern == "" then
  return
 end

 local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
 if not line then
  return
 end

 local match_start, match_end
 local offset = 1
 while true do
  local s, e = line:find(search_pattern, offset)
  if not s then
   break
  end

  local s0 = s - 1

  if col >= s0 and col < e then
   match_start, match_end = s, e
   break
  end

  if s0 > col then
   match_start, match_end = s, e
   break
  end
  offset = e + 1
 end

 if not match_start or not match_end then
  match_start, match_end = line:find(search_pattern)
  if not match_start or not match_end then
   return
  end
 end

 require("undo-glow").highlight_region({
  hlgroup = "UgUndo",
  s_row = row,
  s_col = match_start - 1,
  e_row = row,
  e_col = match_end,
 })
end, { silent = true })
```

### How I set it up?

```lua
return {
 {
  "y3owk1n/undo-glow.nvim",
  event = { "VeryLazy" },
  ---@type UndoGlow.Config
  opts = {
   duration = 1000,
   highlights = {
    undo = {
     hl_color = { bg = "#48384B" },
    },
    redo = {
     hl_color = { bg = "#3B474A" },
    },
    yank = {
     hl_color = { bg = "#5A513C" },
    },
    paste = {
     hl_color = { bg = "#5A496E" },
    },
    search = {
     hl_color = { bg = "#6D4B5E" },
    },
    comment = {
     hl_color = { bg = "#6D5640" },
    },
   },
  },
  ---@param _ any
  ---@param opts UndoGlow.Config
  config = function(_, opts)
   local undo_glow = require("undo-glow")

   undo_glow.setup(opts)

   vim.keymap.set("n", "u", undo_glow.undo, { noremap = true, desc = "Undo with highlight" })
   vim.keymap.set("n", "U", undo_glow.redo, { noremap = true, desc = "Redo with highlight" })
   vim.keymap.set("n", "p", undo_glow.paste_below, { noremap = true, desc = "Paste below with highlight" })
   vim.keymap.set("n", "P", undo_glow.paste_above, { noremap = true, desc = "Paste above with highlight" })
   vim.keymap.set("n", "n", undo_glow.search_next, { noremap = true, desc = "Search next with highlight" })
   vim.keymap.set("n", "N", undo_glow.search_prev, { noremap = true, desc = "Search previous with highlight" })
   vim.keymap.set("n", "*", undo_glow.search_star, { noremap = true, desc = "Search * with highlight" })
   vim.keymap.set({ "n", "x" }, "gc", undo_glow.comment, { expr = true, noremap = true, desc = "Toggle comment with highlight" })

   vim.keymap.set("o", "gc", undo_glow.comment_textobject, { noremap = true, desc = "Comment textobject with highlight" })

   vim.keymap.set("n", "gcc", undo_glow.comment_line, { expr = true, noremap = true, desc = "Toggle comment line with highlight" })

   vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    callback = require("undo-glow").yank,
   })
 },
}
```

## Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
