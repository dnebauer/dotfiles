--[[ alexghergh/nvim-tmux-navigation : navigate between vim and tmux splits ]]

return {
  {
    "alexghergh/nvim-tmux-navigation",
    event = "VeryLazy",
    config = function()
      local nvim_tmux_nav = require("nvim-tmux-navigation")
      nvim_tmux_nav.setup({
        disable_when_zoomed = true, -- defaults to false
      })
    end,
    --[[ define keymaps in lua/config/keymaps.lua ]]
  },
}
