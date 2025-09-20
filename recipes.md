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

Remember to disable highlights from `yanky.nvim`

```lua
-- yanky.nvim config
{
 highlight = {
  on_put = false,
  on_yank = false,
 },
}
```

### Put text after cursor

```lua
vim.keymap.set("n", "p", function()
 local opts = require("undo-glow.utils").merge_command_opts("UgPaste")
 require("undo-glow").highlight_changes(opts)
 return "<Plug>(YankyPutAfter)"
end, { desc = "Paste below with highlight", noremap = true, expr = true })
```

### Put text before cursor

```lua
vim.keymap.set("n", "p", function()
 local opts = require("undo-glow.utils").merge_command_opts("UgPaste")
 require("undo-glow").highlight_changes(opts)
 return "<Plug>(YankyPutBefore)"
end, { desc = "Paste below with highlight", noremap = true, expr = true })
```

## With Substitute.nvim

Remember to disable highlights from `substitute.nvim`

```lua
-- substitute.nvim config
{
 highlight_substituted_text = {
   enabled = false,
 },
}
```

### Substitute line

The rest of the commands should be almost the identical.

```lua
vim.keymap.set("n", "ss", function()
 local opts = require("undo-glow.utils").merge_command_opts("UgPaste", {}) -- Set this to whatever hlgroup you like
 require("undo-glow").highlight_changes(opts)

 require("substitute").line()
end, { noremap = true })
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
