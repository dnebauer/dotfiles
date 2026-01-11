-- chrishrb/gx.nvim : open links without netrw

-- lua plugin

return {
  {
    "chrishrb/gx.nvim",
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
    cmd = { "Browse" },
    init = function()
      vim.g.netrw_nogx = true -- disable netrw gx
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true, -- default settings
    submodules = false, -- not needed, submodules are required only for tests
  },
}
