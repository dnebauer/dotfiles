-- [[ lukas-reineke/indent-blankline.nvim : add indentation guides to neovim ]]

-- lua plugin

return {
  "lukas-reineke/indent-blankline.nvim",
  dependencies = {
    { "folke/snacks.nvim" },
  },
  lazy = false,
  opts = function()
    -- set mapping for toggling indentation guides
    Snacks.toggle({ ---@diagnostic disable-line: undefined-global
      name = "Indention Guides",
      get = function()
        return require("ibl.config").get_config(0).enabled
      end,
      set = function(state)
        require("ibl").setup_buffer(0, { enabled = state })
      end,
    }):map("<leader>ug")
    -- opts
    return {
      indent = {
        -- thinner than the default bold lines
        char = "│",
        tab_char = "│",
      },
      exclude = {
        filetypes = {
          "Trouble",
          "alpha",
          "dashboard",
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "notify",
          "snacks_dashboard",
          "snacks_notif",
          "snacks_terminal",
          "snacks_win",
          "toggleterm",
          "trouble",
        },
      },
    }
  end,
  init = function()
    -- dn-help
    local dn_help_data = vim.g.dn_help_data or {}
    vim.tbl_deep_extend("error", dn_help_data, {
      modules = {
        ["indent-blankline.nvim"] = {
          mappings = {
            ["<leader>ug"] = "Toggle indentation guides",
          },
        },
      },
    })
    vim.g.dn_help_data = dn_help_data
  end,
  main = "ibl",
}
