return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",  -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the below with a valid path to your Obsidian vault.
    -- If you don't have one yet, this will error or warn. 
    -- Ideally, we should detect or ask, but for now we set a default `~/Notes` or similar.
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/Notes", -- Default vault location
        },
      },
      
      -- Optional, customize how names/ids for new notes are created
      note_id_func = function(title)
        return title or tostring(os.time())
      end,
      
      -- Optional, for templates
      -- templates = {
      --   folder = "templates",
      --   date_format = "%Y-%m-%d",
      --   time_format = "%H:%M",
      -- },
    },
    keys = {
      { "<leader>nn", "<cmd>ObsidianNew<cr>", desc = "New Note" },
      { "<leader>ns", "<cmd>ObsidianSearch<cr>", desc = "Search Notes" },
      { "<leader>nt", "<cmd>ObsidianTemplate<cr>", desc = "Insert Template" },
    },
  },
}
