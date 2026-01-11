--[[ alexghergh/nvim-tmux-navigation : navigate between vim and tmux splits ]]

-- lua plugin

return {
  {
    "alexghergh/nvim-tmux-navigation",
    lazy = false,
    opts = {
      -- counterintuitively, this is required to prevent the plugin
      -- being disabled by default
      disable_when_zoomed = true, -- default = false
    },
    config = function(_, opts)
      -- opts are not loaded automatically, so force it here
      require("nvim-tmux-navigation").setup(opts)

      -- set up plugin key mappings
      local map = vim.keymap.set
      map(
        { "n", "t" },
        "<c-h>",
        "<cmd>NvimTmuxNavigateLeft<cr>",
        { silent = true, desc = "Move left to next pane/split" }
      )
      map(
        { "n", "t" },
        "<c-j>",
        "<cmd>NvimTmuxNavigateDown<cr>",
        { silent = true, desc = "Move down to next pane/split" }
      )
      map({ "n", "t" }, "<c-k>", "<cmd>NvimTmuxNavigateUp<cr>", { silent = true, desc = "Move up to next pane/split" })
      map(
        { "n", "t" },
        "<c-l>",
        "<cmd>NvimTmuxNavigateRight<cr>",
        { silent = true, desc = "Move right to next pane/split" }
      )
      map(
        { "n", "t" },
        "<c-\\>",
        "<cmd>NvimTmuxNavigateLastActive<cr>",
        { silent = true, desc = "Move to previous pane/split" }
      )
    end,
  },
}
