--[[ axieax/urlview.nvim : finds and display urls ]]

-- lua plugin

return {
  {
    "axieax/urlview.nvim",
    config = function()
      -- use qutebrowser to open urls
      -- • define 'spectate' action
      local actions = require("urlview.actions")
      actions["spectate"] = function(raw_url)
        local utils = require("urlview.utils")
        local cmd = "qutebrowser"
        if cmd and vim.fn.executable(cmd) == 1 then
          local args = { cmd, raw_url }
          local err = vim.fn.system(args)
          if vim.v.shell_error ~= 0 then
            if err ~= "" then
              utils.log(string.format("Could not navigate link with `%s`:\n%s", cmd, err), vim.log.levels.ERROR)
            else
              utils.log(string.format("Could not navigate link with `%s`", cmd), vim.log.levels.ERROR)
            end
          end
        else
          utils.log(
            string.format("Cannot use command `%s` to navigate links (either empty or non-executable)", cmd),
            vim.log.levels.ERROR
          )
        end
      end
      -- set up plugin
      require("urlview").setup({
        default_action = "spectate",
        default_picker = "telescope",
      })
    end,
  },
}
