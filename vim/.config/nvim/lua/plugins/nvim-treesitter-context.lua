--[[ nvim-treesitter/nvim-treesitter-context : lightweight alternative to context.vim ]]

-- automatically loaded since lazyvim 10.x, but load here to disable mappings

return {
  "nvim-treesitter/nvim-treesitter-context",
  -- disable all plugin key mappings
  keys = function()
    return {}
  end,
}
