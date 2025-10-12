--[[ hotoo/template.vim : file templates ]]

-- vim plugin
-- not part of default LazyVim

return {
  {
    "hotoo/template.vim",
    config = function()
      vim.g.template_dir = vim.fn.stdpath("config") .. "/template"
      vim.g.template_author = "David Nebauer (david at nebauer dot org)"
    end,
  },
}
