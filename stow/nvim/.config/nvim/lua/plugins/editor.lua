return {
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- Search (Find Files) - Force show hidden & ignored (filtered by file_ignore_patterns)
      {
        "<leader>ff",
        function() require("telescope.builtin").find_files({ hidden = true, no_ignore = true }) end,
        desc = "Find Files (Root Dir)",
      },
      {
        "<leader>fF",
        function() require("telescope.builtin").find_files({ hidden = true, no_ignore = true, cwd = false }) end,
        desc = "Find Files (Cwd)",
      },
      {
        "<leader><space>",
        function() require("telescope.builtin").find_files({ hidden = true, no_ignore = true }) end,
        desc = "Find Files (Root Dir)",
      },
      -- Grep (Find Text) - Force show hidden & ignored
      {
        "<leader>/",
        function() require("telescope.builtin").live_grep({ additional_args = { "--hidden", "--no-ignore" } }) end,
        desc = "Grep (Root Dir)",
      },
      {
        "<leader>sg",
        function() require("telescope.builtin").live_grep({ additional_args = { "--hidden", "--no-ignore" } }) end,
        desc = "Grep (Root Dir)",
      },
    },
    opts = {
      defaults = {
        -- Ensure .git folder itself is ignored even if hidden is on, otherwise it's noisy
        file_ignore_patterns = { 
          ".git/", 
          "node_modules", 
          "target/", 
          "dist/", 
          "build/", 
          "%.DS_Store",
          "%.png", "%.jpg", "%.jpeg", "%.mp4", "%.zip", "%.pdf", -- Media/Binaries
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    },
  },

  -- Neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true, -- Check if this is conflicting
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },
}
