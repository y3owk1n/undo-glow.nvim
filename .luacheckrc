std = "lua51+vim"
globals = {
  "vim",
  "_G",
  "describe",
  "it",
  "before_each",
  "after_each",
}
ignore = {
  "211", -- unused variable
  "212", -- unused argument
}
max_line_length = 120
max_cyclomatic_complexity = 20
files = {
  "lua/**/*.lua",
  "tests/**/*.lua",
}
exclude_files = {
  "lua/undo-glow/types.lua",
}