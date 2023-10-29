--[[ stevearc/aerial.nvim : outline window for skimming and quick navigation ]]

return {
  {
    "stevearc/aerial.nvim",
    -- change aerial toggle from default '\cs' to 'F5'
    keys = {
      { "<Leader>cs", "", desc = "config for plugin: stevearc/aerial.nvim" },
      { "<F5>", "<Cmd>AerialToggle<CR>", desc = "Aerial (Symbols)" },
    },
  },
}
