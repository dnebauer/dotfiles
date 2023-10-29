--[[ christoomey/vim-tmux-navigator : navigate between vim and tmux splits ]]

return {
  "christoomey/vim-tmux-navigator",
  keys = {
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
  },
}
