--[[ lewis6991/ts-install.nvim : install, update, and remove parsers ]]

-- lua plugin

--[[
return {
  {
    "lewis6991/ts-install.nvim",
    config = function()
      require("ts-install").setup({
        parsers = {
          mail = {
            install_info = {
              url = "https://github.com/stevenxxiu/tree-sitter-mail",
              branch = "master",
            },
          },
        },
      })
    end,
  },
}
]]
