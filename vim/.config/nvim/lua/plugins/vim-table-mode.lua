--[[ dhruvasagar/vim-table-mode : automatic table creator and formatter ]]

-- vim plugin
-- not part of default LazyVim

return {
  {
    "dhruvasagar/vim-table-mode",
    config = function()
      -- pandoc grid tables
      -- • if set 'g:table_mode_corner' or 'b:table_mode_corner' here it will
      --   be ignored because the plugin file "tablemode_markdown.vim" sets
      --   'b:table_mode_corner' to "|" which overrides them
      -- • as per https://github.com/dhruvasagar/vim-table-mode/issues/185,
      --   the solution is to create file:
      --     ~/.config/nvim/after/ftplugin/markdown/tablemode_override.vim
      --   with content:
      --     let b:table_mode_corner = '+'
      vim.g.table_mode_corner_corner = "+"
      vim.g.table_mode_header_fillchar = "="
      -- automatically add row borders when create table with :Tableize
      vim.g.table_mode_tableize_auto_border = true
    end,
  },
}
