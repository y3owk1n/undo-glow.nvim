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
---@field undo_hl? string
---@field redo_hl? string
---@field undo_hl_color? UndoGlow.HlColor
---@field redo_hl_color? UndoGlow.HlColor

---@class UndoGlow.HlColor
---@field bg string Background color
---@field fg? string Optional for text color (Without this, it will just remain the existing text color as it is)
{
 duration = 500, -- in ms
 animation = true, -- whether to turn on or off for animation
 animation_type = "fade", -- default to "fade"
 fps = 120, -- change the fps, normally either 60 / 120
 easing = M.easing.ease_in_out_cubic, -- see more at easing section on how to change and create your own
 undo_hl = "UgUndo", -- This will not set new hlgroup, if it's not "UgUndo", we will try to grab the colors of specified hlgroup and apply to "UgUndo"
 redo_hl = "UgRedo", -- This will not set new hlgroup, if it's not "UgRedo", we will try to grab the colors of specified hlgroup and apply to "UgRedo"
 undo_hl_color = { bg = "#FF5555" }, -- Colors from undo_hl will overwrite this, unless undo_hl does not contain the bg or fg. Ugly red color, please change it!
 redo_hl_color = { bg = "#50FA7B" }, -- -- Colors from undo_hl will overwrite this, unless redo_hl does not contain the bg or fg. Ugly green color, please change it!
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

---@class UndoGlow.AttachAndRunOpts
---@field hlgroup string
---@field cmd? function
---@field animation_type? AnimationType -- Overwrites animation_type from config

---@param opts UndoGlow.AttachAndRunOpts
require("undo-glow").attach_and_run(opts) -- API to create custom actions that highlights
```

You can set it up anywhere you like, Commonly at the keymap level directly. For example:

```lua
vim.keymap.set("n", "u", require("undo-glow").undo, { noremap = true, silent = true })
vim.keymap.set("n", "<C-r>", require("undo-glow").redo, { noremap = true, silent = true })
```

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
vim.keymap.set("n", "key_that_you_like", some_action, { noremap = true, silent = true })

--- Example of undo function
function undo()
 require("undo-glow").attach_and_run({
  hlgroup = "UgUndo",
  cmd = function()
   vim.cmd("undo")
  end,
 })
end
````

Feel free to send a PR if you think there are some good actions that can be merged into the source.

### Creating an autocmd that will highlight anything when textChanged

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
   require("undo-glow").attach_and_run({
    hlgroup = "UgUndo",
   })
  end)
 end,
})
```

> As per docs for `TextChanged`, `Careful: This is triggered very often, don't do anything that the user does not expect or that is slow.`, so please becareful about this. I have been using this for a while, and everything seems working fine.

Feel free to send a PR if you think anything can be improved to better support autocmd,

### How I set it up?

```lua
return {
 {
  "y3owk1n/undo-glow.nvim",
  event = { "VeryLazy" },
  ---@type UndoGlow.Config
  opts = {
   undo_hl = "DiffDelete",
   redo_hl = "DiffAdd",
   duration = 1000,
  },
  ---@param _ any
  ---@param opts UndoGlow.Config
  config = function(_, opts)
   local undo_glow = require("undo-glow")

   undo_glow.setup(opts)

   -- I like to use U to redo instead
   vim.keymap.set("n", "U", "<C-r>", { noremap = true, silent = true })

   -- Highlight everything that changes
   vim.api.nvim_create_autocmd({ "BufReadPost", "TextChanged" }, {
    pattern = "*",
    callback = function()
     if vim.bo.buftype ~= "" then
      return
     end

     vim.schedule(function()
      undo_glow.attach_and_run({
       hlgroup = "UgUndo",
      })
     end)
    end,
   })
  end,
 },
}
```

## Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
