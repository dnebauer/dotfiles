-- [[ nvim-mini/mini.surround : delete/change/add surrounding parens, etc. ]]

-- lua plugin
-- part of LazyVim extras

return {
  {
    "nvim-mini/mini.surround",
    opts = {
      -- match my customised version of the standard tpope/vim-surround mappings
      mappings = {
        add = "yz", -- add surrounding in Normal and Visual modes
        delete = "dz", -- delete surrounding
        find = "", -- find surrounding (to the right)
        find_left = "", -- find surrounding (to the left)
        highlight = "", -- highlight surrounding
        replace = "cz", -- replace surrounding
        update_n_lines = "", -- update `n_lines`
      },
      search_method = "cover_or_next",
    },
    -- additional mappings defined in config 'keymaps.lua' file
  },
}
