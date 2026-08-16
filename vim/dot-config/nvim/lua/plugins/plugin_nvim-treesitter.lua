--[[ nvim-treesitter/nvim-treesitter : interface to parsing tool treesitter ]]

-- lua plugin

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    keys = {},
    config = function()
      -- languages to be handled by treesitter
      local languages = {
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
        "mail",
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
        "zsh",
      }

      -- use default setup
      require("nvim-treesitter").setup({})

      -- ensure language parsers are installed
      require("nvim-treesitter").install(languages)

      -- run treesitter
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("my_treesitter_run", { clear = true }),
        pattern = languages,
        callback = function()
          -- enable native neovim treesitter highlighting
          vim.treesitter.start()

          -- configure code folding
          -- • specifying bufid (second '[0]') forces setlocal behaviour
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"

          -- enable treesitter-based indentation
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
        desc = "Run treesitter",
      })
    end,
  },
}
