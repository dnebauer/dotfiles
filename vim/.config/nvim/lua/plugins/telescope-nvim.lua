--[[ nvim-telescope/telescope.nvim : highly extendable fuzzy finder over lists ]]

return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      extensions = {
        ctags_outline = {
          --ctags option
          ctags = { "ctags" },
          --ctags filetype option
          ft_opt = {
            vim = "--vim-kinds=fk",
            lua = "--lua-kinds=fk",
          },
        },
        heading = {
          treesitter = true,
        },
      },
    },
    dependencies = {
      -- file finder based on frequency and recency
      {
        "nvim-telescope/telescope-frecency.nvim",
        event = "VeryLazy",
        opts = {},
        config = function(_, opts)
          require("frecency").setup(opts)
          require("lazyvim.util").on_load("telescope.nvim", function()
            require("telescope").load_extension("frecency")
          end)
        end,
      },
      -- software licenses
      {
        "chip/telescope-software-licenses.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        config = function()
          require("lazyvim.util").on_load("telescope.nvim", function()
            require("telescope").load_extension("software-licenses")
          end)
        end,
      },
      -- symbols
      {
        "nvim-telescope/telescope-symbols.nvim",
        event = "VeryLazy",
      },
      -- emojis
      {
        "xiyaowong/telescope-emoji.nvim",
        event = "VeryLazy",
        config = function()
          require("lazyvim.util").on_load("telescope.nvim", function()
            require("telescope").load_extension("emoji")
          end)
        end,
      },
      -- glyphs
      {
        "ghassan0/telescope-glyph.nvim",
        event = "VeryLazy",
        config = function()
          require("lazyvim.util").on_load("telescope.nvim", function()
            require("telescope").load_extension("glyph")
          end)
        end,
      },
      -- headings
      {
        "crispgm/telescope-heading.nvim",
        event = "VeryLazy",
        config = function()
          require("lazyvim.util").on_load("telescope.nvim", function()
            require("telescope").load_extension("heading")
          end)
        end,
      },
      -- ctags outline
      {
        "fcying/telescope-ctags-outline.nvim",
        event = "VeryLazy",
        config = function()
          require("lazyvim.util").on_load("telescope.nvim", function()
            require("telescope").load_extension("ctags_outline")
          end)
        end,
      },
      -- scriptnames
      {
        "LinArcX/telescope-scriptnames.nvim",
        event = "VeryLazy",
        config = function()
          require("lazyvim.util").on_load("telescope.nvim", function()
            require("telescope").load_extension("scriptnames")
          end)
        end,
      },
      -- undo
      {
        "debugloop/telescope-undo.nvim",
        event = "VeryLazy",
        config = function()
          require("lazyvim.util").on_load("telescope.nvim", function()
            require("telescope").load_extension("undo")
          end)
        end,
      },
    },
  },
}
