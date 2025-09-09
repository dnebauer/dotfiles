--[[ nvim-treesitter/nvim-treesitter : interface to parsing tool treesitter ]]

return {
  {
    "nvim-treesitter/nvim-treesitter",
    keys = function()
      return {}
    end,
    opts = {
      matchup = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "css",
        "diff",
        "html",
        "java",
        "javascript",
        "jq",
        "jsdoc",
        "json",
        "latex",
        "lua",
        "luadoc",
        "make",
        "markdown",
        "markdown_inline",
        "perl",
        "python",
        "query",
        "regex",
        "ruby",
        "tcl",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          --node_incremental = "<C-space>",
          node_incremental = "v",
          scope_incremental = false,
          --node_decremental = "<bs>",
          node_decremental = "V",
        },
      },
    },
  },
}
