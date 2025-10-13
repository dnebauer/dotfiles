--[[ WhoIsSethDaniel/mason-tool-installer.nvim : install/upgrade 3rd party tools ]]

-- lua plugin

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- linters
        "checkmake",
        "cmakelang",
        "cmakelint",
        "dotenv-linter",
        "easy-coding-standard",
        "eslint_d",
        "flake8",
        "gitlint",
        "htmlhint",
        "jsonlint",
        "luacheck",
        "markdownlint",
        "markdownlint-cli2",
        "mypy",
        "proselint",
        "pyflakes",
        "pylint",
        "rubocop",
        "ruff",
        "shellcheck",
        "shellharden",
        "sqlfluff",
        "stylelint",
        "systemdlint",
        "textlint",
        "write-good",
        "yamllint",
        -- formatters
        "black",
        "clang-format",
        "cmakelang",
        "easy-coding-standard",
        "gofumpt",
        "goimports",
        "isort",
        "luaformatter",
        "markdownlint",
        "markdownlint-cli2",
        "mdformat",
        "prettier",
        "prettierd",
        "rubocop",
        "ruff",
        "shellharden",
        "shfmt",
        "stylua",
        "taplo",
        "xmlformatter",
      },
      -- if set to true this will check each tool for updates. If updates
      -- are available the tool will be updated. This setting does not
      -- affect :MasonToolsUpdate or :MasonToolsInstall.
      -- Default: false
      auto_update = true,

      -- automatically install / update on startup. If set to false nothing
      -- will happen on startup. You can use :MasonToolsInstall or
      -- :MasonToolsUpdate to install tools and check for updates.
      -- Default: true
      run_on_start = true,

      -- set a delay (in ms) before the installation starts. This is only
      -- effective if run_on_start is set to true.
      -- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
      -- Default: 0
      start_delay = 3000, -- 3 second delay

      -- Only attempt to install if 'debounce_hours' number of hours has
      -- elapsed since the last time Neovim was started. This stores a
      -- timestamp in a file named stdpath('data')/mason-tool-installer-debounce.
      -- This is only relevant when you are using 'run_on_start'. It has no
      -- effect when running manually via ':MasonToolsInstall' etc....
      -- Default: nil
      debounce_hours = 5, -- at least 5 hours between attempts to install/update

      -- By default all integrations are enabled. If you turn on an integration
      -- and you have the required module(s) installed this means you can use
      -- alternative names, supplied by the modules, for the thing that you want
      -- to install. If you turn off the integration (by setting it to false) you
      -- cannot use these alternative names. It also suppresses loading of those
      -- module(s) (assuming any are installed) which is sometimes wanted when
      -- doing lazy loading.
      integrations = {
        ["mason-lspconfig"] = true,
        ["mason-null-ls"] = true,
        ["mason-nvim-dap"] = true,
      },
    },
  },
}
