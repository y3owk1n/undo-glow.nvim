# 🌈 undo-glow.nvim

**undo-glow.nvim** is a Neovim plugin that adds beautiful visual feedback to your edits. See exactly what changed when you undo, redo, paste, search, or perform any text operation.

> [!note]
> This plugin requires manual setup—no keymaps are created automatically. See the [Quick Start](#-quick-start) guide below to get started in minutes!

## ✨ Features

- **Visual feedback for all text operations** - Undo, redo, paste, search, comments, and more
- **Beautiful animations** - Smooth fades, pulses, bounces, and 10+ other effects
- **Zero dependencies** - Uses only Neovim's native APIs
- **Highly customizable** - Change colors, duration, and animation styles per action
- **Works with your favorite plugins** - Built-in support for yanky.nvim, substitute.nvim, flash.nvim

<!-- panvimdoc-ignore-start -->

## 👀 Quick Preview

### Undo

<https://github.com/user-attachments/assets/4c042f5c-fb7f-4a1e-a3d9-e2ab43ae215a>

### Redo

<https://github.com/user-attachments/assets/08ea2ecc-2c48-4dad-9982-4e3c904b5ec2>

### Yank

<https://github.com/user-attachments/assets/4a9548f1-af55-43fc-8c6a-963d61a42661>

### Paste

<https://github.com/user-attachments/assets/07281bcc-e9ea-41c1-b7b6-100a61c4b0ab>

### Search

<https://github.com/user-attachments/assets/dba2e3dc-578c-459f-b2a8-23755ddd5adf>

### Comment

<https://github.com/user-attachments/assets/30346f75-30d8-4aef-9aa0-71ed26834a48>

### Significant Cursor Movement (Like beacon.nvim)

<https://github.com/user-attachments/assets/89b9e385-3bb4-47ad-8e35-bbdf38d78a87>

<!-- panvimdoc-ignore-end -->

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "y3owk1n/undo-glow.nvim",
  version = "*", -- use stable releases
  opts = {
    -- your configuration (see Quick Start below)
  }
}
```

For other package managers, call `setup()` manually:

```lua
require("undo-glow").setup({
  animation = {
    enabled = true,
    duration = 300,
  }
})
```

## 🚀 Quick Start

Here's a complete, ready-to-use configuration that covers the most common use cases:

```lua
{
  "y3owk1n/undo-glow.nvim",
  event = { "VeryLazy" },
  ---@type UndoGlow.Config
  opts = {
    animation = {
      enabled = true,
      duration = 300,
      animation_type = "zoom",
      window_scoped = true,
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
      "#",
      function()
        require("undo-glow").search_hash({
          animation = {
            animation_type = "strobe",
          },
        })
      end,
      mode = "n",
      desc = "Search hash with highlight",
      noremap = true,
    },
    {
      "gc",
      function()
        -- This is an implementation to preserve the cursor position
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
        require("undo-glow").yank()
      end,
    })

    -- This only handles neovim instance and do not highlight when switching panes in tmux
    vim.api.nvim_create_autocmd("CursorMoved", {
      desc = "Highlight when cursor moved significantly",
      callback = function()
        require("undo-glow").cursor_moved({
          animation = {
            animation_type = "slide",
          },
        })
      end,
    })

    -- This will handle highlights when focus gained, including switching panes in tmux
    vim.api.nvim_create_autocmd("FocusGained", {
      desc = "Highlight when focus gained",
      callback = function()
        ---@type UndoGlow.CommandOpts
        local opts = {
          animation = {
            animation_type = "slide",
          },
        }

        opts = require("undo-glow.utils").merge_command_opts("UgCursor", opts)
        local pos = require("undo-glow.utils").get_current_cursor_row()

        require("undo-glow").highlight_region(vim.tbl_extend("force", opts, {
          s_row = pos.s_row,
          s_col = pos.s_col,
          e_row = pos.e_row,
          e_col = pos.e_col,
          force_edge = opts.force_edge == nil and true or opts.force_edge,
        }))
      end,
    })

    vim.api.nvim_create_autocmd("CmdlineLeave", {
      desc = "Highlight when search cmdline leave",
      callback = function()
        require("undo-glow").search_cmd({
          animation = {
            animation_type = "fade",
          },
        })
      end,
    })
  end,
},
```

**That's it!** You now have beautiful visual feedback for all your edits. 🎉

> [!tip]
> Want to customize colors, animations, or add more features? Check out the [Configuration Guide](#%EF%B8%8F-configuration-guide) below.

## ⚙️ Configuration Guide

### Basic Configuration

The main settings you'll want to customize:

```lua
opts = {
  animation = {
    enabled = true,        -- Turn animations on/off
    duration = 300,        -- How long highlights last (milliseconds)
    animation_type = "fade", -- Animation style (see options below)
  },
  highlights = {
    undo = { hl_color = { bg = "#FF5555" } },  -- Red for undo
    redo = { hl_color = { bg = "#50FA7B" } },  -- Green for redo
    -- ... customize other operations
  },
}
```

### Animation Types

Choose from 11 built-in animation styles:

- `"fade"` - Smooth fade out (default)
- `"pulse"` - Breathing effect
- `"zoom"` - Brief brightness increase
- `"slide"` - Moves right before fading
- `"blink"` - Rapid on/off toggle
- `"strobe"` - Rapid color changes
- `"jitter"` - Shaky/vibrating effect
- `"spring"` - Overshoots then settles
- `"rainbow"` - Cycles through colors
- `"desaturate"` - Gradually mutes colors
- `"fade_reverse"` - Smooth fade in

<!-- panvimdoc-ignore-start -->

#### Animation Previews

##### No Animation

Static highlight cleared after duration.

<https://github.com/user-attachments/assets/661ca359-7bdb-43e0-ba25-e8678af0ca5d>

##### Fade (Default)

Gradually decreases opacity.

<https://github.com/user-attachments/assets/f030ca76-c60e-4ce9-a67c-e6b4e5c054ac>

##### Fade Reverse

Gradually increases opacity.

<https://github.com/user-attachments/assets/1f555fab-b69a-4ad3-b335-eb1106fd2356>

##### Blink

Toggles highlight on and off.

<https://github.com/user-attachments/assets/3283e4ba-fcf6-4a3e-92f2-fd60c55bce9d>

##### Pulse

Rhythmic breathing effect.

<https://github.com/user-attachments/assets/4b5c39bf-d33b-4b16-b273-730e5fbd03af>

##### Jitter

Rapid shaking/vibrating.

<https://github.com/user-attachments/assets/b593a666-a45f-49bc-a250-75479e1cfdca>

##### Spring

Overshoots then settles.

<https://github.com/user-attachments/assets/94cc4c93-439e-46ad-88bf-314df5fddc5b>

##### Desaturate

Gradually reduces saturation.

<https://github.com/user-attachments/assets/8d4fdf8c-d8be-4e72-8727-4a69d4f0d140>

##### Strobe

Rapid color toggles.

<https://github.com/user-attachments/assets/31ad3be7-8f5b-4e21-9fe3-ae07c1646699>

##### Zoom

Brief brightness increase.

<https://github.com/user-attachments/assets/06b252c1-3940-41c0-b3ad-c4f88688663f>

##### Rainbow

Cycles through hues smoothly.

<https://github.com/user-attachments/assets/cae9862e-acb5-4976-a921-16e5e8a32b90>

##### Slide

Moves right before fading.

<https://github.com/user-attachments/assets/7cb24aae-86cc-48f9-aab8-eb5171f2160c>

<!-- panvimdoc-ignore-end -->

### Color Customization

Three ways to set colors:

```lua
-- 1. Direct color (hex code)
highlights = {
  undo = { hl_color = { bg = "#FF5555" } }
}

-- 2. Link to existing highlight group
highlights = {
  undo = { hl = "Cursor" }
}

-- 3. Use vim.api.nvim_set_hl (in your config)
vim.api.nvim_set_hl(0, "UgUndo", { bg = "#FF5555" })
```

### Per-Operation Settings

Customize animations for specific operations:

```lua
keys = {
  -- Use "zoom" for searches
  {
    "n",
    function()
      require("undo-glow").search_next({
        animation = { animation_type = "zoom" }
      })
    end,
    desc = "Search next"
  },

  -- Use "pulse" for undo
  {
    "u",
    function()
      require("undo-glow").undo({
        animation = { animation_type = "pulse" }
      })
    end,
    desc = "Undo"
  },
}
```

## 📚 Common Use Cases

### Highlight Cursor Movement (Like beacon.nvim)

Show where your cursor lands after big jumps:

```lua
init = function()
  vim.api.nvim_create_autocmd("CursorMoved", {
    callback = function()
      require("undo-glow").cursor_moved({
        animation = { animation_type = "slide" }
      }, {
        steps_to_trigger = 10, -- Jump threshold
        ignored_ft = { "mason", "lazy" }, -- Skip these filetypes
      })
    end,
  })
end
```

### Highlight Comments

Visual feedback when toggling comments:

```lua
keys = {
  {
    "gc",
    function()
      local pos = vim.fn.getpos(".")
      vim.schedule(function() vim.fn.setpos(".", pos) end)
      return require("undo-glow").comment()
    end,
    mode = { "n", "x" },
    expr = true,
    desc = "Toggle comment"
  },
  {
    "gcc",
    function()
      return require("undo-glow").comment_line()
    end,
    expr = true,
    desc = "Comment line"
  },
}
```

### Plugin Integrations

#### yanky.nvim

```lua
-- Turn off yanky's built-in highlights
require("yanky").setup({
  highlight = {
    on_put = false,
    on_yank = false,
  }
})

-- Add undo-glow highlights
vim.keymap.set("n", "p", function()
  return require("undo-glow").yanky_put("YankyPutAfter")
end, { expr = true, desc = "Paste below" })
```

#### substitute.nvim

```lua
-- Turn off substitute's highlights
require("substitute").setup({
  highlight_substituted_text = { enabled = false }
})

-- Add undo-glow highlights
vim.keymap.set("n", "s", function()
  require("undo-glow").substitute_action(require("substitute").operator)
end, { desc = "Substitute" })
```

#### flash.nvim

```lua
-- Highlight cursor after jumping
vim.keymap.set({ "n", "x", "o" }, "s", function()
  require("undo-glow").flash_jump()
end, { desc = "Flash jump" })
```

## 🎨 Available Highlight Groups

Default colors (customize these in your config):

| Group       | Default Color       | Purpose         |
| ----------- | ------------------- | --------------- |
| `UgUndo`    | `#FF5555` (red)     | Undo operations |
| `UgRedo`    | `#50FA7B` (green)   | Redo operations |
| `UgYank`    | `#F1FA8C` (yellow)  | Yank/copy       |
| `UgPaste`   | `#8BE9FD` (cyan)    | Paste           |
| `UgSearch`  | `#BD93F9` (purple)  | Search          |
| `UgComment` | `#FFB86C` (orange)  | Comments        |
| `UgCursor`  | `#FF79C6` (magenta) | Cursor movement |

## 🔍 Troubleshooting

Run the health check if something isn't working:

```vim
:checkhealth undo-glow
```

Common issues:

- **Animations not showing?** Make sure `animation.enabled = true`
- **Wrong colors?** Check if your theme is overriding the highlight groups
- **Performance issues?** Try increasing `debounce_delay` or disabling animations

## 📖 More Resources

- **[Recipes](recipes.md)** - More configuration examples
- **[Advanced Documentation](#-advanced-documentation)** - APIs, custom animations, performance tuning
- **[GitHub Issues](https://github.com/y3owk1n/undo-glow.nvim/issues)** - Report bugs or request features

---

# 🚀 Advanced Documentation

> [!note]
> **For advanced users only!** If you're happy with the basic setup above, you don't need to read this section.

The sections below cover advanced topics like creating custom animations, performance tuning, and extending the plugin with hooks and APIs.

<details>
<summary><b>📋 Table of Contents</b></summary>

- [Full Configuration Options](#full-configuration-options)
- [Performance Tuning](#performance-tuning)
- [Logging Configuration](#logging-configuration)
- [Core APIs](#core-apis)
- [Enhanced API System](#enhanced-api-system)
- [Custom Animations](#custom-animations)
- [Custom Easing Functions](#custom-easing-functions)
- [Plugin Development](#plugin-development)

</details>

## Full Configuration Options

Complete reference for all available options:

```lua
{
  animation = {
    enabled = false,
    duration = 100,              -- milliseconds
    animation_type = "fade",     -- or custom function
    fps = 120,                   -- frames per second
    easing = "in_out_cubic",     -- or custom function
    window_scoped = false,       -- experimental: restrict to active window
  },

  fallback_for_transparency = {
    bg = "#000000",              -- fallback when transparent
    fg = "#FFFFFF",
  },

  highlights = {
    undo = {
      hl = "UgUndo",             -- highlight group name
      hl_color = { bg = "#FF5555" }
    },
    -- ... other operations
  },

  priority = 4096,               -- extmark priority

  performance = {
    color_cache_size = 1000,
    debounce_delay = 50,
    animation_skip_unchanged = true,
  },

  logging = {
    level = "INFO",              -- TRACE, DEBUG, INFO, WARN, ERROR, OFF
    notify = true,               -- show in notifications
    file = false,                -- write to log file
    file_path = nil,             -- custom log path
  },
}
```

## Performance Tuning

Optimize the plugin for your machine:

### Color Caching

```lua
performance = {
  color_cache_size = 1000, -- Higher = faster, more memory
}
```

- **Fast machines**: Increase to 2000+
- **Slow machines**: Decrease to 500

### Debouncing

```lua
performance = {
  debounce_delay = 50, -- milliseconds
}
```

- **Responsive**: Lower values (25-50ms)
- **Performance**: Higher values (100-200ms)

### Animation Optimization

```lua
performance = {
  animation_skip_unchanged = true, -- Skip redundant frames
}
```

Set to `false` only for debugging.

## Logging Configuration

Configure detailed logging for debugging:

```lua
logging = {
  level = "DEBUG",     -- Show detailed info
  notify = true,       -- Display in Neovim
  file = true,         -- Write to file
  file_path = "/tmp/undo-glow.log",
}
```

**Log Levels:**

- `TRACE` - Everything (very verbose)
- `DEBUG` - Detailed debugging
- `INFO` - General info (default)
- `WARN` - Warnings only
- `ERROR` - Errors only
- `OFF` - No logging

## Core APIs

Create your own highlight commands:

### Highlight Text Changes

Automatically detect and highlight changed text:

```lua
function my_custom_action()
  require("undo-glow").highlight_changes({
    hlgroup = "UgUndo",
    animation = { animation_type = "pulse" }
  })

  -- Your action that modifies text
  vim.cmd("normal! diw")
end

vim.keymap.set("n", "<leader>x", my_custom_action)
```

### Highlight Specific Region

Highlight exact coordinates:

```lua
function highlight_current_word()
  local pos = vim.fn.getpos(".")
  local word_start = vim.fn.searchpos("\\<", "bn", pos[2])[2]
  local word_end = vim.fn.searchpos("\\>", "n", pos[2])[2]

  require("undo-glow").highlight_region({
    hlgroup = "UgSearch",
    s_row = pos[2] - 1,
    s_col = word_start - 1,
    e_row = pos[2] - 1,
    e_col = word_end,
  })
end
```

## Enhanced API System

For plugin developers and power users who want to extend functionality:

### Hooks System

Intercept and modify plugin behavior:

```lua
local api = require("undo-glow.api")

-- Run before any highlight operation
api.register_hook("pre_highlight", function(data)
  print("About to highlight:", data.operation)

  -- Modify the highlight color
  if data.operation == "undo" then
    data.hl_color = { bg = "#FF0000" } -- Override the background color
 -- data.hlgroup = "TermCursor" -- Use other group
    -- Or set the highlight group directly:
    -- vim.api.nvim_set_hl(0, "UgUndo", { bg = "#FF0000" })
  end
end, 100) -- priority (higher = runs first)
```

**Available Hooks:**

- `on_config_change` - Configuration updates
- `pre_highlight` / `post_highlight` - All highlight operations
- `pre_animation` / `post_animation` - Animation lifecycle
- `on_error` - Error handling
- `pre_highlight_setup` / `post_highlight_setup` - Highlight group creation

**Hook Data Modifications:**

- `data.hl_color` - Override the highlight color (takes precedence over config)
- `data.hlgroup` - Change the highlight group used
- Other fields like `data.operation` are read-only

### Event System

Subscribe to plugin events:

```lua
local api = require("undo-glow.api")

-- Track command usage
api.subscribe("command_executed", function(data)
  print("Command:", data.command)
  print("Operation:", data.opts.operation)
end)

-- Monitor configuration changes
api.subscribe("config_changed", function(data)
  print("Config updated!")
  print("Changes:", vim.inspect(data.changes))
end)

-- Handle errors
api.subscribe("log_message", function(data)
  if data.level == "ERROR" then
    print("Error:", data.message)
  end
end)
```

**Available Events:**

- `command_executed` - Command operations
- `config_changed` / `config_error` - Configuration lifecycle
- `buffer_changed` - Text modifications
- `log_message` - Logging events
- `color_conversion` / `color_cache_hit` - Color processing

### Dynamic Configuration

Change settings at runtime:

```lua
local api = require("undo-glow.api")

-- Build and apply new configuration
api.config_builder()
  :animation({
    enabled = true,
    duration = 500,
    animation_type = "spring"
  })
  :performance({
    debounce_delay = 100
  })
  :build() -- Applies immediately

-- Listen for changes
api.subscribe("config_changed", function(data)
  print("New config:", vim.inspect(data.new_config))
end)
```

### Operation-Based Customization

Customize behavior per operation type:

```lua
local api = require("undo-glow.api")

-- Different animations for different operations
api.register_hook("pre_animation", function(data)
  local search_ops = { "search_next", "search_prev", "search_star", "search_hash" }

  if vim.tbl_contains(search_ops, data.operation) then
    data.animation_type = "rainbow"
  elseif data.operation == "cursor_moved" then
    data.animation_type = "spring"
  elseif data.operation == "undo" then
    data.animation_type = "pulse"
  end
end)

-- Different colors per operation
api.register_hook("pre_highlight", function(data)
  if data.operation == "undo" then
    data.hl_color = { bg = "#4A90E2" }
  elseif data.operation == "search_next" then
    data.hl_color = { bg = "#50C878" }
  end
end)
```

**Available Operations:**

- `undo`, `redo` - Undo/redo
- `yank` - Copy
- `paste_below`, `paste_above` - Paste
- `search_next`, `search_prev`, `search_star`, `search_hash`, `search_cmd` - Search
- `comment`, `comment_textobject`, `comment_line` - Comments
- `cursor_moved` - Cursor movement
- `yanky_paste`, `substitute_paste` - Plugin integrations

## Custom Animations

Create your own animation effects:

```lua
local api = require("undo-glow.api")

-- Register custom animation
api.register_animation("my_bounce", function(opts)
  -- Step 1: Create extmark for highlighting (REQUIRED!)
  local extmark_opts = require("undo-glow.utils").create_extmark_opts({
    bufnr = opts.bufnr,
    hlgroup = opts.hlgroup,
    s_row = opts.coordinates.s_row,
    s_col = opts.coordinates.s_col,
    e_row = opts.coordinates.e_row,
    e_col = opts.coordinates.e_col,
    priority = require("undo-glow.config").config.priority,
    force_edge = opts.state.force_edge,
    window_scoped = opts.state.animation.window_scoped,
  })

  -- Step 2: Set the extmark
  local extmark_id = vim.api.nvim_buf_set_extmark(
    opts.bufnr,
    opts.ns,
    opts.coordinates.s_row,
    opts.coordinates.s_col,
    extmark_opts
  )

  -- Step 3: Add to extmark list
  table.insert(opts.extmark_ids, extmark_id)

  -- Step 4: Animate
  require("undo-glow.animation").animate_start(opts, function(progress)
    local bounce = math.abs(math.sin(progress * math.pi * 4))
    return {
      bg = string.format("#%02X%02X%02X",
        math.floor(255 * bounce),
        math.floor(100 * (1 - bounce)),
        math.floor(50 * bounce)
      )
    }
  end)
end)

-- Use it
require("undo-glow").setup({
  animation = {
    enabled = true,
    animation_type = "my_bounce"
  }
})
```

## Custom Easing Functions

Create custom easing for smooth animations:

```lua
-- Built-in easings
require("undo-glow").setup({
  animation = {
    easing = "in_out_cubic" -- or any other built-in
  }
})
```

**Available Easings:**
`linear`, `in_quad`, `out_quad`, `in_out_quad`, `in_cubic`, `out_cubic`, `in_out_cubic`, `in_quart`, `out_quart`, `in_sine`, `out_sine`, `in_expo`, `out_expo`, `in_circ`, `out_circ`, `in_elastic`, `out_elastic`, `in_back`, `out_back`, `in_bounce`, `out_bounce`

### Custom Easing Function

```lua
local function my_easing(opts)
  -- opts.time is progress (0 to 1)
  -- Return integer between 0 and opts.duration
  return math.floor(opts.time * opts.time * opts.duration)
end

require("undo-glow").setup({
  animation = {
    easing = my_easing
  }
})
```

## Plugin Development

### Real-World Examples

#### Add Sound Effects

```lua
local api = require("undo-glow.api")

api.register_hook("post_highlight", function(data)
  if data.operation == "undo" then
    vim.fn.system("afplay /System/Library/Sounds/Blow.aiff &")
  elseif data.operation == "redo" then
    vim.fn.system("afplay /System/Library/Sounds/Glass.aiff &")
  end
end)
```

#### Usage Analytics

```lua
local api = require("undo-glow.api")
local stats = { undo = 0, redo = 0 }

api.subscribe("command_executed", function(data)
  if data.command == "undo" then
    stats.undo = stats.undo + 1
  elseif data.command == "redo" then
    stats.redo = stats.redo + 1
  end

  print(string.format("Undo: %d, Redo: %d", stats.undo, stats.redo))
end)
```

#### Context-Aware Colors

```lua
local api = require("undo-glow.api")

api.register_hook("pre_highlight", function(data)
  local ft = vim.bo.filetype

  if ft == "lua" then
    data.hl_color = { bg = "#4A90E2" } -- Blue for Lua
  elseif ft == "python" then
    data.hl_color = { bg = "#3776AB" } -- Python blue
  elseif ft == "javascript" then
    data.hl_color = { bg = "#F7DF1E" } -- JS yellow
  end
end)
```

#### Git Integration

```lua
local api = require("undo-glow.api")

api.register_hook("post_highlight", function(data)
  if data.operation == "yank" and package.loaded.gitsigns then
    -- Refresh git signs after yank
    require("gitsigns").refresh()
  end
end)
```

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Read the documentation carefully
2. Check existing issues before creating new ones
3. Test your changes thoroughly
4. Follow the existing code style

## 📝 Differences from Similar Plugins

**Why choose undo-glow.nvim?**

- ✅ **Fully configurable animations** with custom easings
- ✅ **Exposed APIs** for plugin developers
- ✅ **Per-operation configuration** for colors and animations
- ✅ **Non-intrusive** - no automatic keymaps
- ✅ **Library potential** - use as foundation for other plugins
- ✅ **Thoroughly tested** - core functionality tested
- ✅ **Easy plugin integration** - seamless interop
- ✅ **Window-specific highlighting** - works with splits

### Alternatives

- [highlight-undo.nvim](https://github.com/tzachar/highlight-undo.nvim)
- [tiny-glimmer.nvim](https://github.com/rachartier/tiny-glimmer.nvim)
- [emission.nvim](https://github.com/aileot/emission.nvim)
- [beacon.nvim](https://github.com/DanilaMihailov/beacon.nvim)

## 📄 License

MIT License - see LICENSE file for details.
