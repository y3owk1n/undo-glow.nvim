# 🌈 undo-glow.nvim

**undo-glow.nvim** is a Neovim plugin that adds a visual "glow" effect to your neovim operations. It highlights the exact region that’s changed, giving you immediate visual feedback on your edits. You can even enable glow for non-changing texts!

> [!important]
> This plugin does not setup or hijack the keymaps but provides api for you to hook into anywhere in your config.

## ✨ Features

- **Visual Feedback For Changes:** Highlights the region affected by text changes commands (E.g. undo, redo, comment).
- **Visual Feedback For Non-changes:** Highlights any region from an operation (E.g. search next, search prev, search star, yank).
- **Simple API For Custom Highlights:** Simple API to create and attach your own commands that glows.
- **Customizable Appearance:** Easily change the glow duration, highlight colors and animations.
- **Lightweight & Fast:** Uses Neovim's native APIs for efficient real-time highlighting with zero dependencies.

## 🔥 Status

This project is feature complete at this point. The rest of the commits will be focusing on bug fixes, optimizations and additional commands that fits in the scope of this project.

## 👀 Previews

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

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- undo-glow.lua
return {
 "y3owk1n/undo-glow.nvim",
 version = "*", -- remove this if you want to use the `main` branch
 opts = {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
 }
}
```

If you are using other package managers you need to call `setup`:

```lua
require("undo-glow").setup({
  -- your configuration
})
```

## ⚙️Configuration

> [!important]
> Make sure to run `:checkhealth undo-glow` if something isn't working properly

**undo-glow.nvim** is highly configurable. Expand to see the list of all the default options below.

### Default Options

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
 fps = 120, -- change the fps, normally either 60 / 120, but it can be whatever number
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

<details><summary>My setup in my config</summary>

<!-- config:start -->

```lua
return {
 {
  "y3owk1n/undo-glow.nvim",
  version = "*",
  event = { "VeryLazy" },
  ---@type UndoGlow.Config
  opts = {
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

<!-- config:end -->

</details>

## 🌎 API

**undo-glow.nvim** comes with simple API and builtin commands for you to hook into your config or DIY.

### Commands

#### Undo Highlights

```lua
require("undo-glow").undo() -- Undo command with highlights
```

<details><summary>Usage Example</summary>

<!-- config:start -->

```lua
vim.keymap.set("n", "u", require("undo-glow").undo, { noremap = true, desc = "Undo with highlight" })
```

<!-- config:end -->

</details>

#### Redo Highlights

```lua
require("undo-glow").redo() -- Redo command with highlights
```

<details><summary>Usage Example</summary>

<!-- config:start -->

```lua
vim.keymap.set("n", "<C-r>", require("undo-glow").redo, { noremap = true, desc = "Redo with highlight" })
```

<!-- config:end -->

</details>

#### Yank Highlights

> [!WARNING]
> This is not a command and it is designed to be used in autocmd callback.

```lua
require("undo-glow").yank() -- Yank with highlights.
```

<details><summary>Usage Example</summary>

<!-- config:start -->

```lua
vim.api.nvim_create_autocmd("TextYankPost", {
 desc = "Highlight when yanking (copying) text",
 callback = require("undo-glow").yank,
})
```

<!-- config:end -->

</details>

#### Paste Highlights

```lua
require("undo-glow").paste_below() -- Paste below command with highlights
require("undo-glow").paste_above() -- Paste above command with highlights
```

<details><summary>Usage Example</summary>

<!-- config:start -->

```lua
vim.keymap.set("n", "p", require("undo-glow").paste_below, { noremap = true, desc = "Paste below with highlight" })
vim.keymap.set("n", "P", require("undo-glow").paste_above, { noremap = true, desc = "Paste above with highlight" })
```

<!-- config:end -->

</details>

#### Search Highlights

```lua
require("undo-glow").search_next() -- Search next command with highlights
require("undo-glow").search_prev() -- Search prev command with highlights
require("undo-glow").search_star() -- Search current word with "*" with highlights
```

<details><summary>Usage Example</summary>

<!-- config:start -->

```lua
vim.keymap.set("n", "n", require("undo-glow").search_next, { noremap = true, desc = "Search next with highlight" })
vim.keymap.set("n", "N", require("undo-glow").search_prev, { noremap = true, desc = "Search previous with highlight" })
vim.keymap.set("n", "*", require("undo-glow").search_star, { noremap = true, desc = "Search * with highlight" })
```

<!-- config:end -->

</details>

#### Comment Highlights

```lua
require("undo-glow").comment() -- Comment with `gc` in `n` and `x` mode
require("undo-glow").comment_textobject() -- Comment with `gc` in `o` mode. E.g. gcip, gcap, etc
require("undo-glow").comment_line() -- Comment lines with `gcc`.
```

<details><summary>Usage Example</summary>

<!-- config:start -->

```lua
vim.keymap.set({ "n", "x" }, "gc", require("undo-glow").comment, { expr = true, desc = "Toggle comment with highlight" })
vim.keymap.set("o", "gc", require("undo-glow").comment_text_object, { expr = true, desc = "Comment textobject with highlight" })
vim.keymap.set("n", "gcc", require("undo-glow").comment_line, { expr = true, desc = "Toggle comment line with highlight" })
```

<!-- config:end -->

</details>

### Do-it-yourself APIs

**undo-glow.nvim** also provides APIs to create your own highlights that are not supported out of the box.

#### Highlight text changes

```lua
---@class UndoGlow.HighlightChanges
---@field hlgroup string
---@field animation_type? AnimationType -- Overwrites animation_type from config

---@param opts UndoGlow.HighlightChanges
require("undo-glow").highlight_changes(opts) -- API to highlight text changes
```

##### Usage

```lua
function some_action()
 require("undo-glow").highlight_changes({
  hlgroup = "hlgroup",
 })
 do_something_here() -- some action that will cause text changes
end

--- then you can use it to bind to anywhere just like before. Undo and redo command are fundamentally doing the same thing.
vim.keymap.set("n", "key_that_you_like", some_action, { silent = true })
````

<details><summary>Example with undo command</summary>

<!-- config:start -->

```lua
function undo()
 require("undo-glow").highlight_changes({
  hlgroup = "UgUndo",
 })
 vim.cmd("undo")
end
```

<!-- config:end -->

</details>

#### Highlight any region of your choice

```lua
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

##### Usage Example

```lua
function some_action()
 -- Do some calculation here and get the region coordinates that you want to highlight as below
 -- s_row integer
 -- s_col integer
 -- e_row integer
 -- e_col integer
 local region = get_region() --- This is a sample function

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
````

<details><summary>Example with yank</summary>

<!-- config:start -->

```lua
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
```

<!-- config:end -->

</details>

### Lazy Mode: Creating an autocmd that will highlight anything that changed

> [!WARNING]
> I personally don't use this in my config, but it should work just fine. Use at your own risk!

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

## 💎 Animations & Easings

### Animations

**undo-glow.nvim** comes with 4 default animations out of the box and can be toggled on and off.

```lua
---@alias AnimationType "fade" | "blink" | "pulse" | "jitter"
```

#### No Animation

Static highlight and will be cleared after a duration immediately.

<https://github.com/user-attachments/assets/7ea4b7fb-9c04-445c-a397-914b76c240f1>

#### Fade (Default)

Gradually increases or decreases the opacity of the highlight, creating a smooth fading effect.

<https://github.com/user-attachments/assets/06820af3-1c37-445c-9e3d-946c277d946a>

#### Blink

Toggles the highlight on and off at a fixed interval, similar to a cursor blink.

<https://github.com/user-attachments/assets/8afee494-f9a0-4eef-9c9e-86a5c0c56eae>

#### Pulse

Alternates the highlight intensity in a rhythmic manner, creating a breathing effect.

<https://github.com/user-attachments/assets/57c9f86a-f1e6-424c-a885-caf288b594fc>

#### Jitter

Rapidly moves or shifts the highlight slightly, giving a shaky or vibrating appearance.

<https://github.com/user-attachments/assets/8627ee17-2ac7-4571-a897-3422cebe0e1b>

### Easing

**undo-glow.nvim** comes with 4 default easing options as below. Feel free to send PRs for more interesting easings.

#### Builtin easings

```lua
require("undo-glow").easing.ease_in_out_cubic() -- default
require("undo-glow").easing.ease_out_quad()
require("undo-glow").easing.ease_out_cubic()
require("undo-glow").easing.ease_in_sine()
```

#### Changing easing from configuration with builtin

```lua
-- configuration opts
{
 --- rest of configurations
 easing = require("undo-glow").easing.ease_in_sine()
 --- rest of configurations
}
```

#### Custom easing functions

Other than the defaults, you can also create your own easing function like below.

```lua
{
 --- rest of configurations
 ---@param t number (0-1) Interpolation factor
 ---@return number
 easing = function(t)
  return 1 - math.cos((t * math.pi) / 2)
 end,
 --- rest of configurations
}
```

## Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
