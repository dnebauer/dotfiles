--[[ akinsho/bufferline.nvim : buffer line with tabpage integration ]]

return {
  {
    "akinsho/bufferline.nvim",
    -- disable plugin key mappings
    -- • rely on general LazyVim mappings for '[b' and ']b' mappings
    keys = function()
      return {}
    end,
  },
}
