--[[ williamboman/mason-lspconfig.nvim : bridge between mason.nvim and lspconfig plugins ]]

return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "bashls", -- bash
        "ccls", -- c/c++/objective-c
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
