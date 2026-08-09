-- stevearc/oil.nvim : edit the filesystem like a normal buffer

-- lua plugin

return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = {
      { "nvim-tree/nvim-web-devicons", opts = {} },
      { "MagicDuck/grug-far.nvim" },
    },
    opts = {
      keymaps = {
        -- create new mapping: gs
        -- • available while in "oil" file explorer
        -- • search and replace in the current directory
        -- • taken from the grug-far readme at
        --   https://github.com/MagicDuck/grug-far.nvim?tab=readme-ov-file#\
        --   add-oilnvim-integration-to-open-search-limited-to-focused-directory
        gs = {
          callback = function()
            -- get the current directory
            local prefills = { paths = require("oil").get_current_dir() }
            local grug_far = require("grug-far")
            -- instance check
            if not grug_far.has_instance("explorer") then
              grug_far.open({
                instanceName = "explorer",
                prefills = prefills,
                staticTitle = "Find and Replace from Explorer",
              })
            else
              grug_far.get_instance("explorer"):open()
              -- updating the prefills without clearing the search and other fields
              grug_far.get_instance("explorer"):update_input_values(prefills, false)
            end
          end,
          desc = "oil: Search in directory",
        },
      },
    },
  },
}
