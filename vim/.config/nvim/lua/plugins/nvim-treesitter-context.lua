--[[ nvim-treesitter/nvim-treesitter-context : lightweight alternative to context.vim ]]

-- lua plugin
-- part of LazyVim extras

return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    -- disable all plugin key mappings
    keys = function()
      return {}
    end,
  },
}
