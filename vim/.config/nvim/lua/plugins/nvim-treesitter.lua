--[[ nvim-treesitter/nvim-treesitter : interface to parsing tool treesitter ]]

local disable_function = function(lang)
  local buf_name = vim.api.nvim_buf_get_name(0)
  --vim.notify("Lang:'" .. lang .. "'")
  --if lang == "clojure" and string.find(buf_name, "conjure%-") then
  if string.find(buf_name, "msmtprc") then
    return true
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "LazyFile", "VeryLazy" },
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>", desc = "Decrement selection", mode = "x" },
    },
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      highlight = {
        enable = true,
        disable = disable_function, -- WARNING: function is not called
      },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "css",
        "diff",
        "html",
        "java",
        "javascript",
        "jq",
        "jsdoc",
        "json",
        "latex",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "perl",
        "python",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
        },
      },
    },
    ---@param opts TSConfig
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
