---@alias UndoGlow.AnimationTypeString "fade" | "blink" | "pulse" | "jitter"
---@alias UndoGlow.AnimationTypeFn fun(opts: UndoGlow.Animation)
---@alias UndoGlow.EasingString "linear" | "in_quad" | "out_quad" | "in_out_quad" | "out_in_quad" | "in_cubic" | "out_cubic" | "in_out_cubic" | "out_in_cubic" | "in_quart" | "out_quart" | "in_out_quart" | "out_in_quart" | "in_quint" | "out_quint" | "in_out_quint" | "out_in_quint" | "in_sine" | "out_sine" | "in_out_sine" | "out_in_sine" | "in_expo" | "out_expo" | "in_out_expo" | "out_in_expo" | "in_circ" | "out_circ" | "in_out_circ" | "out_in_circ" | "in_elastic" | "out_elastic" | "in_out_elastic" | "out_in_elastic" | "in_back" | "out_back" | "in_out_back" | "out_in_back" | "in_bounce" | "out_bounce" | "in_out_bounce" | "out_in_bounce"
---@alias UndoGlow.EasingFn fun(opts: UndoGlow.EasingOpts): integer

---@class UndoGlow.Config
---@field animation? UndoGlow.Config.Animation
---@field highlights? table<"undo" | "redo" | "yank" | "paste" | "search" | "comment", { hl: string, hl_color: UndoGlow.HlColor }>

---@class UndoGlow.EasingOpts
---@field time integer Elapsed time
---@field begin? integer Begin
---@field change? integer Change == ending - beginning
---@field duration? integer Duration (total time)
---@field amplitude? integer Amplitude
---@field period? integer Period
---@field overshoot? integer Overshoot

---@class UndoGlow.Config.Animation
---@field enabled? boolean Turn on or off for animation
---@field duration? number Highlight duration in ms
---@field animation_type? UndoGlow.AnimationTypeString | UndoGlow.AnimationTypeFn A animation_type string or function that does the animation
---@field easing? UndoGlow.EasingString | UndoGlow.EasingFn A easing string or function that computes easing.
---@field fps? number Normally either 60 / 120, up to you

---@class UndoGlow.HlColor
---@field bg string
---@field fg? string

---@class UndoGlow.State
---@field current_hlgroup string
---@field should_detach boolean
---@field animation? UndoGlow.Config.Animation
---@field force_edge? boolean

---@class UndoGlow.RGBColor
---@field r integer Red (0-255)
---@field g integer Green (0-255)
---@field b integer Blue (0-255)

---@class UndoGlow.CommandOpts
---@field hlgroup? string
---@field animation? UndoGlow.Config.Animation
---@field force_edge? boolean

---@class UndoGlow.HighlightChanges : UndoGlow.CommandOpts

---@class UndoGlow.HighlightRegion : UndoGlow.CommandOpts,UndoGlow.RowCol

---@class UndoGlow.Animation
---@field bufnr integer Buffer number
---@field hlgroup string
---@field extmark_id integer
---@field start_bg UndoGlow.RGBColor
---@field end_bg UndoGlow.RGBColor
---@field start_fg? UndoGlow.RGBColor
---@field end_fg? UndoGlow.RGBColor
---@field duration integer
---@field config UndoGlow.Config
---@field state UndoGlow.State

---@class UndoGlow.HandleHighlight : UndoGlow.RowCol
---@field bufnr integer Buffer number
---@field config UndoGlow.Config
---@field state UndoGlow.State State

---@class UndoGlow.RowCol
---@field s_row integer Start row
---@field s_col integer Start column
---@field e_row integer End row
---@field e_col integer End column
