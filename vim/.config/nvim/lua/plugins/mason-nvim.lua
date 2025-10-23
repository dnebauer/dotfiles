--[[ mason-org/mason.nvim : portable package manager for neovim ]]

-- lua plugin

return {
  {
    "mason-org/mason.nvim",
    dependencies = {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    -- disable plugin key mappings
    keys = function()
      return {}
    end,
    opts = {
      log_level = vim.log.levels.DEBUG,
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
}
