--[[ mason-org/mason.nvim : portable package manager for neovim ]]

return {
  {
    "mason-org/mason.nvim",
    -- disable plugin key mappings
    keys = function()
      return {}
    end,
    opts = {
      log_level = vim.log.levels.DEBUG,
    },
  },
}
