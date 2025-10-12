--[[ folke/trouble.nvim : better diagnostics list ]]

-- lua plugin
-- part of default LazyVim

return {
  {
    "folke/trouble.nvim",
    -- disable some plugin key mappings
    -- • \cs = toggle symbols
    -- • \cl = toggle symbols
    -- • \xL = toggle lsp definition, references, etc.
    -- • \xQ = toggle quickfix
    -- leaves the following active key mappings:
    -- • \xx = toggle diagnostics (all buffers)
    -- • \xX = toggle diagnostics (current buffer)
    keys = {
      { "<Leader>cs", false },
      -- lsp definitions, etc., toggle
      { "<Leader>xL", false },
      -- loclist toggle
      { "<Leader>xL", false },
      -- quickfix list toggle
      { "<Leader>xQ", false },
    },
  },
}
