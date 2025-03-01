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
> I am mainly daily driving this plugin, and all commits are tested in CI (But not 100% coverage). If there's anything that are not working based on your workflow, and it should fall under the scope of this plugin, please raise an issue or even better, send in a PR for fix.

## 📝 Differences from other similar plugins

There are alot of similars plugins that you can simply find from github. The main differences of **undo-glow.nvim** from the rest are:

- **Fully configurable animations** with customizable easings
- **Exposed APIs** to create your own highlight actions
- **Per-action configuration** for colors and animations
- **Non-intrusive design** - no automatic keymaps or autocmds
- **Library potential** - use it as a foundation for other plugins
- **Tested code** - important parts of the codebase are thoroughly tested
- **Easy plugin integration** - seamlessly integrate with other plugins via the exposed highlight API

### Alternative to

- [highlight-undo.nvim](https://github.com/tzachar/highlight-undo.nvim)
- [tiny-glimmer.nvim](https://github.com/rachartier/tiny-glimmer.nvim)
- [emission.nvim](https://github.com/aileot/emission.nvim)
- [beacon.nvim](https://github.com/DanilaMihailov/beacon.nvim)

<!-- panvimdoc-ignore-start -->

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

### Significant Cursor Movement (Like beacon.nvim)

<https://github.com/user-attachments/assets/6cc42cec-fb01-48ad-b069-68779c42726f>

<!-- panvimdoc-ignore-end -->

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
> Make sure to run `:checkhealth undo-glow` if something isn't working properly.

**undo-glow.nvim** is highly configurable. And the default configurations are as below.

### Default Options

```lua
---Animation type aliases.
---@alias UndoGlow.AnimationTypeString "fade" | "fade_reverse" | "blink" | "pulse" | "jitter" | "spring" | "desaturate" | "strobe" | "zoom" | "rainbow" | "slide" | "slide_reverse"
---@alias UndoGlow.AnimationTypeFn fun(opts: UndoGlow.Animation)

---Easing function aliases.
---@alias UndoGlow.EasingString "linear" | "in_quad" | "out_quad" | "in_out_quad" | "out_in_quad" | "in_cubic" | "out_cubic" | "in_out_cubic" | "out_in_cubic" | "in_quart" | "out_quart" | "in_out_quart" | "out_in_quart" | "in_quint" | "out_quint" | "in_out_quint" | "out_in_quint" | "in_sine" | "out_sine" | "in_out_sine" | "out_in_sine" | "in_expo" | "out_expo" | "in_out_expo" | "out_in_expo" | "in_circ" | "out_circ" | "in_out_circ" | "out_in_circ" | "in_elastic" | "out_elastic" | "in_out_elastic" | "out_in_elastic" | "in_back" | "out_back" | "in_out_back" | "out_in_back" | "in_bounce" | "out_bounce" | "in_out_bounce" | "out_in_bounce"
---@alias UndoGlow.EasingFn fun(opts: UndoGlow.EasingOpts): integer

---Configuration options for undo-glow.
---@class UndoGlow.Config
---@field animation? UndoGlow.Config.Animation Configuration for animations.
---@field highlights? table<"undo" | "redo" | "yank" | "paste" | "search" | "comment" | "cursor", { hl: string, hl_color: UndoGlow.HlColor }> Highlight configurations for various actions.
---@field priority? integer Extmark priority to render the highlight (Default 4096)

---Animation configuration.
---@class UndoGlow.Config.Animation
---@field enabled? boolean Whether animation is enabled.
---@field duration? number Duration of the highlight animation in milliseconds.
---@field animation_type? UndoGlow.AnimationTypeString|UndoGlow.AnimationTypeFn Animation type (a string key or a custom function).
---@field easing? UndoGlow.EasingString|UndoGlow.EasingFn Easing function (a string key or a custom function).
---@field fps? number Frames per second for the animation.

---Options passed to easing functions.
---@class UndoGlow.EasingOpts
---@field time number Elapsed time (e.g. a progress value between 0 and 1).
---@field begin? number Optional start value.
---@field change? number Optional change value (ending minus beginning).
---@field duration? number Optional total duration.
---@field amplitude? number Optional amplitude (for elastic easing).
---@field period? number Optional period (for elastic easing).
---@field overshoot? number Optional overshoot (for back easing).

---Highlight color information.
---@class UndoGlow.HlColor
---@field bg string Background color as a hex string.
---@field fg? string Optional foreground color as a hex string.

{
 animation = {
  enabled = false, -- whether to turn on or off for animation
  duration = 100, -- in ms
  animation_type = "fade", -- default to "fade", see more at animation section on how to change or create your own
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
  cursor = {
   hl = "UgCursor", -- Same as above
   hl_color = { bg = "#FF79C6" }, -- Ugly magenta color
  },
 },
 priority = 4096, -- so that it will work with render-markdown.nvim
}
```

<details><summary>My setup in my config</summary>

<!-- config:start -->

```lua
---@type LazySpec
return {
 {
  "y3owk1n/undo-glow.nvim",
  event = { "VeryLazy" },
  ---@type UndoGlow.Config
  opts = {
   animation = {
    enabled = true,
    duration = 500,
    animtion_type = "zoom",
   },
   highlights = {
    undo = {
     hl_color = { bg = "#693232" }, -- Dark muted red
    },
    redo = {
     hl_color = { bg = "#2F4640" }, -- Dark muted green
    },
    yank = {
     hl_color = { bg = "#7A683A" }, -- Dark muted yellow
    },
    paste = {
     hl_color = { bg = "#325B5B" }, -- Dark muted cyan
    },
    search = {
     hl_color = { bg = "#5C475C" }, -- Dark muted purple
    },
    comment = {
     hl_color = { bg = "#7A5A3D" }, -- Dark muted orange
    },
    cursor = {
     hl_color = { bg = "#793D54" }, -- Dark muted pink
    },
   },
   priority = 2048 * 3,
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
     require("undo-glow").search_next({
      animation = {
       animation_type = "strobe",
      },
     })
    end,
    mode = "n",
    desc = "Search next with highlight",
    noremap = true,
   },
   {
    "N",
    function()
     require("undo-glow").search_prev({
      animation = {
       animation_type = "strobe",
      },
     })
    end,
    mode = "n",
    desc = "Search prev with highlight",
    noremap = true,
   },
   {
    "*",
    function()
     require("undo-glow").search_star({
      animation = {
       animation_type = "strobe",
      },
     })
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
    callback = function()
     vim.schedule(function()
      require("undo-glow").yank()
     end)
    end,
   })

   vim.api.nvim_create_autocmd("CursorMoved", {
    desc = "Highlight when cursor moved significantly",
    callback = function()
     vim.schedule(function()
      require("undo-glow").cursor_moved({
       animation = {
        animation_type = "slide",
       },
      })
     end)
    end,
   })
  end
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
| **cursor** | ***UgCursor*** | #FF79C6  |

<!-- colors:end -->

### Overiding hlgroups and colors (internally)

You can easily override the colors from configuration `opts`. And the types are as below:

```lua
---@field highlights? table<"undo" | "redo" | "yank" | "paste" | "search" | "comment", { hl: string, hl_color: UndoGlow.HlColor }>

---Highlight color information.
---@class UndoGlow.HlColor
---@field bg string Background color as a hex string.
---@field fg? string Optional foreground color as a hex string.
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
---Command options for triggering highlights.
---@class UndoGlow.CommandOpts
---@field hlgroup? string Optional highlight group to use.
---@field animation? UndoGlow.Config.Animation Optional animation configuration.
---@field force_edge? boolean Optional flag to force edge highlighting.

---Animation configuration.
---@class UndoGlow.Config.Animation
---@field enabled? boolean Whether animation is enabled.
---@field duration? number Duration of the highlight animation in milliseconds.
---@field animation_type? UndoGlow.AnimationTypeString|UndoGlow.AnimationTypeFn Animation type (a string key or a custom function).
---@field easing? UndoGlow.EasingString|UndoGlow.EasingFn Easing function (a string key or a custom function).
---@field fps? number Frames per second for the animation.
```

#### Undo Highlights

```lua
---Undo command that highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
require("undo-glow").undo(opts)
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
---Redo command that highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
require("undo-glow").redo(opts)
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
---Yank command that highlights.
---For autocmd usage only.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
require("undo-glow").yank(opts)
```

<details><summary>Usage Example</summary>

<!-- config:start -->

```lua
vim.api.nvim_create_autocmd("TextYankPost", {
 desc = "Highlight when yanking (copying) text",
 callback = function()
  vim.schedule(function()
  require("undo-glow").yank()
  end)
 end,
})
```

<!-- config:end -->

</details>

#### Paste Highlights

```lua
---Paste below command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
require("undo-glow").paste_below(opts)

---Paste above command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
require("undo-glow").paste_above(opts)
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
---Search next command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
require("undo-glow").search_next(opts)

---Search prev command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
require("undo-glow").search_prev(opts)

---Search star (*) command with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
require("undo-glow").search_star(opts)
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
---Comment with `gc` in `n` and `x` mode with highlights.
---Requires `expr` = true in ``vim.keymap.set`
---@param opts? UndoGlow.CommandOpts Optional command option
---@return string|nil expression String for expression and nil for non-expression
require("undo-glow").comment(opts)

---Comment with `gc` in `o` mode. E.g. gcip, gcap, etc with highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
require("undo-glow").comment_textobject(opts)

---Comment lines with `gcc` with highlights.
---Requires `expr` = true in ``vim.keymap.set`
---@param opts? UndoGlow.CommandOpts Optional command option
---@return string expression String for expression
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

#### Significant Cursor Moved Highlights

Best effort to imitate [beacon.nvim](https://github.com/DanilaMihailov/beacon.nvim) functionality. Highlights when:

- Cursor moved more than 10 steps away
- On buffer load
- Split view supported

For now the following are ignored:

- Preview windows
- Floating windows
- Buffers that are not text buffers
- Filetypes that are passed in to be ignored

> [!WARNING]
> This is not a command and it is designed to be used in autocmd callback.

```lua
---Cursor move command that highlights.
---For autocmd usage only.
---@param opts? UndoGlow.CommandOpts Optional command option
---@param ignored_ft? table<string> Optional filetypes to ignore
---@return nil
require("undo-glow").cursor_moved(opts, ignored_ft)
```

<details><summary>Usage Example</summary>

<!-- config:start -->

```lua
vim.api.nvim_create_autocmd("CursorMoved", {
 desc = "Highlight when cursor moved significantly",
 callback = function()
  vim.schedule(function()
   require("undo-glow").cursor_moved()
  end)
 end,
})

-- Ignore certain filetype
vim.api.nvim_create_autocmd("CursorMoved", {
 desc = "Highlight when cursor moved significantly",
 callback = function()
  vim.schedule(function()
   require("undo-glow").cursor_moved(_, { "mason", "lazy", ... })
  end)
 end,
})
```

<!-- config:end -->

</details>

### Do-it-yourself APIs

**undo-glow.nvim** also provides APIs to create your own highlights that are not supported out of the box.

#### Highlight text changes

```lua
---Options for highlight changes API.
---@class UndoGlow.HighlightChanges
---@field hlgroup? string Optional highlight group to use.
---@field animation? UndoGlow.Config.Animation Optional animation configuration.
---@field force_edge? boolean Optional flag to force edge highlighting.

---Animation configuration.
---@class UndoGlow.Config.Animation
---@field enabled? boolean Whether animation is enabled.
---@field duration? number Duration of the highlight animation in milliseconds.
---@field animation_type? UndoGlow.AnimationTypeString|UndoGlow.AnimationTypeFn Animation type (a string key or a custom function).
---@field easing? UndoGlow.EasingString|UndoGlow.EasingFn Easing function (a string key or a custom function).
---@field fps? number Frames per second for the animation.

---Core API to highlight changes in the current buffer.
---@param opts? UndoGlow.HighlightChanges|UndoGlow.CommandOpts
---@return nil
require("undo-glow").highlight_changes(opts)
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
---Undo command that highlights.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
function M.undo(opts)
 opts = require("undo-glow.utils").merge_command_opts("UgUndo", opts)
 require("undo-glow").highlight_changes(opts)
 pcall(vim.cmd, "undo")
end
```

<!-- config:end -->

</details>

#### Highlight any region of your choice

```lua
---Options for highlight region API.
---@class UndoGlow.HighlightRegion
---@field hlgroup? string Optional highlight group to use.
---@field animation? UndoGlow.Config.Animation Optional animation configuration.
---@field force_edge? boolean Optional flag to force edge highlighting.
---@field s_row integer Start row
---@field s_col integer Start column
---@field e_row integer End row
---@field e_col integer End column

---Animation configuration.
---@class UndoGlow.Config.Animation
---@field enabled? boolean Whether animation is enabled.
---@field duration? number Duration of the highlight animation in milliseconds.
---@field animation_type? UndoGlow.AnimationTypeString|UndoGlow.AnimationTypeFn Animation type (a string key or a custom function).
---@field easing? UndoGlow.EasingString|UndoGlow.EasingFn Easing function (a string key or a custom function).
---@field fps? number Frames per second for the animation.

---Core API to highlight a specified region in the current buffer.
---@param opts UndoGlow.HighlightRegion
---@return nil
require("undo-glow").highlight_region(opts)
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
---Yank command that highlights.
---For autocmd usage only.
---@param opts? UndoGlow.CommandOpts Optional command option
---@return nil
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

**undo-glow.nvim** comes with numerous default animations out of the box and can be toggled on and off and swap globally or per action (incuding your custom actions).

> [!note]
> If you wish to, every different action can have different animation configurations.

```lua
---@alias UndoGlow.AnimationTypeString "fade" <- default | "fade_reverse" | "blink" | "pulse" | "jitter" | "spring" | "desaturate" | "strobe" | "zoom" | "rainbow" | "slide" | "slide_reverse"
---@alias UndoGlow.AnimationTypeFn fun(opts: UndoGlow.Animation)

---@field animation_type? UndoGlow.AnimationTypeString | UndoGlow.AnimationTypeFn A animation_type string or function that does the animation
```

<!-- panvimdoc-ignore-start -->

#### Animation previews

##### No Animation

Static highlight and will be cleared after a duration immediately.

<https://github.com/user-attachments/assets/7ea4b7fb-9c04-445c-a397-914b76c240f1>

##### Fade (Default)

Gradually increases or decreases the opacity of the highlight, creating a smooth fading effect.

<https://github.com/user-attachments/assets/06820af3-1c37-445c-9e3d-946c277d946a>

##### Blink

Toggles the highlight on and off at a fixed interval, similar to a cursor blink.

<https://github.com/user-attachments/assets/8afee494-f9a0-4eef-9c9e-86a5c0c56eae>

##### Pulse

Alternates the highlight intensity in a rhythmic manner, creating a breathing effect.

<https://github.com/user-attachments/assets/68145ed1-326e-4f64-8dcf-3edae8baeb31>

##### Jitter

Rapidly moves or shifts the highlight slightly, giving a shaky or vibrating appearance.

<https://github.com/user-attachments/assets/8627ee17-2ac7-4571-a897-3422cebe0e1b>

##### Spring

Overshoots the target color and then settles, mimicking a spring-like motion.

<https://github.com/user-attachments/assets/bd19d4d6-0585-4705-bd56-1efcf18f3565>

##### Desaturate

Gradually reduces the color saturation, muting the highlight over time.

<https://github.com/user-attachments/assets/a16ec21f-524d-4805-83d4-b56d0c59f1d1>

##### Strobe

Rapidly toggles between two colors to simulate a strobe light effect.

<https://github.com/user-attachments/assets/8e0fd3bf-2a8b-4e0a-a5c1-8430e06bdba2>

##### Zoom

Briefly increases brightness to simulate a zoom or spotlight effect before returning to normal.

<https://github.com/user-attachments/assets/93e9da9a-771c-4988-acdd-2c796f04b306>

##### Rainbow

Cycles through hues smoothly, creating a rainbow-like transition effect.

<https://github.com/user-attachments/assets/d287ad33-de80-47e1-8f93-7bfa7215afff>

##### Slide

Moves the highlight horizontally to the right across the text before fading out.

> [!note]
> Only supports single-line highlights.

<https://github.com/user-attachments/assets/92d9b490-7f8c-4a06-a9ff-6a15af2ad531>

##### Slide Reverse

Moves the highlight horizontally to the left, reversing the slide effect. Only supports single-line highlights.

> [!note]
> Only supports single-line highlights.

<https://github.com/user-attachments/assets/40e6036d-ad77-4fb0-ae3f-3056ea77659c>

<!-- panvimdoc-ignore-end -->

#### Changing animation from configuration

##### Animation type in string

```lua
-- configuration opts
{
 animation = {
  --- rest of configurations
  animation_type = "jitter" -- one of the builtins
  --- rest of configurations
 }
}
```

##### Animation type in function

> [!warning]
> This API is just re-exported from the source code and that's exactly how the animation internally works.
> There's a lot of manual configuration for now, and I don't think lots of people will want to configure their own animation.
> But hey, if you need to, it's there for you.

```lua
---Parameters for an animation.
---@class UndoGlow.Animation
---@field bufnr integer Buffer number.
---@field hlgroup string Highlight group name.
---@field extmark_id integer Extmark identifier.
---@field start_bg UndoGlow.RGBColor Starting background color.
---@field end_bg UndoGlow.RGBColor Ending background color.
---@field start_fg? UndoGlow.RGBColor Optional starting foreground color.
---@field end_fg? UndoGlow.RGBColor Optional ending foreground color.
---@field duration number Animation duration in milliseconds.
---@field config UndoGlow.Config Configuration for undo-glow.
---@field state UndoGlow.State Current state of the highlight.

-- configuration opts
{
 animation = {
  ---rest of configurations
  ---@param opts UndoGlow.Animation The animation options.
  ---@return boolean|nil status Return `false` to fallback to fade
  animation_type = function(opts)
   --- Sometimes thing just don't work and if your custom animation don't support certain thing
   --- You can return false, and it will fallback to `fade` animation.
   --- E.g. since `e_col` will always be 0 if you highlight with visual block, it will be troublesome to do calculation.
   if should_fallback then
    return false
   end

   ---@param opts UndoGlow.Animation The animation options.
   ---@param animate_fn fun(progress: number): UndoGlow.HlColor|nil A function that receives the current progress (0 = start, 1 = end) and return the hl colors or nothing.
   ---@return nil
   require("undo-glow").animate_start(opts, function(progress)
    -- do something for your animation
    -- normally you will do some calculation with the progress value (0 = start, 1 = end)
    -- you also have access to the current extmark via `opts.extmark_id`
    -- lastly, return the bg and fg (optional) if you want the color to be set automatically or...
    -- not return anything, but you need to set the color yourself in this function
    return hl_opts
   end)
  end
  --- rest of configurations
 }
}
```

##### Example using `blink` animation from source code

```lua
-- configuration opts
{
 animation = {
  --- rest of configurations
  animation_type = function(opts)
   require("undo-glow").animate_start(opts, function(progress)
      local blink_period = 200
      local phase = (progress * opts.duration % blink_period) < (blink_period / 2)

      if phase then
        return {
          bg = require("undo-glow.color").rgb_to_hex(opts.start_bg),
          fg = opts.start_fg and require("undo-glow.color").rgb_to_hex(opts.start_fg) or nil,
        }
      else
        return {
          bg = require("undo-glow.color").rgb_to_hex(opts.end_bg),
          fg = opts.end_fg and require("undo-glow.color").rgb_to_hex(opts.end_fg) or nil,
        }
      end
   end)
  end
  --- rest of configurations
 }
}
```

### Easing

**undo-glow.nvim** comes with a handful of default easing options as below [(Thanks to EmmanuelOga/easing)](https://github.com/EmmanuelOga/easing) . Feel free to send PRs for more interesting easings.

> [!note]
> Not all animation supports easing. Only `fade (default)` and `fade_reverse` supports easing. If you use other animation and set easing, it will just get ignored.

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

##### Easing in string

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

##### Easing in function

```lua
-- configuration opts
{
 animation = {
  --- rest of configurations
  easing = function(easing_opts)
   -- do some calculation
   return integer
  end
  --- rest of configurations
 }
}
```

#### Overriding easing properties

> [!note]
> The easing function should always return an integer!

```lua
---Options passed to easing functions.
---@class UndoGlow.EasingOpts
---@field time number Elapsed time (e.g. a progress value between 0 and 1).
---@field begin? number Optional start value.
---@field change? number Optional change value (ending minus beginning).
---@field duration? number Optional total duration.
---@field amplitude? number Optional amplitude (for elastic easing).
---@field period? number Optional period (for elastic easing).
---@field overshoot? number Optional overshoot (for back easing).

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
