--[[ catppuccin/nvim : pastel theme for neovim ]]

-- lua plugin

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "auto", -- auto, latte, frappe, macchiato, mocha
      background = { -- :h background
        light = "latte", -- latte
        dark = "mocha", -- frappe, macchiato, mocha
      },
      lsp_styles = {
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        fzf = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        mini = true,
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        snacks = true,
        telescope = true,
        treesitter_context = true,
        which_key = true,
      },
    },
    specs = {
      {
        "akinsho/bufferline.nvim",
        optional = true,
        opts = function(_, opts)
          if (vim.g.colors_name or ""):find("catppuccin") then
            opts.highlights = require("catppuccin.special.bufferline").get_theme()
          end
        end,
      },
    },
    config = function()
      -- enable the following command to make this the default colorscheme
      -- • can use: 'catppuccin' or 'catppuccin-{latte,frappe,macchiato,mocha}'
      --vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
}
