--[[ rcarriga/nvim-notify : fancy, configurable, notification manager ]]

-- lua plugin
-- not part of default LazyVim

return {
  {
    "rcarriga/nvim-notify",
    -- change plugin mapping from "Dismiss All" to "Telescope notify"
    keys = {
      {
        "<Leader>un",
        function()
          require("telescope").extensions.notify.notify()
        end,
        desc = "Telescope Notify",
      },
    },
  },
}
