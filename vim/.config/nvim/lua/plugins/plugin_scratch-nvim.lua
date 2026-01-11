--[[ swaits/scratch.nvim : a simple way to work with scratch buffers ]]

-- lua plugin

return {
  {
    "swaits/scratch.nvim",
    lazy = true,
    keys = {},
    cmd = {
      "Scratch",
      "ScratchSplit",
    },
    opts = {},
  },
}
