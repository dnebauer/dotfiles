--[[ rcarriga/nvim-notify : fancy, configurable, notification manager ]]

-- lua plugin

return {
  {
    "rcarriga/nvim-notify",
    -- change plugin mapping from "Dismiss All" to "Telescope notify",
    -- i.e., display all notifications in a searchable list
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
