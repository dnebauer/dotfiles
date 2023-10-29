--[[ hotoo/template.vim : file templates ]]

return {
  {
    "hotoo/template.vim",
    config = function()
      vim.g.template_dir = vim.fn.stdpath("config") .. "/template"
      vim.g.template_author = "David Nebauer (david at nebauer dot org)"
    end,
  },
}
