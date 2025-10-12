--[[ neovim/nvim-lspconfig : configuration for the nvim LSP client ]]

-- lua plugin
-- part of default LazyVim

return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.autotools_ls = {} -- autoconf, automake, make
      vim.lsp.bashls = {} -- bash
      vim.lsp.biome = {} -- json javascript typescript
      vim.lsp.clangd = {} -- c++ clang
      vim.lsp.cmake = {} -- cmake
      vim.lsp.dockerls = {} -- docker
      vim.lsp.eslint = {} -- javascript typescript
      vim.lsp.gopls = {} -- golang
      vim.lsp.grammarly = {} -- markdown
      vim.lsp.html = {} -- html
      vim.lsp.jdtls = {} -- java
      vim.lsp.jedi_language_server = {} -- python
      vim.lsp.jqls = {} -- jq
      vim.lsp.lemminx = {} -- xml
      vim.lsp.ltex = {} -- latex
      vim.lsp.lua_ls = {} -- lua
      vim.lsp.marksman = {} -- markdown
      vim.lsp.perlnavigator = { -- perl
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
      vim.lsp.pylsp = {} -- python
      vim.lsp.raku_navigator = {} -- raku
      vim.lsp.rubocop = {} -- ruby
      vim.lsp.taplo = {} -- toml
      vim.lsp.vimls = {} -- vimscript
      vim.lsp.yamlls = {} -- yaml
    end,
    --[[opts = {
      servers = {
        autotools_ls = {}, -- autoconf, automake, make
        bashls = {}, -- bash
        biome = {}, -- json, javascript, typescript
        clangd = {}, -- c++, clang
        cmake = {}, -- cmake
        dockerls = {}, -- docker
        eslint = {}, -- javascript, typescript
        gopls = {}, -- golang
        grammarly = {}, -- markdown
        html = {}, -- html
        jdtls = {}, -- java
        jedi_language_server = {}, -- python
        jqls = {}, -- jq
        lemminx = {}, -- xml
        ltex = {}, -- latex
        lua_ls = {}, -- lua
        marksman = {}, -- markdown
        perlnavigator = { -- perl
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
        },
        pylsp = {}, -- python
        raku_navigator = {}, -- raku
        rubocop = {}, -- ruby
        taplo = {}, -- toml
        vimls = {}, -- vimscript
        yamlls = {}, -- yaml
      },
      --setup = {
      --  jdtls = function()
      --    return true -- avoid duplicate servers
      --  end,
      --},
    },]]
  },
}
