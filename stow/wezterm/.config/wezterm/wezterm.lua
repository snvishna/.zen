local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local action = wezterm.action

-- =========================================================
-- 1. APPEARANCE & AESTHETICS (Zen Mode)
-- =========================================================
config.color_scheme = 'Catppuccin Mocha'
-- Override the text color to Neon Green
config.colors = {
  foreground = '#a6e3a1', -- Catppuccin Green (Softer, fits the theme better)
  split = "#89b4fa",
}
config.font = wezterm.font_with_fallback {
  'AnonymicePro Nerd Font', -- Or 'Anonymice Pro'
  'JetBrainsMono Nerd Font',      -- Or 'JetBrains Mono'
  'Apple Color Emoji',   -- Good for standard emojis
}
config.font_size = 16.0 -- Bumped slightly for readability
config.line_height = 1.0 -- Gave it some breathing room (was 0.95)

-- Window Layout
config.window_decorations = "TITLE|RESIZE"
config.window_padding = {
  left = 16,
  right = 16,
  top = 12,
  bottom = 12,
}

-- Transparency & Blur
config.window_background_opacity = 0.7 -- Slightly less transparent for contrast
config.macos_window_background_blur = 10
config.text_background_opacity = 1.0

-- Dim inactive panes (Spotlight Mode)
config.inactive_pane_hsb = {
  saturation = 0.5,
  brightness = 0.4, 
}

-- =========================================================
-- 2. TABS & STATUS BAR
-- =========================================================
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(wezterm.format({
    { Attribute = { Intensity = 'Bold' } },
    { Text = window:active_workspace() .. '  ' },
  }))
end)

-- =========================================================
-- 3. PERFORMANCE & BEHAVIOR
-- =========================================================
config.front_end = "WebGpu"
config.scrollback_lines = 100000
config.default_cursor_style = 'BlinkingBar' -- Or BlinkingBlock
config.animation_fps = 1
config.animation_fps = 120
config.cursor_blink_rate = 500
-- Allow standard Mac keys (Option -> Alt)
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- =========================================================
-- 4. POWER USER FEATURES
-- =========================================================
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = '[a-zA-Z0-9_.-]+@[a-zA-Z0-9_.-]+\\.[a-zA-Z0-9_.-]+',
  format = 'mailto:$0',
})

config.enable_scroll_bar = false
config.quick_select_alphabet = "arstqwfpzxcvneioluymdhgjbk"

config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = action.PasteFrom 'Clipboard',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = action.OpenLinkAtMouseCursor,
  },
}

-- =========================================================
-- 5. KEYBINDINGS (The "Editor" Feel)
-- =========================================================
config.keys = {
  -- --- CLIPBOARD (Smart Integration) ---
  -- --- CLIPBOARD (Smart Integration) ---
  -- Cmd+C = Send \x1bc (Esc+c) -> Zsh captures this to copy selection
  { key = 'c', mods = 'CMD', action = action.SendString '\x1bc' },
  -- Cmd+X = Send \x1bx (Esc+x) -> Zsh captures this to cut selection
  { key = 'x', mods = 'CMD', action = action.SendString '\x1bx' },
  -- Cmd+V = Send \x1bv (Esc+v) -> Zsh captures this to Smart Paste
  { key = 'v', mods = 'CMD', action = action.SendString '\x1bv' },
  -- Cmd+Shift+V = Force Native Paste (for Vim/Nano/Remote)
  { key = 'v', mods = 'CMD|SHIFT', action = action.PasteFrom 'Clipboard' },
  -- Cmd+Shift+C = Force Native Copy (for mouse selections/non-Zsh apps)
  { key = 'c', mods = 'CMD|SHIFT', action = action.CopyTo 'Clipboard' },
  
  -- --- SEARCH ---
  { key = 'f', mods = 'CMD', action = action.Search 'CurrentSelectionOrEmptyString' },

  -- --- COPY MODE (The "Select Text" fix) ---
  -- 1. Enter Copy Mode
  { key = 'Space', mods = 'CMD|SHIFT', action = action.ActivateCopyMode },
  
  -- --- FONT SIZING (Zoom) ---
  { key = '=', mods = 'CMD', action = action.IncreaseFontSize },
  { key = '-', mods = 'CMD', action = action.DecreaseFontSize },
  { key = '0', mods = 'CMD', action = action.ResetFontSize },

  -- --- PANE MANAGEMENT ---
  { key = 'd', mods = 'CMD', action = action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = 'CMD', action = action.CloseCurrentPane { confirm = true } },
  
  -- NAVIGATE PANES: CMD + Arrow (Standard Editor Style)
  { key = 'LeftArrow',  mods = 'CMD', action = action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CMD', action = action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'CMD', action = action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'CMD', action = action.ActivatePaneDirection 'Down' },

  -- RESIZE PANES: CTRL + SHIFT + Arrow
  { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = action.AdjustPaneSize { 'Left', 5 } },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = action.AdjustPaneSize { 'Right', 5 } },
  { key = 'UpArrow', mods = 'CTRL|SHIFT', action = action.AdjustPaneSize { 'Up', 5 } },
  { key = 'DownArrow', mods = 'CTRL|SHIFT', action = action.AdjustPaneSize { 'Down', 5 } },

  -- --- TABS ---
  { key = 't', mods = 'CMD', action = action.SpawnTab 'CurrentPaneDomain' },
  { key = '[', mods = 'CMD|SHIFT', action = action.ActivateTabRelative(-1) },
  { key = ']', mods = 'CMD|SHIFT', action = action.ActivateTabRelative(1) },
  { key = '1', mods = 'CMD', action = action.ActivateTab(0) },
  { key = '2', mods = 'CMD', action = action.ActivateTab(1) },
  { key = '3', mods = 'CMD', action = action.ActivateTab(2) },

  -- --- UTILITIES ---
  { key = 'p', mods = 'CMD', action = action.ActivateCommandPalette },
  { key = 'L', mods = 'CTRL|SHIFT', action = action.ShowDebugOverlay },
  { key = 'k', mods = 'CMD', action = action.ClearScrollback 'ScrollbackOnly' },
  
  -- --- TEXT NAV (Sending Codes to Zsh) ---
  -- Option+Left/Right = Jump Word (sends Alt-b / Alt-f)
  { key = 'LeftArrow', mods = 'OPT', action = action.SendKey { key = 'b', mods = 'ALT' } },
  { key = 'RightArrow', mods = 'OPT', action = action.SendKey { key = 'f', mods = 'ALT' } },
  -- Cmd+Backspace = Delete Line (sends Ctrl-U)
  { key = 'Backspace', mods = 'CMD', action = action.SendString '\x15' },
  
  -- --- EDITOR EXPERIENCE (Undo/Redo & Selection) ---
  -- Undo: Cmd+Z -> Ctrl+_ (\x1f)
  { key = 'z', mods = 'CMD', action = action.SendString '\x1f' },
  -- Redo: Cmd+Shift+Z -> Ctrl+Y (\x19) (We will map this in Zsh)
  { key = 'z', mods = 'CMD|SHIFT', action = action.SendString '\x19' },

  -- Text Selection (Shift+Arrow) -> Send standard xterm codes
  { key = 'LeftArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2D' },
  { key = 'RightArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2C' },
  { key = 'UpArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2A' },
  { key = 'DownArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2B' },
  
  -- Select Line Start/End (Cmd+Shift+Arrow) -> Send custom codes
  { key = 'LeftArrow', mods = 'CMD|SHIFT', action = action.SendString '\x1b[1;9D' },
  { key = 'RightArrow', mods = 'CMD|SHIFT', action = action.SendString '\x1b[1;9C' },

  -- Multi-line Entry (Shift+Enter) -> Send Esc+Enter
  { key = 'Enter', mods = 'SHIFT', action = action.SendString '\x1b\r' },

  -- Word Selection (Shift+Option+Arrow) -> Send custom codes
  { key = 'LeftArrow', mods = 'SHIFT|OPT', action = action.SendString '\x1b[1;10D' },
  { key = 'RightArrow', mods = 'SHIFT|OPT', action = action.SendString '\x1b[1;10C' },
}

-- =========================================================
-- 6. KEY TABLES (Advanced Selection Logic)
-- =========================================================
config.key_tables = {
  -- This table activates when you press CMD+SHIFT+SPACE
  copy_mode = {
    -- Exit
    { key = 'c', mods = 'CMD', action = action.CopyMode 'Close' },
    { key = 'Escape', mods = 'NONE', action = action.CopyMode 'Close' },
    { key = 'q', mods = 'NONE', action = action.CopyMode 'Close' },

    -- MOVEMENT (Vim Style + Arrow Keys)
    { key = 'h', mods = 'NONE', action = action.CopyMode 'MoveLeft' },
    { key = 'j', mods = 'NONE', action = action.CopyMode 'MoveDown' },
    { key = 'k', mods = 'NONE', action = action.CopyMode 'MoveUp' },
    { key = 'l', mods = 'NONE', action = action.CopyMode 'MoveRight' },
    { key = 'LeftArrow', mods = 'NONE', action = action.CopyMode 'MoveLeft' },
    { key = 'RightArrow', mods = 'NONE', action = action.CopyMode 'MoveRight' },
    { key = 'UpArrow', mods = 'NONE', action = action.CopyMode 'MoveUp' },
    { key = 'DownArrow', mods = 'NONE', action = action.CopyMode 'MoveDown' },

    -- SELECTION BEHAVIOR
    -- 1. "v" to start character selection, "V" for line selection
    { key = 'v', mods = 'NONE', action = action.CopyMode{ SetSelectionMode =  'Cell' } },
    { key = 'V', mods = 'SHIFT', action = action.CopyMode{ SetSelectionMode = 'Line' } },
    
    -- 2. Shift + Arrows to Move Faster (By Word)
    -- FIXED: Passed as strings, not tables
    { key = 'LeftArrow', mods = 'SHIFT', action = action.CopyMode 'MoveBackwardWord' },
    { key = 'RightArrow', mods = 'SHIFT', action = action.CopyMode 'MoveForwardWord' },
    
    -- OPERATION
    { key = 'y', mods = 'NONE', action = action.Multiple{ { CopyTo =  'ClipboardAndPrimarySelection' }, { CopyMode =  'Close' } } },
    { key = 'c', mods = 'CMD', action = action.Multiple{ { CopyTo =  'ClipboardAndPrimarySelection' }, { CopyMode =  'Close' } } },
  },

  search_mode = {
    { key = 'Enter', mods = 'NONE', action = action.CopyMode 'NextMatch' },
    { key = 'Enter', mods = 'SHIFT', action = action.CopyMode 'PriorMatch' },
    { key = 'Escape', mods = 'NONE', action = action.CopyMode 'Close' },
    { key = 'n', mods = 'CTRL', action = action.CopyMode 'NextMatch' },
    { key = 'p', mods = 'CTRL', action = action.CopyMode 'PriorMatch' },
    { key = 'r', mods = 'CTRL', action = action.CopyMode 'CycleMatchType' },
    { key = 'Backspace', mods = 'NONE', action = action.CopyMode 'ClearPattern' },
  },
}

return config
