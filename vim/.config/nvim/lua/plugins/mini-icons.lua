--[[ nvim-mini/mini.icons : filetype icon provider ]]

-- lua plugin

return {
  {
    "nvim-mini/mini.icons",
    opts = {
      file = {
        [".chezmoiignore"] = { glyph = "", hl = "MiniIconsGrey" },
        [".chezmoiremove"] = { glyph = "", hl = "MiniIconsGrey" },
        [".chezmoiroot"] = { glyph = "", hl = "MiniIconsGrey" },
        [".chezmoiversion"] = { glyph = "", hl = "MiniIconsGrey" },
        [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        [".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
        [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
        [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
        ["bash.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        ["json.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
        ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
        ["ps1.tmpl"] = { glyph = "󰨊", hl = "MiniIconsGrey" },
        ["sh.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
        ["toml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
        ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["yaml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
        ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
        ["zsh.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
        gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
      },
    },
    config = function(_, opts)
      require("mini.icons").setup(opts)
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },
}
