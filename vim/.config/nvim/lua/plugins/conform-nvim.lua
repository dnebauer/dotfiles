--[[ stevearc/conform.nvim : formatter plugin ]]

-- lua plugin
-- part of default LazyVim

return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    lazy = true,
    keys = {},
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        cmake = { "cmake_format" },
        css = { "prettierd", "prettier", stop_after_first = true },
        go = { "gofmt", "goimports", "gofumpt", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd" },
        json = { "prettierd", "prettier", stop_after_first = true },
        less = { "prettierd", "prettier", stop_after_first = true },
        lua = { "stylua", "prettierd", stop_after_first = true },
        markdown = { "mdformat", "markdownlint", "markdownlint-cli2", "prettierd", "prettier", stop_after_first = true },
        ["markdown.pandoc"] = {
          "mdformat",
          "markdownlint",
          "markdownlint-cli2",
          "prettierd",
          "prettier",
          stop_after_first = true,
        },
        pandoc = { "mdformat", "markdownlint", "markdownlint-cli2", "prettierd", "prettier", stop_after_first = true },
        perl = { "perlimports", "perltidy" },
        --[[
        python = { "isort", "black" },
        python = function(bufnr)
          if require("conform").get_formatter_info("ruff_format", bufnr).available then
            return { "ruff_format" }
          else
            return { "isort", "black" }
          end
        end,
        ]]
        python = {
          -- fix auto-fixable lint errors
          "ruff_fix",
          -- run the ruff formatter
          "ruff_format",
          -- organize the imports
          "ruff_organize_imports",
        },
        ruby = { "rubocop" },
        rust = { "rustfmt" },
        scss = { "prettierd", "prettier", stop_after_first = true },
        sh = { "shfmt", "shellcheck" },
        shell = { "shfmt", "shellcheck" },
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
          append_args = { "--style={BasedOnStyle: Google, IndentWidth: 4}" },
        },
        injected = {
          options = { ignore_errors = true },
        },
        latexindent = {
          command = "latexindent",
          stdin = true,
          append_args = function()
            return { "-m" }
          end,
        },
        prettierd = {
          condition = function()
            return vim.uv.fs_realpath(".prettierrc.js") ~= nil or vim.uv.fs_realpath(".prettierrc.mjs") ~= nil
          end,
        },
      },
      default_format_opts = {
        timeout_ms = 3000,
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_format = "fallback", -- not recommended to change
      },
    },
  },
}
