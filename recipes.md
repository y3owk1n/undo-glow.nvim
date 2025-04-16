# Recipes

> [!note]
> If you have more recipes, feel free to send a PR to add them here.

## With Flash.nvim

```lua
function()
 vim.g.ug_ignore_cursor_moved = true
 require("flash").jump()

 vim.defer_fn(function()
  local region = require("undo-glow.utils").get_current_cursor_row()

  local undo_glow_opts = require("undo-glow.utils").merge_command_opts("UgSearch", {
   force_edge = true,
  })

  require("undo-glow").highlight_region(vim.tbl_extend("force", undo_glow_opts, region))
 end, 5)
end,
```

## With Yanky.nvim

### Put text after cursor

```lua
function()
 local opts = require("undo-glow.utils").merge_command_opts("UgPaste")
 require("undo-glow").highlight_changes(opts)
 return "<Plug>(YankyPutAfter)"
end,
```

### Put text before cursor

```lua
function()
 local opts = require("undo-glow.utils").merge_command_opts("UgPaste")
 require("undo-glow").highlight_changes(opts)
 return "<Plug>(YankyPutBefore)"
end,
```

## Cursor Moved Highlights for out side of Neovim Switching E.g. Tmux

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
