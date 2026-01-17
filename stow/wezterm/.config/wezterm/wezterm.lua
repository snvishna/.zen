local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local action = wezterm.action

-- =========================================================
-- 0. HELPERS
-- =========================================================
local function get_background_image()
  -- 1. Check for user override (background.png, .jpg, .jpeg)
  local possible_overrides = { 'background.png', 'background.jpg', 'background.jpeg', 'background.gif' }
  for _, filename in ipairs(possible_overrides) do
    local path = wezterm.config_dir .. '/' .. filename
    local f = io.open(path, 'r')
    if f then
      f:close()
      return path
    end
  end
  
  -- 2. Fallback to Zen Glass asset
  return wezterm.config_dir .. '/assets/zen-glass.png'
end

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
config.line_height = 1.05

config.background = {
  -- Layer 1: The Solid Background Color
  {
    source = { Color = '#1A1A1A' },
    width = '100%',
    height = '100%',
    opacity = 0.75,
  },
  -- Layer 2: The Image (Watermark)
  {
    source = { File = get_background_image() },
    vertical_align = 'Bottom',
    horizontal_align = 'Right',
    vertical_offset = -50,
    width = '15%',
    height = '20%',
    repeat_x = 'NoRepeat',
    repeat_y = 'NoRepeat',
    hsb = {
      brightness = 0.9,
      hue = 1.0,
      saturation = 0.5,
    },
    opacity = 0.25
  },
}

-- Frameless UI
config.window_decorations = "RESIZE"
config.window_padding = { left = 12, right = 12, top = 12, bottom = 12 }

-- Transparency & Blur
config.macos_window_background_blur = 30
config.text_background_opacity = 1.0
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
config.animation_fps = 120
config.cursor_blink_rate = 500

-- Allow standard Mac keys
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- =========================================================
-- 4. POWER USER FEATURES
-- =========================================================
config.enable_scroll_bar = false
config.quick_select_alphabet = "arstqwfpzxcvneioluymdhgjbk"

-- Hyperlinks
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
-- 5. KEYBINDINGS
-- =========================================================
config.keys = {
  -- --- ZSH INTELLIGENCE ---
  { key = 't', mods = 'CMD', action = action.SendString '\x1bt' },  -- FZF File
  { key = 'c', mods = 'CMD', action = action.CopyTo 'Clipboard' },
  { key = 'x', mods = 'CMD', action = action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CMD', action = action.PasteFrom 'Clipboard' },

  -- --- SPLITS ---
  { key = 'd', mods = 'CMD', action = action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = 'CMD', action = action.CloseCurrentPane { confirm = true } },

  -- --- NAVIGATION ---
  { key = 'LeftArrow', mods = 'CMD|OPT', action = action.ActivateTabRelative(-1) },
  { key = 'RightArrow', mods = 'CMD|OPT', action = action.ActivateTabRelative(1) },
  { key = 'UpArrow',    mods = 'CMD', action = action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'CMD', action = action.ActivatePaneDirection 'Down' },
  
  -- --- EDITOR NAV ---
  { key = 'LeftArrow', mods = 'CMD', action = action.SendString '\x01' },   -- Home
  { key = 'RightArrow', mods = 'CMD', action = action.SendString '\x05' },  -- End
  { key = 'LeftArrow', mods = 'OPT', action = action.SendString '\x1bb' },  -- Back Word
  { key = 'RightArrow', mods = 'OPT', action = action.SendString '\x1bf' }, -- Fwd Word
  { key = 'Backspace', mods = 'CMD', action = action.SendString '\x15' },   -- Del Line

  -- --- EDITING ---
  { key = 'z', mods = 'CMD', action = action.SendString '\x1f' },        -- Undo
  { key = 'z', mods = 'CMD|SHIFT', action = action.SendString '\x19' },  -- Redo

  -- --- SELECTION (Visual Mode) ---
  { key = 'LeftArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2D' },
  { key = 'RightArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2C' },
  { key = 'UpArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2A' },
  { key = 'DownArrow', mods = 'SHIFT', action = action.SendString '\x1b[1;2B' },
  
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
  
  -- --- WORKSPACES (Multiplexing) ---
  { key = 's', mods = 'CMD', action = action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { key = 'n', mods = 'CMD|SHIFT', action = action.SwitchToWorkspace }, -- Prompts for new name
  { key = 'r', mods = 'CMD|SHIFT', action = action.PromptInputLine {
      description = 'Enter new workspace name:',
      action = wezterm.action_callback(function(window, pane, line)
          if line then wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line) end
      end),
  } },
  { key = '[', mods = 'CMD|SHIFT', action = action.SwitchWorkspaceRelative(-1) },
  { key = ']', mods = 'CMD|SHIFT', action = action.SwitchWorkspaceRelative(1) },

  -- --- COPY MODE ---
  { key = 'Space', mods = 'CMD|SHIFT', action = action.ActivateCopyMode },
}

-- =========================================================
-- 6. KEY TABLES
-- =========================================================
config.key_tables = {
  copy_mode = {
    { key = 'c', mods = 'CMD', action = action.CopyMode 'Close' },
    { key = 'Escape', mods = 'NONE', action = action.CopyMode 'Close' },
    { key = 'q', mods = 'NONE', action = action.CopyMode 'Close' },
    
    -- Movement
    { key = 'h', mods = 'NONE', action = action.CopyMode 'MoveLeft' },
    { key = 'j', mods = 'NONE', action = action.CopyMode 'MoveDown' },
    { key = 'k', mods = 'NONE', action = action.CopyMode 'MoveUp' },
    { key = 'l', mods = 'NONE', action = action.CopyMode 'MoveRight' },
    { key = 'LeftArrow', mods = 'NONE', action = action.CopyMode 'MoveLeft' },
    { key = 'RightArrow', mods = 'NONE', action = action.CopyMode 'MoveRight' },
    { key = 'UpArrow', mods = 'NONE', action = action.CopyMode 'MoveUp' },
    { key = 'DownArrow', mods = 'NONE', action = action.CopyMode 'MoveDown' },
    
    -- Selection
    { key = 'v', mods = 'NONE', action = action.CopyMode{ SetSelectionMode =  'Cell' } },
    { key = 'V', mods = 'SHIFT', action = action.CopyMode{ SetSelectionMode = 'Line' } },
    
    -- Word
    { key = 'LeftArrow', mods = 'SHIFT', action = action.CopyMode 'MoveBackwardWord' },
    { key = 'RightArrow', mods = 'SHIFT', action = action.CopyMode 'MoveForwardWord' },
    
    -- Action
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
-- 7. PRIVATE OVERRIDES
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
