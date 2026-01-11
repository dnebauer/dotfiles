-- [[ rafamadriz/friendly-snippets : snippets collection ]]

-- lua plugin

return {
  {
    "rafamadriz/friendly-snippets",
    -- add blink.compat to dependencies
    {
      "saghen/blink.compat",
      optional = true, -- make optional so it's only enabled if any extras need it
      opts = {},
    },
    -- ensure LuaSnips snippets are detected (although LuaSnips not loaded!)
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
    end,
  },
}
