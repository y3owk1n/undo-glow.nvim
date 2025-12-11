# Recipes

> [!note]
> If you have more recipes, feel free to send a PR to add them here.

## 🎨 Operation-Based Animation Customization

Customize animations based on the type of operation using hooks:

```lua
local api = require("undo-glow.api")

-- Different animations for different operations
api.register_hook("pre_animation", function(data)
  -- Search operations get rainbow animation
  local search_ops = { "search_next", "search_prev", "search_star", "search_hash" }
  if vim.tbl_contains(search_ops, data.operation) then
    data.animation_type = "rainbow"
  -- Cursor movement gets bounce
  elseif data.operation == "cursor_moved" then
    data.animation_type = "bounce"
  -- Comments get strobe effect
  elseif vim.startswith(data.operation, "comment") then
    data.animation_type = "strobe"
  -- Undo/Redo get pulse
  elseif data.operation == "undo" or data.operation == "redo" then
    data.animation_type = "pulse"
  end
end, 75)

-- Different colors per operation
api.register_hook("pre_highlight", function(data)
  if data.operation == "undo" then
    data.hl_color = { bg = "#4A90E2", fg = "#FFFFFF" } -- Blue for undo
  elseif data.operation == "redo" then
    data.hl_color = { bg = "#E94B3C", fg = "#FFFFFF" } -- Red for redo
  elseif vim.startswith(data.operation, "search") then
    data.hl_color = { bg = "#50C878", fg = "#000000" } -- Green for search
  end
end, 50)
```

## 🛠️ Custom Animation Creation

Create your own animations with full control:

```lua
local api = require("undo-glow.api")

-- Register a custom "sparkle" animation
api.register_animation("sparkle", function(opts)
  -- Create extmark for highlighting (REQUIRED!)
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

  local extmark_id = vim.api.nvim_buf_set_extmark(
    opts.bufnr,
    opts.ns,
    opts.coordinates.s_row,
    opts.coordinates.s_col,
    extmark_opts
  )

  table.insert(opts.extmark_ids, extmark_id)

  -- Start the sparkle animation
  require("undo-glow.animation").animate_start(opts, function(progress)
    -- Sparkle effect: rapid random color changes
    local sparkle = math.random()
    local intensity = math.sin(progress * math.pi * 8) * sparkle
    return {
      bg = string.format("#%02X%02X%02X",
        math.floor(255 * intensity),
        math.floor(200 * (1 - intensity)),
        math.floor(255 * sparkle)
      )
    }
  end)
end)

-- Use it in hooks
api.register_hook("pre_animation", function(data)
  if data.operation == "yank" then
    data.animation_type = "sparkle"
  end
end)
```

## ⚡ Runtime Configuration Changes

Modify plugin behavior dynamically using the config builder:

```lua
local api = require("undo-glow.api")

-- Change animation settings at runtime
api.config_builder()
  :animation({
    enabled = true,
    duration = 800,
    animation_type = "bounce",
    easing = "out_elastic"
  })
  :performance({
    color_cache_size = 1500,
    debounce_delay = 75
  })
  :build()

-- Context-aware theming
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    if vim.o.background == "dark" then
      api.config_builder()
        :animation({ duration = 600 })
        :build()
    else
      api.config_builder()
        :animation({ duration = 400 })
        :build()
    end
  end
})
```

## 🎵 Sound Effects Integration

Add audio feedback for operations:

```lua
local api = require("undo-glow.api")

api.register_hook("post_highlight", function(data)
  if data.operation == "undo" then
    vim.fn.system("afplay /System/Library/Sounds/Blow.aiff &")
  elseif data.operation == "redo" then
    vim.fn.system("afplay /System/Library/Sounds/Glass.aiff &")
  elseif vim.startswith(data.operation, "search") then
    vim.fn.system("afplay /System/Library/Sounds/Pop.aiff &")
  end
end)
```

## 📊 Usage Analytics

Track how users interact with your editor:

```lua
local api = require("undo-glow.api")
local stats = { operations = {}, total = 0 }

api.register_hook("post_highlight", function(data)
  stats.total = stats.total + 1
  stats.operations[data.operation] = (stats.operations[data.operation] or 0) + 1

  -- Log to file every 100 operations
  if stats.total % 100 == 0 then
    local log_file = io.open("/tmp/undo-glow-stats.json", "w")
    if log_file then
      log_file:write(vim.json.encode(stats))
      log_file:close()
    end
  end
end)

-- Get current stats
function get_undo_glow_stats()
  return vim.deepcopy(stats)
end
```

## 🔗 Third-Party Plugin Integration

Create seamless integrations with other plugins:

```lua
local api = require("undo-glow.api")

-- Enhanced gitsigns integration
api.register_hook("post_highlight", function(data)
  if data.operation == "undo" and package.loaded.gitsigns then
    -- Refresh gitsigns after undo operations
    require("gitsigns").refresh()

    -- Highlight git hunks that were affected
    vim.defer_fn(function()
      vim.cmd("Gitsigns preview_hunk")
    end, 100)
  end
end)

-- Telescope integration
api.register_hook("pre_animation", function(data)
  if data.operation == "search_cmd" and package.loaded.telescope then
    -- Use telescope's previewer colors for search highlighting
    data.hl_color = { bg = "#2D3343", fg = "#E5E9F0" }
  end
end)
```

## Highlight on `<C-R>` in Insert Mode

This snippet does not work with `which-key.nvim`, no idea how to make it work together. PR is welcome.

```lua
vim.keymap.set({ "i", "c" }, "<C-r>", function()
 ---@type UndoGlow.CommandOpts
 local opts = {}

 local opts = require("undo-glow.utils").merge_command_opts("UgPaste", opts)
 require("undo-glow").highlight_changes(opts)

 return "<C-r>"
end, { expr = true, desc = "Register paste with highlighting flag" })
```

## Highlight on jumping to a mark

This snippet does not work with `which-key.nvim`, no idea how to make it work together. PR is welcome.

> [!note]
> This snippet uses key backtick as example, you can also do keys like `', g`, g', etc`, it should work just fine.

```lua
vim.keymap.set("n", "`", function()
 ---@type UndoGlow.CommandOpts
 local opts = {
  animation = {
   animation_type = "slide",
  },
 }

 opts = require("undo-glow.utils").merge_command_opts("UgCursor", opts)

 vim.schedule(function()
  local pos = require("undo-glow.utils").get_current_cursor_row()
  require("undo-glow").highlight_region(vim.tbl_extend("force", opts, {
   s_row = pos.s_row,
   s_col = pos.s_col,
   e_row = pos.e_row,
   e_col = pos.e_col,
   force_edge = opts.force_edge == nil and true or opts.force_edge,
  }))
 end)

 return "`"
end, { expr = true, desc = "Jump to mark with highlighting" })
```

## Cursor Moved Highlights for outside of Neovim Switching E.g. Tmux

```lua
vim.api.nvim_create_autocmd("FocusGained", {
 group = augroup("ug_highlight_focus_gained"),
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
```
