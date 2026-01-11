--[[ Saghen/blink.cmp : completion plugin for Neovim ]]

-- lua plugin

return {
  {
    "saghen/blink.cmp",
    version = "*",
    dependencies = {
      { "rafamadriz/friendly-snippets" },
      { "nvim-tree/nvim-web-devicons" },
      { "onsails/lspkind.nvim" },
      { "moyiz/blink-emoji.nvim" },
      { "Kaiser-Yang/blink-cmp-dictionary" },
      -- also require executables:
      -- • fzf (debian package 'fzf')
      -- • wn (debian package 'wordnet')
      -- • rustup (debian package 'rustup')
    },
    -- build command requires the nightly rust toolchain, installed with:
    --   `rustup toolchain install nightly`
    build = "cargo build --release",
    event = { "InsertEnter", "CmdlineEnter" },

    opts = {
      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        --nerd_font_variant = "mono",

        -- can override kind icons here
        --kind_icons = {
        --  Text = "󰉿",
        --  Method = "󰊕",
        --  Function = "󰊕",
        --  Constructor = "󰒓",

        --  Field = "󰜢",
        --  Variable = "󰆦",
        --  Property = "󰖷",

        --  Class = "󱡠",
        --  Interface = "󱡠",
        --  Struct = "󱡠",
        --  Module = "󰅩",

        --  Unit = "󰪚",
        --  Value = "󰦨",
        --  Enum = "󰦨",
        --  EnumMember = "󰦨",

        --  Keyword = "󰻾",
        --  Constant = "󰏿",

        --  Snippet = "󱄽",
        --  Color = "󰏘",
        --  File = "󰈔",
        --  Reference = "󰬲",
        --  Folder = "󰉋",
        --  Event = "󱐋",
        --  Operator = "󰪚",
        --  TypeParameter = "󰬛",
        --},
      },

      completion = {
        -- the below configuration does not provide an icon for
        -- 'dictionary' word completions:
        --menu = {
        --  draw = {
        --    components = {
        --      -- kind_icon taken from
        --      -- https://cmp.saghen.dev/recipes#nvim-web-devicons-lspkind
        --      kind_icon = {
        --        text = function(ctx)
        --          local icon = ctx.kind_icon
        --          if vim.tbl_contains({ "Path" }, ctx.source_name) then
        --            local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
        --            if dev_icon then
        --              icon = dev_icon
        --            end
        --          else
        --            icon = require("lspkind").symbolic(ctx.kind, {
        --              mode = "symbol",
        --            })
        --          end

        --          return icon .. ctx.icon_gap
        --        end,

        --        -- Optionally, use the highlight groups from nvim-web-devicons
        --        -- You can also add the same function for `kind.highlight` if you want to
        --        -- keep the highlight groups in sync with the icons.
        --        highlight = function(ctx)
        --          local hl = ctx.kind_hl
        --          if vim.tbl_contains({ "Path" }, ctx.source_name) then
        --            local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
        --            if dev_icon then
        --              hl = dev_hl
        --            end
        --          end
        --          return hl
        --        end,
        --      },
        --    },
        --  },
        --},
        documentation = {
          auto_show = true, -- default: false
          auto_show_delay_ms = 200, -- default: 500
        },
        ghost_text = {
          enabled = true, -- default: false
        },
      },

      fuzzy = {
        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        -- See the fuzzy documentation for more information
        implementation = "prefer_rust_with_warning", -- recommended
        -- sorts taken from
        -- https://cmp.saghen.dev/recipes#always-prioritize-exact-matches
        sorts = {
          -- default: score, sort_text
          "exact",
          "score",
          "sort_text",
        },
      },

      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = "default", -- recommended
      },

      sources = {
        -- `lsp`, `buffer`, `snippets`, `path` and `omni` are built-in
        -- so you don't need to define them in `sources.providers`
        default = { "lsp", "path", "snippets", "buffer", "emoji" },
        -- define providers per filetype
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
          markdown = { inherit_defaults = true, "dictionary" },
          ["markdown.pandoc"] = { inherit_defaults = true, "dictionary" },
          pandoc = { inherit_defaults = true, "dictionary" },
          mail = { inherit_defaults = true, "dictionary" },
          text = { inherit_defaults = true, "dictionary" },
        },
        providers = {
          emoji = {
            -- https://github.com/moyiz/blink-emoji.nvim
            -- default trigger is colon (':')
            module = "blink-emoji",
            name = "Emoji",
            score_offset = 15, -- the higher the number, the higher the priority
            min_keyword_length = 2,
            opts = {
              insert = true, -- insert emoji (default) or complete its name
            },
          },
          dictionary = {
            -- https://github.com/Kaiser-Yang/blink-cmp-dictionary
            -- for the word definitions make sure "wn" is installed
            -- • sudo aptitude install wordnet
            -- taken from https://github.com/Kaiser-Yang/blink-cmp-dictionary/issues/2
            module = "blink-cmp-dictionary",
            name = "Dict",
            score_offset = 20, -- the higher the number, the higher the priority
            enabled = true,
            max_items = 8,
            min_keyword_length = 3,
            opts = {
              -- according to https://github.com/Kaiser-Yang/blink-cmp-dictionary/issues/2:
              -- • the dictionary by default now uses fzf, make sure to have it installed
              -- • for 'dictionary_directories' specify only paths, not files
              -- • dictionary files in 'dictionary_directories' must end in .txt
              dictionary_directories = {
                vim.fn.expand("~/.config/nvim/dict/"),
              },
              -- include my 'good' words in the dictionary
              dictionary_files = {
                vim.fn.expand("~/.config/nvim/spell/en.utf-8.add"),
              },
              --  to disable the definitions uncomment this section below:
              --separate_output = function(output)
              --  local items = {}
              --  for line in output:gmatch("[^\r\n]+") do
              --    table.insert(items, {
              --      label = line,
              --      insert_text = line,
              --      documentation = nil,
              --    })
              --  end
              --  return items
              --end,
            },
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
