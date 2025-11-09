--[[ stevearc/conform.nvim : formatter plugin ]]

-- lua plugin

return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo" },
    keys = {},
    opts = function()
      -- markdown formatters:
      -- • mdformat: unable to handle yaml mdformat-frontmatter
      --             even with mdformat-frontmatter installed
      -- • markdownlint: times out, auto-deletes reference link definitions
      -- • markdownlint-cli2: as per markdownlint
      local markdown_opts = {
        "prettierd",
        "prettier",
        stop_after_first = true,
      }
      local shell_opts = { "shfmt", "shellcheck" }
      return {
        formatters_by_ft = {
          c = { "clang-format" },
          cpp = { "clang-format" },
          cmake = { "cmake_format" }, -- unavailable: cmake_format
          css = { "prettierd", "prettier", stop_after_first = true },
          go = {
            "gofmt",
            "goimports",
            "gofumpt",
            stop_after_first = true,
          }, -- unavailable: gofmt
          html = { "prettierd", "prettier", stop_after_first = true },
          javascript = {
            "prettierd",
            "prettier",
            stop_after_first = true,
          },
          javascriptreact = { "prettierd" },
          json = { "prettierd", "prettier", stop_after_first = true },
          less = { "prettierd", "prettier", stop_after_first = true },
          -- warning: lua-format collapses comment lines and removes single blank lines
          lua = {
            "stylua",
            "prettierd",
            "lua-format",
            stop_after_first = true,
          },
          markdown = markdown_opts,
          ["markdown.pandoc"] = markdown_opts,
          pandoc = markdown_opts,
          perl = { "perltidy" }, -- do NOT use 'perlimports'
          -- python = { "isort", "black" },
          -- python = function(bufnr)
          --  if require("conform").get_formatter_info("ruff_format", bufnr).available then
          --    return { "ruff_format" }
          --  else
          --    return { "isort", "black" }
          --  end
          -- end,
          python = {
            -- fix auto-fixable lint errors
            "ruff_fix", -- run the ruff formatter
            "ruff_format", -- organize the imports
            "ruff_organize_imports",
          },
          ruby = { "rubocop" },
          rust = { "rustfmt" },
          scss = { "prettierd", "prettier", stop_after_first = true },
          sh = shell_opts,
          shell = shell_opts,
          sql = { "injected", lsp_format = "last" },
          tex = { "latexindent" },
          typescript = { "prettierd" },
          typescriptreact = { "prettierd" },
          xml = { "xmlformatter", "xmllint" },
          yaml = { "prettierd", "prettier", stop_after_first = true },
          ["*"] = { "trim_whitespace" },
        },
        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        formatters = {
          clang_format = {
            command = "clang-format",
            append_args = {
              "--style={BasedOnStyle: Google, IndentWidth: 4}",
            },
          },
          injected = { options = { ignore_errors = true } },
          latexindent = {
            command = "latexindent",
            stdin = true,
            append_args = function()
              return { "-m" }
            end,
          },
        },
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_format = "fallback", -- not recommended to change
        },
        format_on_save = {
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        },
      }
    end,
  },
}
