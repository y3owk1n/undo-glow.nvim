# 🌈 undo-glow.nvim

**undo-glow.nvim** is a Neovim plugin that adds a visual "glow" effect to your neovim operations. It highlights the exact region that’s changed, giving you immediate visual feedback on your edits. You can even enable glow for non-changing texts!

> [!note]
> This plugin does not do anything on installation, no keymaps or autocmd are created by default. You need to do it your own.

## ✨ Features

- **Visual Feedback For Changes:** Highlights the region affected by text changes commands (E.g. undo, redo, comment).
- **Visual Feedback For Non-changes:** Highlights any region from an operation (E.g. search next, search prev, search star, yank).
- **Simple API For Custom Highlights:** Simple API to create and attach your own commands that glows.
- **Customizable Appearance:** Easily change the glow duration, highlight colors and animations.
- **Zero Dependencies:** Uses Neovim's native APIs for efficient real-time highlighting with zero dependencies.

## 🔥 Status

This project is feature complete at this point. The rest of the commits will be focusing on bug fixes, optimizations and additional commands that fits in the scope of this project.

> [!note]
> I am mainly daily driving this plugin, and all commits are not tested perfectly through CI, but tested based on how I use my editor. If there's anything that are not working based on your workflow, and it should fall under the scope of this plugin, please raise an issue or even better, send in a PR for fix.

## 📝 Differences from other similar plugins

There are alot of similars plugins that you can simply find from github. The main differences of **undo-glow.nvim** from the rest are:

- Configurable animation and colors everywhere (Globally or per action, including your custom actions)
- Expose APIs for you to even create your own actions that can highlight
- Create custom easings if the builtin easings are not enough for you
- Do not hijack your keymaps and silently creates autocmd (Do it your own in your config)
- You can use it as a library to create other plugins, since we are exposing the core APIs that are handling highlights

## 👀 Previews

### Undo

<https://github.com/user-attachments/assets/60d0cb17-78fb-414f-ab7f-870397b13d5e>

### Redo

<https://github.com/user-attachments/assets/4fd54266-b116-4da3-8fee-186b44baf6a5>

### Yank

<https://github.com/user-attachments/assets/1c55324a-1a1a-4bdd-b766-cc7ad4972b1b>

### Paste

<https://github.com/user-attachments/assets/cc32dfa7-1c00-4f07-885a-7ca4c9ae6649>

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

## ⚙️ Configuration

> [!important]
> Make sure to run `:checkhealth undo-glow` if something isn't working properly

**undo-glow.nvim** is highly configurable. Expand to see the list of all the default options below.

### Default Options

```lua
---@alias UndoGlow.AnimationType "fade" | "blink" | "pulse" | "jitter"
---@alias UndoGlow.EasingString "linear" | "in_quad" | "out_quad" | "in_out_quad" | "out_in_quad" | "in_cubic" | "out_cubic" | "in_out_cubic" | "out_in_cubic" | "in_quart" | "out_quart" | "in_out_quart" | "out_in_quart" | "in_quint" | "out_quint" | "in_out_quint" | "out_in_quint" | "in_sine" | "out_sine" | "in_out_sine" | "out_in_sine" | "in_expo" | "out_expo" | "in_out_expo" | "out_in_expo" | "in_circ" | "out_circ" | "in_out_circ" | "out_in_circ" | "in_elastic" | "out_elastic" | "in_out_elastic" | "out_in_elastic" | "in_back" | "out_back" | "in_out_back" | "out_in_back" | "in_bounce" | "out_bounce" | "in_out_bounce" | "out_in_bounce"
---@alias UndoGlow.EasingFn fun(opts: UndoGlow.EasingOpts): integer

---@class UndoGlow.Config
---@field animation? UndoGlow.Config.Animation
---@field highlights? table<"undo" | "redo" | "yank" | "paste" | "search" | "comment", { hl: string, hl_color: UndoGlow.HlColor }>

---@class UndoGlow.Config.Animation
---@field enabled? boolean Turn on or off for animation
---@field duration? number Highlight duration in ms
---@field animation_type? UndoGlow.AnimationType
---@field easing? UndoGlow.EasingString | UndoGlow.EasingFn A easing string or function that computes easing.
---@field fps? number Normally either 60 / 120, up to you

---@class UndoGlow.EasingOpts
---@field time integer Elapsed time
---@field begin? integer Begin
---@field change? integer Change == ending - beginning
---@field duration? integer Duration (total time)
---@field amplitude? integer Amplitude
---@field period? integer Period
---@field overshoot? integer Overshoot

---@class UndoGlow.HlColor
---@field bg string Background color
---@field fg? string Optional for text color (Without this, it will just remain the existing text color as it is)
{
 animation = {
  enabled = false, -- whether to turn on or off for animation
  duration = 100, -- in ms
  animation_type = "fade", -- default to "fade"
  fps = 120, -- change the fps, normally either 60 / 120, but it can be whatever number
  easing = "in_out_cubic", -- see more at easing section on how to change and create your own
 },
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
---@type LazySpec
return {
 {
  "y3owk1n/undo-glow.nvim",
  -- dir = "~/Dev/undo-glow.nvim", -- Your path
  event = { "VeryLazy" },
  ---@module 'undo-glow'
  ---@type UndoGlow.Config
  opts = {
   animation = {
    enabled = true,
    duration = 500,
   },
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
    search = {
     hl_color = { bg = "#6D4B5E" },
    },
    comment = {
     hl_color = { bg = "#6D5640" },
    },
   },
  },
  keys = {
   {
    "u",
    function()
     require("undo-glow").undo()
    end,
    mode = "n",
    desc = "Undo with highlight",
    noremap = true,
   },
   {
    "U",
    function()
     require("undo-glow").redo()
    end,
    mode = "n",
    desc = "Redo with highlight",
    noremap = true,
   },
   {
    "p",
    function()
     require("undo-glow").paste_below()
    end,
    mode = "n",
    desc = "Paste below with highlight",
    noremap = true,
   },
   {
    "P",
    function()
     require("undo-glow").paste_above()
    end,
    mode = "n",
    desc = "Paste above with highlight",
    noremap = true,
   },
   {
    "n",
    function()
     require("undo-glow").search_next()
    end,
    mode = "n",
    desc = "Search next with highlight",
    noremap = true,
   },
   {
    "N",
    function()
     require("undo-glow").search_prev()
    end,
    mode = "n",
    desc = "Search prev with highlight",
    noremap = true,
   },
   {
    "*",
    function()
     require("undo-glow").search_star()
    end,
    mode = "n",
    desc = "Search star with highlight",
    noremap = true,
   },
   {
    "gc",
    function()
     local pos = vim.fn.getpos(".")
     vim.schedule(function()
      vim.fn.setpos(".", pos)
     end)
     return require("undo-glow").comment()
    end,
    mode = { "n", "x" },
    desc = "Toggle comment with highlight",
    expr = true,
    noremap = true,
   },
   {
    "gc",
    function()
     require("undo-glow").comment_textobject()
    end,
    mode = "o",
    desc = "Comment textobject with highlight",
    noremap = true,
   },
   {
    "gcc",
    function()
     return require("undo-glow").comment_line()
    end,
    mode = "n",
    desc = "Toggle comment line with highlight",
    expr = true,
    noremap = true,
   },
  },
  init = function()
   vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    callback = require("undo-glow").yank,
   })
  end,
 },
}
```

<!-- config:end -->

</details>

## 🎨 Hlgroups

### Existing hlgroups

The default colors are fairly ugly in my opinion, but they are sharp enough for any themes. You should change the color to whatever you like.

<!-- colors:start -->

| Opts Key | Default Group | Color Code (Background) |
| --- | --- | --- |
| **undo** | ***UgUndo*** | #FF5555  |
| **redo** | ***UguRedo*** | #50FA7B |
| **yank** | ***UgYank*** | #F1FA8C |
| **paste** | ***UgPaste*** | #8BE9FD |
| **search** | ***UgSearch*** | #BD93F9 |
| **comment** | ***UgComment*** | #FFB86C  |

<!-- colors:end -->

### Overiding hlgroups and colors (internally)

You can easily override the colors from configuration `opts`. And the types are as below:

```lua
---@field highlights? table<"undo" | "redo" | "yank" | "paste" | "search" | "comment", { hl: string, hl_color: UndoGlow.HlColor }>

---@class UndoGlow.HlColor
---@field bg string Background color
---@field fg? string Optional for text color (Without this, it will just remain the existing text color as it is)
```

By setting hlgroup name to other value, the plugin will grab the colors of the target hlgroup and apply to it. For example:

> [!note]
> If you specify a hl other than the default, you no longer need to specify the hl_color key, as it will be ignored.

```lua
-- ✅ Valid
{
  undo = {
   hl = "Cursor",
 }
}

-- ✅ Valid
{
  undo = {
   hl_color = { bg = "#FF5555" },
 }
}

-- ✅ Valid but hl_color with be ignored
{
  undo = {
   hl = "Cursor",
   hl_color = { bg = "#FF5555" },
 }
}
```

### Overiding hlgroups and colors (externally)

> [!note]
> It's recommended to set the colors from the configuration table.

The most common way to override the colors externally are with `vim.api.nvim_set_hl`. Note that setting up this way will take precedent than **undo-glow.nvim** configurations.

```lua
-- Link to other hlgroups
vim.api.nvim_set_hl(0, "UgYank", { link = "CurSearch" })
-- Set specific colors directly
vim.api.nvim_set_hl(0, "UgYank", { bg = "#F4DBD6", fg = "#24273A" })
```

Or if you're using `snacks.nvim`, you can do as below:

```lua
-- Link to other hlgroups
Snacks.util.set_hl({ UgYank = "Cursor" }, { default = true })
-- Set specific colors directly
Snacks.util.set_hl({ UgYank = { bg = "#CBA6F7", fg = "#11111B" } }, { default = true })
```

> [!note]
> You don't have to set anything for the configuration opts if you're setting it in other places.

## 🌎 API

**undo-glow.nvim** comes with simple API and builtin commands for you to hook into your config or DIY.

### Commands

Each builtin commands takes in optional `opts` take allows to configure **color** and **animation** type per command. And the opts type as below:

> [!note]
> Each animation related options can be configured separately. If you don't, it will fallback to the default from your configuration.

```lua
---@class UndoGlow.CommandOpts
---@field hlgroup? string
---@field animation? UndoGlow.Config.Animation

---@class UndoGlow.Config.Animation
---@field enabled? boolean Turn on or off for animation
---@field duration? number Highlight duration in ms
---@field animation_type? UndoGlow.AnimationType
---@field easing? UndoGlow.EasingString | UndoGlow.EasingFn A easing string or function that computes easing.
---@field fps? number Normally either 60 / 120, up to you
```

#### Undo Highlights

```lua
---@param opts? UndoGlow.CommandOpts
require("undo-glow").undo(opts) -- Undo command with highlights
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
---@param opts? UndoGlow.CommandOpts
require("undo-glow").redo(opts) -- Redo command with highlights
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
---@param opts? UndoGlow.CommandOpts
require("undo-glow").yank(opts) -- Yank with highlights.
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
---@param opts? UndoGlow.CommandOpts
require("undo-glow").paste_below(opts) -- Paste below command with highlights
require("undo-glow").paste_above(opts) -- Paste above command with highlights
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
---@param opts? UndoGlow.CommandOpts
require("undo-glow").search_next(opts) -- Search next command with highlights
require("undo-glow").search_prev(opts) -- Search prev command with highlights
require("undo-glow").search_star(opts) -- Search current word with "*" with highlights
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
---@param opts? UndoGlow.CommandOpts
require("undo-glow").comment(opts) -- Comment with `gc` in `n` and `x` mode
require("undo-glow").comment_textobject(opts) -- Comment with `gc` in `o` mode. E.g. gcip, gcap, etc
require("undo-glow").comment_line(opts) -- Comment lines with `gcc`.
```

<details><summary>Usage Example</summary>

<!-- config:start -->

```lua
vim.keymap.set({ "n", "x" }, "gc", require("undo-glow").comment, { expr = true, noremap = true, desc = "Toggle comment with highlight" })
vim.keymap.set("o", "gc", require("undo-glow").comment_text_object, { noremap = true, desc = "Comment textobject with highlight" })
vim.keymap.set("n", "gcc", require("undo-glow").comment_line, { expr = true, noremap = true, desc = "Toggle comment line with highlight" })
```

<!-- config:end -->

</details>

### Do-it-yourself APIs

**undo-glow.nvim** also provides APIs to create your own highlights that are not supported out of the box.

#### Highlight text changes

```lua
---@class UndoGlow.HighlightChanges
---@field hlgroup? string -- Default to `UgUndo`
---@field animation? UndoGlow.Config.Animation

---@class UndoGlow.Config.Animation
---@field enabled? boolean Turn on or off for animation
---@field duration? number Highlight duration in ms
---@field animation_type? UndoGlow.AnimationType
---@field easing? UndoGlow.EasingString | UndoGlow.EasingFn A easing string or function that computes easing.
---@field fps? number Normally either 60 / 120, up to you

---@param opts? UndoGlow.HighlightChanges
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
---@param opts? UndoGlow.CommandOpts
function M.undo(opts)
 opts = require("undo-glow.utils").merge_command_opts("UgUndo", opts)
 require("undo-glow").highlight_changes(opts)
 vim.cmd("undo")
end
```

<!-- config:end -->

</details>

#### Highlight any region of your choice

```lua
---@class UndoGlow.HighlightRegion
---@field hlgroup? string
---@field animation? UndoGlow.Config.Animation
---@field s_row integer Start row
---@field s_col integer Start column
---@field e_row integer End row
---@field e_col integer End column

---@class UndoGlow.Config.Animation
---@field enabled? boolean Turn on or off for animation
---@field duration? number Highlight duration in ms
---@field animation_type? UndoGlow.AnimationType
---@field easing? UndoGlow.EasingString | UndoGlow.EasingFn A easing string or function that computes easing.
---@field fps? number Normally either 60 / 120, up to you

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
---@param opts? UndoGlow.CommandOpts
function M.yank(opts)
 opts = require("undo-glow.utils").merge_command_opts("UgYank", opts)

 local pos = vim.fn.getpos("'[")
 local pos2 = vim.fn.getpos("']")

 require("undo-glow").highlight_region(vim.tbl_extend("force", opts, {
  s_row = pos[2] - 1,
  s_col = pos[3] - 1,
  e_row = pos2[2] - 1,
  e_col = pos2[3],
 }))
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

> [!note]
> Animation is `off` by default. You can turn it on in your config with `animation.enabled = true`.

**undo-glow.nvim** comes with 4 default animations out of the box and can be toggled on and off and swap globally or per action (incuding your custom actions).

> [!note]
> If you wish to, every different action can have different animation configurations.

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

**undo-glow.nvim** comes with a handful of default easing options as below [(Thanks to EmmanuelOga/easing)](https://github.com/EmmanuelOga/easing) . Feel free to send PRs for more interesting easings.

> [!note]
> Not all animation supports easing. Only `pulse` and `fade (default)` supports easing. If you use other animation and set easing, it will just get ignored.

> [!warning]
> Easing wil be ignored if `animation.enabled` is `off`. Make sure you turn it on if you want easing.

#### Builtin easings

```lua
---@alias UndoGlow.EasingString "linear" | "in_quad" | "out_quad" | "in_out_quad" | "out_in_quad" | "in_cubic" | "out_cubic" | "in_out_cubic" | "out_in_cubic" | "in_quart" | "out_quart" | "in_out_quart" | "out_in_quart" | "in_quint" | "out_quint" | "in_out_quint" | "out_in_quint" | "in_sine" | "out_sine" | "in_out_sine" | "out_in_sine" | "in_expo" | "out_expo" | "in_out_expo" | "out_in_expo" | "in_circ" | "out_circ" | "in_out_circ" | "out_in_circ" | "in_elastic" | "out_elastic" | "in_out_elastic" | "out_in_elastic" | "in_back" | "out_back" | "in_out_back" | "out_in_back" | "in_bounce" | "out_bounce" | "in_out_bounce" | "out_in_bounce"

require("undo-glow").easing.linear
require("undo-glow").easing.in_quad
require("undo-glow").easing.out_quad
require("undo-glow").easing.in_out_quad
require("undo-glow").easing.out_in_quad
require("undo-glow").easing.in_cubic
require("undo-glow").easing.out_cubic
require("undo-glow").easing.in_out_cubic -- default
require("undo-glow").easing.out_in_cubic
require("undo-glow").easing.in_quart
require("undo-glow").easing.out_quart
require("undo-glow").easing.in_out_quart
require("undo-glow").easing.out_in_quart
require("undo-glow").easing.in_quint
require("undo-glow").easing.out_quint
require("undo-glow").easing.in_out_quint
require("undo-glow").easing.out_in_quint
require("undo-glow").easing.in_sine
require("undo-glow").easing.out_sine
require("undo-glow").easing.in_out_sine
require("undo-glow").easing.out_in_sine
require("undo-glow").easing.in_expo
require("undo-glow").easing.out_expo
require("undo-glow").easing.in_out_expo
require("undo-glow").easing.out_in_expo
require("undo-glow").easing.in_circ
require("undo-glow").easing.out_circ
require("undo-glow").easing.in_out_circ
require("undo-glow").easing.out_in_circ
require("undo-glow").easing.in_elastic
require("undo-glow").easing.out_elastic
require("undo-glow").easing.in_out_elastic
require("undo-glow").easing.out_in_elastic
require("undo-glow").easing.in_back
require("undo-glow").easing.out_back
require("undo-glow").easing.in_out_back
require("undo-glow").easing.out_in_back
require("undo-glow").easing.out_bounce
require("undo-glow").easing.in_bounce
require("undo-glow").easing.in_out_bounce
require("undo-glow").easing.out_in_bounce
```

#### Changing easing from configuration with builtin

```lua
-- configuration opts
{
 animation = {
  --- rest of configurations
  easing = "ease_in_sine"
  --- rest of configurations
 }
}
```

#### Overriding easing properties

> [!note]
> The easing function should always return an integer!

```lua
---@class UndoGlow.EasingOpts
---@field time integer Elapsed time
---@field begin? integer Begin
---@field change? integer Change == ending - beginning
---@field duration? integer Duration (total time)
---@field amplitude? integer Amplitude
---@field period? integer Period
---@field overshoot? integer Overshoot

---@param easing_opts UndoGlow.EasingOpts
---@return integer
easing = function(easing_opts)
 -- Override any properties you like
 -- You can refer to the source code of what opts are taking in from each easing function.
 easing_opts.duration = 2
 -- Then pass the `easing_opts` back to the function
 return require("undo-glow").easing.in_back(easing_opts)
end
```

#### Custom easing functions

Other than the defaults, you can also create your own easing function like below.

```lua
---@param easing_opts UndoGlow.EasingOpts
---@return integer
function my_custom_easing(easing_opts)
 easing_opts.begin = 0
 easing_opts.change = 1
 easing_opts.duration = 1

 return easing_opts.change * easing_opts.time / easing_opts.duration + easing_opts.begin
end
```

## 🤝 Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
