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
    config = function()
      require("telescope").load_extension("noice")
    end,
    keys = {
      {
        "<Leader>fs",
        "<Cmd>Telescope builtin<CR>",
        desc = "Telescope builtin selectors",
      },
    },
    dependencies = {
      -- file finder based on frequency and recency
      {
        "nvim-telescope/telescope-frecency.nvim",
        config = function(_, opts)
          require("telescope").load_extension("frecency")
        end,
      },
      -- software licenses
      {
        "chip/telescope-software-licenses.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
          require("telescope").load_extension("software-licenses")
        end,
      },
      -- symbols
      {
        "nvim-telescope/telescope-symbols.nvim",
      },
      -- emojis
      {
        "xiyaowong/telescope-emoji.nvim",
        config = function()
          require("telescope").load_extension("emoji")
        end,
      },
      -- glyphs
      {
        "ghassan0/telescope-glyph.nvim",
        config = function()
          require("telescope").load_extension("glyph")
        end,
      },
      -- headings
      {
        "crispgm/telescope-heading.nvim",
        config = function()
          require("telescope").load_extension("heading")
        end,
      },
      -- ctags outline
      {
        "fcying/telescope-ctags-outline.nvim",
        config = function()
          require("telescope").load_extension("ctags_outline")
        end,
      },
      -- scriptnames
      {
        "LinArcX/telescope-scriptnames.nvim",
        config = function()
          require("telescope").load_extension("scriptnames")
        end,
      },
      -- undo
      {
        "debugloop/telescope-undo.nvim",
        keys = { { "<leader>U", "<cmd>Telescope undo<cr>" } },
        config = function()
          require("telescope").load_extension("undo")
        end,
      },
    },
  },
}
