--[[ williamboman/mason-lspconfig.nvim : bridge between mason.nvim and lspconfig plugins ]]

return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "autotools_ls", -- autoconf, automake, make
        "bashls", -- bash
        "clangd", -- c++, clang
        "cmake", -- cmake
        "dockerls", -- docker
        "eslint", -- javascript, typescript
        "gopls", -- golang
        "grammarly", -- markdown
        "html", -- html
        "jdtls", -- java
        "jedi_language_server", -- python
        "jqls", -- jq
        "lemminx", -- xml
        "ltex", -- latex
        "lua_ls", -- lua
        "marksman", -- markdown
        "perlnavigator", -- perl
        "pylsp", -- python
        "raku_navigator", -- raku
        "rubocop", -- ruby
        "taplo", -- toml
        "vimls", -- vimscript
        "yamlls", -- yaml
      },
      --[[
      automatic_installation = {
        exclude = { "solargraph" },
      },
      --]]
    },
  },
}
