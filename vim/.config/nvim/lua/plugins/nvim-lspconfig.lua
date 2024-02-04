--[[ neovim/nvim-lspconfig : configuration for the nvim LSP client ]]

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {}, -- bash
        biome = {}, -- json, javascript, typescript
        ccls = {}, -- c/c++/objective-c
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
        taplo = {}, -- toml
        vimls = {}, -- vimscript
        yamlls = {}, -- yaml
      },
      setup = {
        jdtls = function()
          return true -- avoid duplicate servers
        end,
      },
    },
  },
}
