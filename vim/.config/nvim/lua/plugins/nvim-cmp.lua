--[[ hrsh7th/nvim-cmp : completion engine written in Lua ]]

return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- use nvim-cmp as the Conventional Commits completion source for fugitive.vim
      -- * also requires after/ftplugin/gitcommit.lua file
      -- * as per https://alpha2phi.medium.com/neovim-for-beginners-conventional-commits-f7f152ad1b78
      "davidsierradz/cmp-conventionalcommits",
    },
  },
}
