--[[ windwp/nvim-ts-autotag : use treesitter to autoclose/autorename html tags ]]

-- lua plugin

-- WARNING: this plugin appears to load but has no functionality;
--          tried numerous configurations from the repo's issues but none
--          restored the misssing functionality

return {
  {
    "windwp/nvim-ts-autotag",
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {},
  },
}
