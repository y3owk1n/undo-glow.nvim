---Animation type aliases.
---@alias UndoGlow.AnimationTypeString "fade" | "blink" | "pulse" | "jitter" | "spring"
---@alias UndoGlow.AnimationTypeFn fun(opts: UndoGlow.Animation)

---Easing function aliases.
---@alias UndoGlow.EasingString "linear" | "in_quad" | "out_quad" | "in_out_quad" | "out_in_quad" | "in_cubic" | "out_cubic" | "in_out_cubic" | "out_in_cubic" | "in_quart" | "out_quart" | "in_out_quart" | "out_in_quart" | "in_quint" | "out_quint" | "in_out_quint" | "out_in_quint" | "in_sine" | "out_sine" | "in_out_sine" | "out_in_sine" | "in_expo" | "out_expo" | "in_out_expo" | "out_in_expo" | "in_circ" | "out_circ" | "in_out_circ" | "out_in_circ" | "in_elastic" | "out_elastic" | "in_out_elastic" | "out_in_elastic" | "in_back" | "out_back" | "in_out_back" | "out_in_back" | "in_bounce" | "out_bounce" | "in_out_bounce" | "out_in_bounce"
---@alias UndoGlow.EasingFn fun(opts: UndoGlow.EasingOpts): integer

---Configuration options for undo-glow.
---@class UndoGlow.Config
---@field animation? UndoGlow.Config.Animation Configuration for animations.
---@field highlights? table<"undo" | "redo" | "yank" | "paste" | "search" | "comment" | "cursor", { hl: string, hl_color: UndoGlow.HlColor }> Highlight configurations for various actions.

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

---Options for highlight changes API.
---@class UndoGlow.HighlightChanges : UndoGlow.CommandOpts

---Options for highlight region API.
---@class UndoGlow.HighlightRegion : UndoGlow.CommandOpts,UndoGlow.RowCol

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

---Handle for highlighting operations, including region coordinates.
---@class UndoGlow.HandleHighlight : UndoGlow.RowCol
---@field bufnr integer Buffer number.
---@field config UndoGlow.Config Configuration for undo-glow.
---@field state UndoGlow.State Current state of the highlight.

---Represents a region (row/column coordinates) in the buffer.
---@class UndoGlow.RowCol
---@field s_row integer Start row.
---@field s_col integer Start column.
---@field e_row integer End row.
---@field e_col integer End column.
