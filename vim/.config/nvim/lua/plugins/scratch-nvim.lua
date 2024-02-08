--[[ swaits/scratch.nvim : a simple way to work with scratch buffers ]]

return {
  "swaits/scratch.nvim",
  keys = {
    { "<leader>bs", "<cmd>Scratch<cr>", desc = "Scratch Buffer", mode = "n" },
    { "<leader>bS", "<cmd>ScratchSplit<cr>", desc = "Scratch Buffer (split)", mode = "n" },
  },
  cmd = {
    "Scratch",
    "ScratchSplit",
  },
  config = true,
}
