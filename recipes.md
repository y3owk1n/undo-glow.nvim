# Recipes

> [!note]
> If you have more recipes, feel free to send a PR to add them here.

## Highlight on `<C-R>` in Insert Mode

This snippet does not work with `which-key.nvim`, no idea how to make it work together. PR is welcome.

```lua
vim.keymap.set({ "i", "c" }, "<C-r>", function()
 local opts = require("undo-glow.utils").merge_command_opts("UgPaste", {})
 require("undo-glow").highlight_changes(opts)

 return "<C-r>"
end, { expr = true, desc = "Register paste with highlighting flag" })
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
