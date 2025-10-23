--[[ farmergreg/vim-lastplace : reopen files at last edit position ]]

-- vimscript plugin

return {
  {
    "farmergreg/vim-lastplace",
    init = function()
      -- variable default values in case I want to change them later
      -- • file types to ignore
      local lastplace_ignore = {
        "gitcommit",
        "gitrebase",
        "hgcommit",
        "svn",
        "xxd",
      }
      vim.g.lastplace_ignore = table.concat(lastplace_ignore, ",")
      -- • buffer types to ignore
      local lastplace_ignore_buftype = {
        "help",
        "nofile",
        "quickfix",
      }
      vim.g.lastplace_ignore_buftype = table.concat(lastplace_ignore_buftype, ",")
      -- • whether to automatically open folds enclosing the last place
      vim.g.lastplace_open_folds = true
    end,
  },
}
