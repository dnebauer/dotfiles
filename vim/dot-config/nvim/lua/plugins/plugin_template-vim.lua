--[[ hotoo/template.vim : file templates ]]

-- vimscript plugin

return {
  {
    "hotoo/template.vim",
    init = function()
      vim.g.template_dir = vim.fn.stdpath("config") .. "/template"
      vim.g.template_author = "David Nebauer (david at nebauer dot org)"
    end,
  },
}
