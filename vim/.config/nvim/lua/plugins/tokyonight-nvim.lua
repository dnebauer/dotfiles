--[[ folke/tokyonight.nvim : dark and light neovim theme ]]

-- lua plugin

return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {},
    config = function()
      -- enable the following command to make this the default colorscheme
      -- • can use: 'tokyonight' or 'tokyonight-{night,storm,day,moon}'
      vim.cmd.colorscheme("tokyonight-moon")
    end,
  },
}
