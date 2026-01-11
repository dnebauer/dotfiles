--[[ m4xshen/hardtime.nvim : establish good command workflow and habit ]]

-- lua plugin

return {
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      -- leave "gJ" (normal mode) alone so splitjoin.vim can grab it
      resetting_keys = {
        ["gJ"] = false,
      },
    },
  },
}
