-- use nvim-cmp as the Conventional Commits completion source for fugitive.vim
-- * also requires configuration of hrsh7th/nvim-cmp plugin
-- * as per https://alpha2phi.medium.com/neovim-for-beginners-conventional-commits-f7f152ad1b78
require("cmp").setup.buffer({
  sources = require("cmp").config.sources({ { name = "conventionalcommits" } }, { { name = "buffer" } }),
})
