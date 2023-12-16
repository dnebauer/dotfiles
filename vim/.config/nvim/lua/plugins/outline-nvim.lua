--[[ hedyhli/outline.nvim : LSP-powered sidebar with a tree-like outline of symbols ]]

return {
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = { { "<F5>", "<Cmd>Outline<CR>", desc = "Toggle outline" } },
    opts = {},
  },
}
