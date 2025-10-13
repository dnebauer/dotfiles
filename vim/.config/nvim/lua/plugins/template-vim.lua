--[[ dnebauer/template.vim : file templates ]]

-- vim plugin
-- not part of default LazyVim

-- forked from hotoo/template.vim to fix duplicate tag errors

return {
  {
    "dnebauer/template.vim",
    config = function()
      vim.g.template_dir = vim.fn.stdpath("config") .. "/template"
      vim.g.template_author = "David Nebauer (david at nebauer dot org)"
    end,
  },
}
