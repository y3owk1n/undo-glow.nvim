# undo-glow.nvim

Make your undo and redo in neovim glows! This plugin does not setup or hijack the keymaps but provides api for you to hook into.

## Previews

### Undo With Animation

<https://github.com/user-attachments/assets/b83ca873-3656-4f37-85d8-a04bd64af86f>

### Undo Without Animation

<https://github.com/user-attachments/assets/f1e08be8-9356-4844-ae3b-a7e9c22a83e0>

### Redo With Animation

<https://github.com/user-attachments/assets/2cf762d2-dada-4786-a602-d71cdd15c560>

### Redo Without Animation

<https://github.com/user-attachments/assets/13e08e01-0ad2-4907-ab2f-a9e5e203746e>

## Motivation

This project is inspired by [highlight-undo.nvim](https://github.com/tzachar/highlight-undo.nvim) and I had been using the project for some time.

However, on and off the plugins will break my existing configuration due to some code changes from the source. Hence i created this 100+ line of code simple plugin that only does 1 thing, highlight the changes whenever I perform undo or redo.

For this project, there is no autocmd that being setup, but just pure lua function as an API to hook into your configuration.

## Contents

- [Installation](#installation)
- [Configuration](#configuration)
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
---@class UndoGlow.Config
---@field duration number In ms
---@field animation boolean
---@field undo_hl string
---@field redo_hl string
---@field undo_hl_color UndoGlow.HlColor
---@field redo_hl_color UndoGlow.HlColor
{
 duration = 300, -- in ms
 animation = true, -- whether to turn on or off for animation
 undo_hl = "UgUndo", -- highlight
 redo_hl = "UgRedo", -- highlight
 undo_hl_color = { bg = "#FF5555", fg = "#000000" }, -- ugly red color, please change it!
 redo_hl_color = { bg = "#50FA7B", fg = "#000000" }, -- ugly green color, please change it!
}
```

## API

```lua
require("undo-glow").undo() -- Undo command with highlights

require("undo-glow").redo() -- Redo command with highlights

---@class UndoGlow.AttachAndRunOpts
---@field hlgroup string
---@field cmd? function
---@param opts UndoGlow.AttachAndRunOpts
require("undo-glow").attach_and_run(opts) -- API to create custom actions that glows
```

You can set it up anywhere you like, I set it up at the keymap level directly.

### Creating custom command to highlight

```lua
function some_action()
 require("undo-glow").attach_and_run({
  hlgroup = "hlgroup",
  cmd = function()
   do_something_here()
  end
 })
end

--- then you can use it to bind to anywhere just like before. Undo and redo command are fundamentally doing the same thing.

--- Example of undo function
function M.undo()
 M.attach_and_run({
  hlgroup = M.config.undo_hl,
  cmd = function()
   vim.cmd("undo")
  end,
 })
end
````

Feel free to send a PR if you think there are some good actions that can be merged into the source.

### Creating an autocmd that will highlight anything when textChanged

```lua
vim.api.nvim_create_autocmd({ "TextChanged" }, {
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
   require("undo-glow").attach_and_run({
    hlgroup = "UgUndo",
   })
  end)
 end,
})
```

> As per docs for `TextChanged`, `Careful: This is triggered very often, don't do anything that the user does not expect or that is slow.`, so please becareful about this. I personnaly do not use autocmd for this purpose.

Feel free to send a PR if you think anything can be improved to better support autocmd

### How I set it up?

```lua
return {
 {
  "y3owk1n/undo-glow.nvim",
  event = { "VeryLazy" },
  ---@param _ any
  ---@param opts UndoGlow.Config
  opts = function(_, opts)
  -- How i set up the colors using catppuccin
   local has_catppuccin, catppuccin = pcall(require, "catppuccin.palettes")

   if has_catppuccin then
    local colors = catppuccin.get_palette()
    opts.undo_hl_color = { bg = colors.red, fg = colors.base }
    opts.redo_hl_color = { bg = colors.flamingo, fg = colors.base }
   end
  end,
  ---@param _ any
  ---@param opts UndoGlow.Config
  config = function(_, opts)
   local undo_glow = require("undo-glow")

   undo_glow.setup(opts)

   vim.keymap.set("n", "u", undo_glow.undo, { noremap = true, silent = true })
   -- I like to use U to redo instead
   vim.keymap.set("n", "U", undo_glow.redo, { noremap = true, silent = true })
  end,
 },
}
```

## Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
