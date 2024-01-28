--[[ folke/noice.nvim : replaces the UI for messages, cmdline and the popupmenu ]]

return {
  "folke/noice.nvim",
  -- disable all plugin key mappings except <C-f> and <C-b> for lsp hover docs
  keys = {
    { "<S-Enter>", false },
    { "<leader>snl", false },
    { "<leader>snh", false },
    { "<leader>sna", false },
    { "<leader>snd", false },
  },
  opts = {
    cmdline = {
      enabled = true, -- enables the Noice cmdline UI
      view = "cmdline", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
    },
    messages = {
      -- NOTE: If you enable messages, then the cmdline is enabled automatically.
      -- This is a current Neovim limitation.
      enabled = true, -- enables the Noice messages UI
      view = "notify", -- default view for messages
      view_error = "mini", -- view for errors
      view_warn = "mini", -- view for warnings
      view_history = "messages", -- view for :messages
      view_search = "mini", -- view for search count messages. Set to `false` to disable
    },
    -- You can add any custom commands below that will be available with `:Noice command`
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
  },
}
