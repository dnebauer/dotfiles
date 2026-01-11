--[[ nvim-neo-tree/neo-tree.nvim : browse the file system and other tree like structures ]]

-- lua plugin

return {
  "nvim-neo-tree/neo-tree.nvim",
  lazy = false, -- neo-tree will lazily load itself
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons", -- optional, but recommended
    "antosha417/nvim-lsp-file-operations", -- lsp integration for commands (copy.delete/move/etc.)
    "s1n7ax/nvim-window-picker", -- window picker
  },
  keys = {
    { "<leader>fE", false },
    { "<leader>e", false },
    { "<leader>E", false },
  },
}
