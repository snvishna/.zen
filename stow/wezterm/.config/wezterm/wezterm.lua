local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local action = wezterm.action

-- =========================================================
-- 1. VISUALS (Zen Glass Theme)
-- =========================================================
config.color_scheme = 'Catppuccin Mocha'
config.default_cwd = wezterm.home_dir

config.font = wezterm.font_with_fallback {
  'JetBrains Mono',
  'Apple Color Emoji',
}
config.font_size = 16.0
config.line_height = 1.05 -- Optimized for readability

config.colors = {
  background = '#1A1A1A'
}

-- FRAMELESS UI: Removes the native Mac title bar (iTerm style)
config.window_decorations = "RESIZE" 
config.window_padding = { left = 12, right = 12, top = 12, bottom = 12 }

-- Transparency & Blur
config.window_background_opacity = 0.90 
config.macos_window_background_blur = 30
config.text_background_opacity = 1.0

-- Dim inactive panes (Spotlight Mode)
config.inactive_pane_hsb = { saturation = 0.6, brightness = 0.4 }

-- =========================================================
-- 2. TABS & STATUS BAR
-- =========================================================
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = false

wezterm.on('update-right-status', function(window, pane)
  local name = window:active_workspace()
  if name == 'default' then name = 'Zen' end
  window:set_right_status(wezterm.format({
    { Attribute = { Intensity = 'Bold' } },
    { Foreground = { Color = '#fab387' } },
    { Text = '  ' .. name .. '  ' },
  }))
end)

-- =========================================================
-- 3. PERFORMANCE & BEHAVIOR
-- =========================================================
config.front_end = "WebGpu"
config.scrollback_lines = 100000
config.default_cursor_style = 'BlinkingBar'
config.animation_fps = 120 -- Fixed: Removed duplicate "1"
config.cursor_blink_rate = 500

-- Allow standard Mac keys (Option -> Alt)
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- =========================================================
-- 4. POWER USER FEATURES
-- =========================================================
config.enable_scroll_bar = false
config.quick_select_alphabet = "arstqwfpzxcvneioluymdhgjbk" -- Restored

-- Hyperlinks (Restored Custom Regex)
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = '[a-zA-Z0-9_.-]+@[a-zA-Z0-9_.-]+\\.[a-zA-Z0-9_.-]+',
  format = 'mailto:$0',
})

config.mouse_bindings = {
  { event = { Down = { streak = 1, button = 'Right' } }, mods = 'NONE', action = action.PasteFrom 'Clipboard' },
  { event = { Up = { streak = 1, button = 'Left' } }, mods = 'CMD', action = action.OpenLinkAtMouseCursor },
}

-- =========================================================
-- 5. KEYBINDINGS (iTerm + Power User)
-- =========================================================
config.keys = {
  -- --- ZSH HANDSHAKE (Crucial for FZF) ---
  -- Cmd+T: Sends Esc+t -> Triggers FZF File Search in Zsh
  { key = 't', mods = 'CMD', action = action.SendString '\x1bt' },

  -- --- CLIPBOARD ---
  -- Cmd+C: Sends Esc+c -> Triggers Smart Copy in Zsh
  { key = 'c', mods = 'CMD', action = action.CopyTo 'Clipboard' },
  -- Cmd+X: Sends Esc+x -> Triggers Smart Cut in Zsh
  { key = 'x', mods = 'CMD', action = action.CopyTo 'Clipboard' },
  -- Cmd+V: Smart Paste
  { key = 'v', mods = 'CMD', action = action.PasteFrom 'Clipboard' },

  -- --- SPLITS (iTerm Style) ---
  { key = 'd', mods = 'CMD', action = action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = 'CMD', action = action.CloseCurrentPane { confirm = true } },

  -- --- NAVIGATION ---
  -- Cmd+Option+Arrows: Switch Tabs
  { key = 'LeftArrow', mods = 'CMD|OPT', action = action.ActivateTabRelative(-1) },
  { key = 'RightArrow', mods = 'CMD|OPT', action = action.ActivateTabRelative(1) },
  
  -- Cmd+Arrows: Pane Navigation
  { key = 'UpArrow',    mods = 'CMD', action = action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'CMD', action = action.ActivatePaneDirection 'Down' },
  
  -- --- EDITOR TEXT NAV (Hex Codes for Zsh) ---
  -- Cmd+Left/Right: Start/End of Line
  { key = 'LeftArrow', mods = 'CMD', action = action.SendString '\x01' },
  { key = 'RightArrow', mods = 'CMD', action = action.SendString '\x05' },
  -- Option+Left/Right: Jump Word
  { key = 'LeftArrow', mods = 'OPT', action = action.SendString '\x1bb' },
  { key = 'RightArrow', mods = 'OPT', action = action.SendString '\x1bf' },
  
  -- --- EDITOR EXPERIENCE ---
  -- Cmd+Backspace: Delete Line
  { key = 'Backspace', mods = 'CMD', action = action.SendString '\x15' },
  -- Cmd+Z: Undo / Cmd+Shift+Z: Redo
  { key = 'z', mods = 'CMD', action = action.SendString '\x1f' },
  { key = 'z', mods = 'CMD|SHIFT', action = action.SendString '\x19' },

  -- Shift+Arrows: Select Text (Sends xterm codes for Zsh visual mode)
  { key = 'LeftArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2D' },
  { key = 'RightArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2C' },
  { key = 'UpArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2A' },
  { key = 'DownArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2B' },

  -- Cmd+Shift+Arrows: Select Line Start/End
  { key = 'LeftArrow', mods = 'CMD|SHIFT', action = action.SendString '\x1b[1;9D' },
  { key = 'RightArrow', mods = 'CMD|SHIFT', action = action.SendString '\x1b[1;9C' },

  -- --- UTILITIES ---
  { key = 'n', mods = 'CMD', action = action.SpawnTab 'CurrentPaneDomain' },
  { key = 'f', mods = 'CMD', action = action.Search 'CurrentSelectionOrEmptyString' },
  { key = 'p', mods = 'CMD|SHIFT', action = action.ActivateCommandPalette },
  { key = 'k', mods = 'CMD', action = action.ClearScrollback 'ScrollbackOnly' },
  { key = '=', mods = 'CMD', action = action.IncreaseFontSize },
  { key = '-', mods = 'CMD', action = action.DecreaseFontSize },
  { key = '0', mods = 'CMD', action = action.ResetFontSize },

  -- --- COPY MODE ---
  { key = 'Space', mods = 'CMD|SHIFT', action = action.ActivateCopyMode },
}

-- =========================================================
-- 6. KEY TABLES (Restored Full Logic)
-- =========================================================
config.key_tables = {
  copy_mode = {
    { key = 'c', mods = 'CMD', action = action.CopyMode 'Close' },
    { key = 'Escape', mods = 'NONE', action = action.CopyMode 'Close' },
    { key = 'q', mods = 'NONE', action = action.CopyMode 'Close' },

    -- MOVEMENT
    { key = 'h', mods = 'NONE', action = action.CopyMode 'MoveLeft' },
    { key = 'j', mods = 'NONE', action = action.CopyMode 'MoveDown' },
    { key = 'k', mods = 'NONE', action = action.CopyMode 'MoveUp' },
    { key = 'l', mods = 'NONE', action = action.CopyMode 'MoveRight' },
    { key = 'LeftArrow', mods = 'NONE', action = action.CopyMode 'MoveLeft' },
    { key = 'RightArrow', mods = 'NONE', action = action.CopyMode 'MoveRight' },
    { key = 'UpArrow', mods = 'NONE', action = action.CopyMode 'MoveUp' },
    { key = 'DownArrow', mods = 'NONE', action = action.CopyMode 'MoveDown' },

    -- SELECTION
    { key = 'v', mods = 'NONE', action = action.CopyMode{ SetSelectionMode =  'Cell' } },
    { key = 'V', mods = 'SHIFT', action = action.CopyMode{ SetSelectionMode = 'Line' } },
    
    -- WORD JUMP
    { key = 'LeftArrow', mods = 'SHIFT', action = action.CopyMode 'MoveBackwardWord' },
    { key = 'RightArrow', mods = 'SHIFT', action = action.CopyMode 'MoveForwardWord' },
    
    -- ACTION
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

-- =========================================================
-- 7. PRIVATE OVERRIDES (Restored)
-- =========================================================
local function merge_tables(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == 'table' then
            if type(t1[k] or false) == 'table' then
                merge_tables(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

local success, private_config = pcall(require, 'wezterm-local')
if success then
   config = merge_tables(config, private_config)
end

return config
