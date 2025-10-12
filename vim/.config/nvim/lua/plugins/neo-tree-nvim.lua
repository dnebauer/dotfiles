--[[ nvim-neo-tree/neo-tree.nvim : browse the file system and other tree like structures ]]

-- lua plugin
-- part of LazyVim extras

return {
  "nvim-neo-tree/neo-tree.nvim",
  lazy = false, -- neo-tree will lazily load itself
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons", -- optional, but recommended
  },
  keys = {
    { "<leader>fE", false },
    { "<leader>e", false },
    { "<leader>E", false },
  },
}
