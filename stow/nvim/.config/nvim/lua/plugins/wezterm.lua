return {
  -- Smart Splits: Unify navigation between Neovim splits and Wezterm panes
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {},
    keys = {
      -- Move between splits/panes
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move cursor left" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move cursor down" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move cursor up" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move cursor right" },
      
      -- Resize splits
      { "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
      { "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
      { "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
      { "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize split right" },
    },
  },
}
