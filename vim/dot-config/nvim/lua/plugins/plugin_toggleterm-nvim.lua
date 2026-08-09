--[[ akinsho/toggleterm.nvim : persist and toggle multiple terminals ]]

-- lua plugin

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return math.floor(vim.opt.lines:get() * 0.5)
        elseif term.direction == "vertical" then
          return math.floor(vim.opt.columns:get() * 0.4)
        end
      end,
    },
    keys = {
      {
        "<Leader>td",
        "<Cmd>ToggleTerm direction=horizontal<CR>",
        desc = "Open Horizontal Terminal in CWD",
      },
    },
  },
}
