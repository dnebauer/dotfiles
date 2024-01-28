--[[ rcarriga/nvim-notify : fancy, configurable, notification manager ]]

return {
  "rcarriga/nvim-notify",
  -- change plugin mapping from "Dismiss All" to "Telescope notify"
  keys = {
    {
      "<Leader>un",
      function()
        require("telescope").extensions.notify.notify()
      end,
    },
  },
}
