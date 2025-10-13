--[[ neovim/nvim-lspconfig : configuration for the nvim LSP client ]]

-- lua plugin
-- part of default LazyVim

return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config.autotools_ls = {} -- autoconf, automake, make
      vim.lsp.config.bashls = {} -- bash
      vim.lsp.config.biome = {} -- json javascript typescript
      vim.lsp.config.clangd = {} -- c++ clang
      vim.lsp.config.cmake = {} -- cmake
      vim.lsp.config.dockerls = {} -- docker
      vim.lsp.config.eslint = {} -- javascript typescript
      vim.lsp.config.gopls = {} -- golang
      vim.lsp.config.grammarly = {} -- markdown
      vim.lsp.config.html = {} -- html
      vim.lsp.config.jdtls = {} -- java
      vim.lsp.config.jedi_language_server = {} -- python
      vim.lsp.config.jqls = {} -- jq
      vim.lsp.config.lemminx = {} -- xml
      vim.lsp.config.ltex = {} -- latex
      vim.lsp.config.lua_ls = {} -- lua
      vim.lsp.config.marksman = {} -- markdown
      vim.lsp.config.perlnavigator = { -- perl
        cmd = {
          "/usr/bin/node",
          "/home/david/.local/share/perlnavigator/PerlNavigator/server/out/server.js",
          "--stdio",
        },
        settings = {
          perlnavigator = {
            perlPath = "/usr/bin/perl",
            enableWarnings = true,
            perltidyEnabled = true,
            perltidyProfile = "/home/david/.perltidyrc",
            perlcriticEnabled = true,
            perlcriticProfile = "/home/david/.perlcriticrc",
          },
        },
      }
      vim.lsp.config.pylsp = {} -- python
      vim.lsp.config.raku_navigator = {} -- raku
      vim.lsp.config.rubocop = {} -- ruby
      vim.lsp.config.taplo = {} -- toml
      vim.lsp.config.vimls = {} -- vimscript
      vim.lsp.config.yamlls = {} -- yaml
      vim.lsp.config("*", {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
            -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
            -- prefix = "icons",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN] = " ",
              [vim.diagnostic.severity.HINT] = " ",
              [vim.diagnostic.severity.INFO] = " ",
            },
          },
        },
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        setup = {
          jdtls = function()
            return true -- avoid duplicate servers
          end,
        },
      })
    end,
  },
}
