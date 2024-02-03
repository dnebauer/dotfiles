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
    -- setting up noice as a dependency results in the following error on executing "Telescope noice":
    -- > Error executing Lua callback:
    -- > ...nvim/lazy/noice.nvim/lua/telescope/_extensions/noice.lua:30:
    -- > attempt to index field 'commands' (a nil value)
    -- so define it here instead                                                                                                                           │(a nil value)
    config = function()
      require("telescope").load_extension("noice")
    end,
    keys = {
      -- disable these plugin key mappings
      { "<Leader>,", false },
      { "<Leader><Space>", false },
      { "<Leader>fc", false },
      { "<Leader>fF", false },
      { "<Leader>fR", false },
      { "<Leader>sa", false },
      { "<Leader>sb", false },
      { "<Leader>sC", false },
      { "<Leader>sd", false },
      { "<Leader>sD", false },
      { "<Leader>sg", false },
      { "<Leader>sG", false },
      { "<Leader>sH", false },
      { "<Leader>ss", false },
      { "<Leader>sS", false },
      -- reassign "<Leader>sC" action to "<Leader>sc"
      { "<leader>sc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      -- add this plugin key mapping
      {
        "<Leader>fs",
        "<Cmd>Telescope builtin<CR>",
        desc = "Telescope builtin selectors",
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
      -- file finder based on frequency and recency
      {
        "nvim-telescope/telescope-frecency.nvim",
        config = function(_, opts)
          require("telescope").load_extension("frecency")
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
        keys = { { "<leader>U", "<cmd>Telescope undo<cr>" } },
        config = function()
          require("telescope").load_extension("undo")
        end,
      },
    },
  },
}
