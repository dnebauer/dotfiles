-- [[ nvim-mini/mini.surround : delete/change/add surrounding parens, etc. ]]

return {
  {
    "nvim-mini/mini.surround",
    -- force load because the 'z' and 'yzz' mappings do not trigger lazy load
    lazy = false,
    -- configure to match my customised version of the standard tpope/vim-surround mappings
    config = function()
      -- most mappings are configured by altering the plugin's configuration table:
      require("mini.surround").setup({
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
      })
      -- these mappings cannot be configured by altering the plugin's configuration table:
      -- * remap adding surrounding to Visual mode selection
      vim.keymap.set(
        "x",
        "z",
        [[:<C-u>lua MiniSurround.add('visual')<CR>]],
        { silent = true, desc = "Add Surrounding to Selection" }
      )
      -- * make special mapping for "add surrounding for line"
      vim.keymap.set("n", "yzz", "yz_", { remap = true, desc = "Add Surrounding for Line" })
    end,
  },
}
