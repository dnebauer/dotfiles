--[[ hedyhli/outline.nvim : LSP-powered sidebar with a tree-like outline of symbols ]]

-- lua plugin
-- part of default LazyVim

return {
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { { "<F5>", "<Cmd>Outline<CR>", desc = "Toggle Outline" } },
    opts = {},
  },
}
