--[[ tris203/hawtkeys.nvim : find/suggest keys for nvim shortcuts ]]

-- lua plugin
-- not part of default LazyVim

return {
  {
    "tris203/hawtkeys.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
      "Hawtkeys",
      "HawtkeysAll",
      "HawtkeysDupes",
    },
    opts = {},
  },
}
