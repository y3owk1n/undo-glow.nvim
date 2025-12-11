---@mod undo-glow.nvim.types Types

local M = {}

---Animation type aliases.
---@alias UndoGlow.AnimationTypeString
---| '"fade"'
---| '"fade_reverse"'
---| '"blink"'
---| '"pulse"'
---| '"jitter"'
---| '"spring"'
---| '"desaturate"'
---| '"strobe"'
---| '"zoom"'
---| '"rainbow"'
---| '"slide"'
---@alias UndoGlow.AnimationTypeFn fun(opts: UndoGlow.Animation)

---Easing function aliases.
---@alias UndoGlow.EasingString
---| '"linear"'
---| '"in_quad"'
---| '"out_quad"'
---| '"in_out_quad"'
---| '"out_in_quad"'
---| '"in_cubic"'
---| '"out_cubic"'
---| '"in_out_cubic"'
---| '"out_in_cubic"'
---| '"in_quart"'
---| '"out_quart"'
---| '"in_out_quart"'
---| '"out_in_quart"'
---| '"in_quint"'
---| '"out_quint"'
---| '"in_out_quint"'
---| '"out_in_quint"'
---| '"in_sine"'
---| '"out_sine"'
---| '"in_out_sine"'
---| '"out_in_sine"'
---| '"in_expo"'
---| '"out_expo"'
---| '"in_out_expo"'
---| '"out_in_expo"'
---| '"in_circ"'
---| '"out_circ"'
---| '"in_out_circ"'
---| '"out_in_circ"'
---| '"in_elastic"'
---| '"out_elastic"'
---| '"in_out_elastic"'
---| '"out_in_elastic"'
---| '"in_back"'
---| '"out_back"'
---| '"in_out_back"'
---| '"out_in_back"'
---| '"in_bounce"'
---| '"out_bounce"'
---| '"in_out_bounce"'
---| '"out_in_bounce"'
---@alias UndoGlow.EasingFn fun(opts: UndoGlow.EasingOpts): number

---Configuration options for undo-glow.
---@class UndoGlow.Config
---@field animation? UndoGlow.Config.Animation Configuration for animations.
---@field highlights? table<"undo" | "redo" | "yank" | "paste" | "search" | "comment" | "cursor", { hl: string, hl_color: UndoGlow.HlColor }> Highlight configurations for various actions.
---@field priority? integer Extmark priority to render the highlight (Default 4096)
---@field fallback_for_transparency? UndoGlow.Config.FallbackForTransparency Fallback color for when the highlight is transparent.
---@field performance? UndoGlow.Config.Performance Performance-related configuration.
---@field logging? UndoGlow.Config.Logging Logging configuration.

---Fallback color for when the highlight is transparent.
---@class UndoGlow.Config.FallbackForTransparency
---@field bg? string Background color as a hex string.
---@field fg? string Optional foreground color as a hex string.

---Options passed to easing functions.
---@class UndoGlow.EasingOpts
---@field time number Elapsed time (e.g. a progress value between 0 and 1).
---@field begin? number Optional start value.
---@field change? number Optional change value (ending minus beginning).
---@field duration? number Optional total duration.
---@field amplitude? number Optional amplitude (for elastic easing).
---@field period? number Optional period (for elastic easing).
---@field overshoot? number Optional overshoot (for back easing).

---Animation configuration.
---@class UndoGlow.Config.Animation
---@field enabled? boolean Whether animation is enabled.
---@field duration? number Duration of the highlight animation in milliseconds.
---@field animation_type? UndoGlow.AnimationTypeString|UndoGlow.AnimationTypeFn Animation type (a string key or a custom function).
---@field easing? UndoGlow.EasingString|UndoGlow.EasingFn Easing function (a string key or a custom function).
---@field fps? number Frames per second for the animation.
---@field window_scoped? boolean If enabled, the highlight effect is constrained to the current active window, even if the buffer is shared across splits.

---Performance-related configuration.
---@class UndoGlow.Config.Performance
---@field color_cache_size? integer Maximum cached color conversions.
---@field debounce_delay? integer Milliseconds to debounce rapid operations.
---@field animation_skip_unchanged? boolean Skip redraws when highlights haven't changed.

---Logging configuration.
---@class UndoGlow.Config.Logging
---@field level? string Log level: "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "OFF".
---@field notify? boolean Show logs in Neovim notifications.
---@field file? boolean Write logs to file.
---@field file_path? string Custom log file path.

---Neovim highlight info from nvim_get_hl.
---@class vim.api.keyset.hl_info
---@field bg? integer Background color.
---@field fg? integer Foreground color.

---Neovim extmark options for nvim_buf_set_extmark.
---@class vim.api.keyset.set_extmark
---@field virt_text? table Virtual text to display.
---@field virt_text_win_col? integer Column position for virtual text.

---Highlight color information.
---@class UndoGlow.HlColor
---@field bg string Background color as a hex string.
---@field fg? string Optional foreground color as a hex string.

---State for the undo-glow highlight.
---@class UndoGlow.State
---@field current_hlgroup string The current highlight group in use.
---@field should_detach boolean Whether the highlight should detach.
---@field animation? UndoGlow.Config.Animation Animation configuration.
---@field force_edge? boolean Whether to force edge highlighting.
---@field _operation? string Internal operation type.

---RGB color representation.
---@class UndoGlow.RGBColor
---@field r integer Red (0-255)
---@field g integer Green (0-255)
---@field b integer Blue (0-255)

---HSL color representation.
---@class UndoGlow.HSLColor
---@field h integer Hue component in degrees (0-360)
---@field s integer Saturation component as a percentage (0-100)
---@field l integer Lightness component as a percentage (0-100)

---Command options for triggering highlights.
---@class UndoGlow.CommandOpts
---@field hlgroup? string Optional highlight group to use.
---@field animation? UndoGlow.Config.Animation Optional animation configuration.
---@field force_edge? boolean Optional flag to force edge highlighting.
---@field _operation? string Internal operation type.

---Options for highlight changes API.
---@class UndoGlow.HighlightChanges : UndoGlow.CommandOpts

---Options for highlight region API.
---@class UndoGlow.HighlightRegion : UndoGlow.CommandOpts,UndoGlow.RowCol
---@field _start_time? number Internal start time.

---Parameters for an animation.
---@class UndoGlow.Animation
---@field bufnr integer Buffer number.
---@field ns integer Namespace id.
---@field hlgroup string Highlight group name.
---@field extmark_ids? integer[] | nil Extmark identifiers.
---@field start_bg UndoGlow.RGBColor Starting background color.
---@field end_bg UndoGlow.RGBColor Ending background color.
---@field start_fg? UndoGlow.RGBColor Optional starting foreground color.
---@field end_fg? UndoGlow.RGBColor Optional ending foreground color.
---@field duration number Animation duration in milliseconds.
---@field config UndoGlow.Config Configuration for undo-glow.
---@field state UndoGlow.State Current state of the highlight.
---@field coordinates UndoGlow.RowCol Current sanitized coordinates

---Handle for highlighting operations, including region coordinates.
---@class UndoGlow.HandleHighlight : UndoGlow.RowCol
---@field bufnr integer Buffer number.
---@field ns? integer Namespace id.
---@field state UndoGlow.State Current state of the highlight.

---Represents a region (row/column coordinates) in the buffer.
---@class UndoGlow.RowCol
---@field s_row integer Start row.
---@field s_col integer Start column.
---@field e_row integer End row.
---@field e_col integer End column.

---Opts to create an extmark
---@class UndoGlow.ExtmarkOpts : UndoGlow.RowCol
---@field bufnr integer Buffer number.
---@field hlgroup string Highlight group name.
---@field priority integer Extmark priority to render the highlight (Default 4096).
---@field force_edge? boolean Whether to force edge highlighting.
---@field window_scoped? boolean If enabled, the highlight effect is constrained to the current active window, even if the buffer is shared across splits.

---Opts for cursor moved command
---@class UndoGlow.CursorMovedOpts
---@field ignored_ft? table<string> Optional filetypes to ignore
---@field steps_to_trigger? number Optional number of steps to trigger
---@field trigger_on_new_buffer? boolean Optional trigger on new buffer
---@field trigger_on_new_window? boolean Optional trigger on new window

return M
