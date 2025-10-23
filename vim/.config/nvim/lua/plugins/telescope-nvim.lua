--[[ nvim-telescope/telescope.nvim : highly extendable fuzzy finder over lists ]]

-- lua plugin

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
    -- setting up noice as a dependency results in the following error on executing "Telescope noice":
    -- > Error executing Lua callback:
    -- > ...nvim/lazy/noice.nvim/lua/telescope/_extensions/noice.lua:30:
    -- > attempt to index field 'commands' (a nil value)
    -- so define it here instead                                                                                                                           │(a nil value)
    config = function()
      require("telescope").load_extension("noice")
    end,
    keys = {
      -- find buffer
      {
        "<leader>fb",
        "<cmd>lua require('telescope.builtin').buffers()<cr>",
        { "n" },
        desc = "Telescope Buffers",
      },
    },
    dependencies = {
      -- ctags outline
      {
        "fcying/telescope-ctags-outline.nvim",
        config = function()
          require("telescope").load_extension("ctags_outline")
        end,
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
      -- notify
      {
        "rcarriga/nvim-notify",
        config = function()
          require("telescope").load_extension("notify")
        end,
      },
      -- scriptnames
      {
        "LinArcX/telescope-scriptnames.nvim",
        config = function()
          require("telescope").load_extension("scriptnames")
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
      -- toggleterm
      {
        "ryanmsnyder/toggleterm-manager.nvim",
        config = function()
          require("telescope").load_extension("toggleterm_manager")
        end,
      },
      -- undo
      {
        "debugloop/telescope-undo.nvim",
        keys = {
          {
            "<leader>U",
            "<cmd>lua require('telescope').extensions.undo.undo()<cr>",
            { "n" },
            desc = "Telescope Undo",
          },
        },
        config = function()
          require("telescope").load_extension("undo")
        end,
      },
    },
  },
}
