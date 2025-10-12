--[[ nvim-treesitter/nvim-treesitter : interface to parsing tool treesitter ]]

-- lua plugin
-- part of default LazyVim

return {
  {
    "nvim-treesitter/nvim-treesitter",
    keys = function()
      return {}
    end,
    branch = "main",
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts = {
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
      auto_install = true,
      folds = { enable = true },
      highlight = { enable = true },
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
      indent = { enable = true },
      matchup = { enable = true },
      sync_install = false,
    },
  },
}
