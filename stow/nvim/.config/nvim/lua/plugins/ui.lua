return {
  -- Use Tokyo Night theme
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "storm" },
  },

  -- Configure LazyVim to load tokyonight
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  -- Which Key customization
  {
    "folke/which-key.nvim",
    opts = {
      -- custom config if needed
    },
  },
}
