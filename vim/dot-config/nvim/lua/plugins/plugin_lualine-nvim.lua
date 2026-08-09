--[[ nvim-lualine/lualine.nvim : nvim statusline ]]

-- lua plugin

return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      local opts = {
        options = {
          icons_enabled = true,
          theme = "auto",
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = " ",
                hint = " ",
                info = " ",
                warn = " ",
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", color = { fg = "#ffffff" } },
          },
          lualine_x = {
            { "encoding", "fileformat", "filetype" },
            -- show normal-mode keystrokes
            {
              ---@diagnostic disable:undefined-field
              require("noice").api.status.command.get,
              cond = require("noice").api.status.command.has,
              color = { fg = "#ff9e64" },
              ---@diagnostic enable:undefined-field
            },
            -- show notice when macro is recording
            {
              ---@diagnostic disable:undefined-field,deprecated
              require("noice").api.statusline.mode.get,
              cond = require("noice").api.statusline.mode.has,
              color = { fg = "#ff9e64" },
              ---@diagnostic enable:undefined-field,deprecated
            },
          },
          lualine_y = { { "progress", separator = " ", padding = { left = 1, right = 0 } } },
          lualine_z = { { "location", padding = { left = 0, right = 1 } } },
        },
        extensions = { "neo-tree", "lazy", "fzf" },
      }

      return opts
    end,
  },
}
