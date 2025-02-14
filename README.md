# undo-glow.nvim

Make your undo and redo in neovim glows! This plugin does not setup or hijack the keymaps but provides api for you to hook into.

## Previews

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
---@type UndoGlow.Config
---@field duration number In ms
---@field undo_hl string
---@field redo_hl string
---@field undo_hl_color vim.api.keyset.highlight
---@field redo_hl_color vim.api.keyset.highlight
{
 duration = 300, -- in ms
 undo_hl = "UgUndo", -- highlight
 redo_hl = "UgRedo", -- highlight
 undo_hl_color = { bg = "#FF5555", fg = "#000000" }, -- ugly red color, please change it!
 redo_hl_color = { bg = "#50FA7B", fg = "#000000" }, -- ugly green color, please change it!
}
```

## API

```lua
require("undo-glow").undo() -- Undo command
require("undo-glow").redo() -- Redo command
```

You can set it up anywhere you like, I set it up at the keymap level directly

### How I set it up?

```lua
return {
 {
  "y3owk1n/undo-glow.nvim",
  event = { "VeryLazy" },
  opts = {},
  config = function(_, opts)
   local undo_glow = require("undo-glow")

   undo_glow.setup(opts)

   vim.keymap.set("n", "u", undo_glow.undo, { noremap = true, silent = true })
   -- I like to use U to redo instead
   vim.keymap.set("n", "U", undo_glow.redo, { noremap = true, silent = true })
  end,
 },
 -- How i set up the colors using catppuccin
 {
  "catppuccin/nvim",
  optional = true,
  opts = function(_, opts)
   local colors = require("catppuccin.palettes").get_palette()
   local highlights = {
    UgUndo = { bg = colors.red, fg = colors.base },
    UgRedo = { bg = colors.flamingo, fg = colors.base },
   }
   opts.custom_highlights = opts.custom_highlights or {}
   for key, value in pairs(highlights) do
    opts.custom_highlights[key] = value
   end
  end,
 },
}
```

## Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
