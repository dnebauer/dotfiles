--[[ nvim-tree/nvim-web-devicons : provide filetype glyphs ]]

return {
  {
    "nvim-tree/nvim-web-devicons",
    ---- nvim-material-icon is an improved version of nvim-web-devicons
    ---- which is configured with nvim-web-devicons as per
    ---- https://alpha2phi.medium.com/modern-neovim-pde-part-3-ad1936137efeA
    --dependencies = { "DaikyXendo/nvim-material-icon" },
    --config = function()
    --  require("nvim-web-devicons").setup({
    --    override = require("nvim-material-icon").get_icons(),
    --  })
    --end,
  },
}
