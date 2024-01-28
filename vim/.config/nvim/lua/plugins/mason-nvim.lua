--[[ williamboman/mason.nvim : portable package manager for neovim ]]

return {
  {
    "williamboman/mason.nvim",
    -- disable plugin key mappings
    keys = function()
      return {}
    end,
    opts = {
      log_level = vim.log.levels.DEBUG,
    },
  },
}
