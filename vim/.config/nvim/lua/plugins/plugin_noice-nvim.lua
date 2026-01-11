--[[ folke/noice.nvim : replaces the UI for messages, cmdline and the popupmenu ]]

-- lua plugin

return {
  {
    "folke/noice.nvim",
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- only need `nvim-notify` if you want to use the notification view;
      -- if not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
    -- disable all plugin key mappings except <C-f> and <C-b> for lsp hover docs
    keys = {
      { "<leader>sn", false },
      { "<S-Enter>", false },
      { "<leader>snl", false },
      { "<leader>snh", false },
      { "<leader>sna", false },
      { "<leader>snd", false },
      { "<leader>snt", false },
    },
    opts = {
      cmdline = {
        enabled = true, -- enables the Noice cmdline UI
        view = "cmdline", -- `cmdline` gets a classic cmdline at the bottom
      },
      messages = {
        -- NOTE: if you enable messages, then the cmdline is enabled
        -- automatically (this is a current Neovim limitation)
        enabled = true, -- enables the Noice messages UI
        view = "notify", -- default view for messages
        view_error = "mini", -- view for errors
        view_warn = "mini", -- view for warnings
        view_history = "messages", -- view for :messages
        view_search = "mini", -- view for search count messages. Set to `false` to disable
      },
      -- you can add any custom commands below that will be available with `:Noice command`
      commands = {
        -- :Noice errors
        errors = {
          -- options for the message history that you get with `:Noice`
          view = "cmdline",
          opts = { enter = true, format = "details" },
          filter = { error = true },
          filter_opts = { reverse = true },
        },
      },
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
    },
  },
}
