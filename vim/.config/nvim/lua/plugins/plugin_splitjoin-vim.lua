--[[ andrewradev/splitjoin.vim : single <-> multi-line statements ]]

-- vimscript plugin

return {
  {
    "andrewradev/splitjoin.vim",
    -- gJ mapping:
    -- • this plugin has two normal mode key mapings: gS and gJ
    -- • the hardtime.nvim plugin resets gJ and that breaks this
    --   plugin's mapping of gJ
    -- • in the hardtime.nvim plugin file the resetting of gJ is
    --   prevented, allowing this plugin to grab gJ and map to it
  },
}
