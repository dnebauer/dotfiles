-- [[ nvim-mini/mini.surround : delete/change/add surrounding parens, etc. ]]

-- lua plugin

return {
  {
    "nvim-mini/mini.surround",
    -- opts not automatically processed: need to pass to lazy's
    -- "config" function to pass to plugin's "setup" function
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
    config = function(_, opts)
      -- setup
      require("mini.surround").setup(opts)
      -- custom mappings
      local map = vim.keymap.set
      -- • remap adding surrounding to Visual mode selection
      map(
        { "x" },
        "z",
        ":<c-u>lua MiniSurround.add('visual')<cr>",
        { silent = true, desc = "Add Surrounding to Selection" }
      )
      -- • make special mapping for "add surrounding for line"
      map({ "n" }, "yzz", "yz_", { remap = true, desc = "Add Surrounding for Line" })
    end,
  },
}
