--[[ folke/snacks.nvim : collection of small QoL plugins for Neovim ]]

-- lua plugin

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    opts = {
      bigfile = {
        enabled = false,
      },
      image = {
        enabled = false,
      },
      input = {
        enabled = true,
      },
      notifier = {
        enabled = true,
      },
      picker = {
        enabled = true,
        ui_select = true,
        db = {
          -- path to the sqlite3 library
          -- debian package 'libsqlite3-0'
          sqlite3_path = "/usr/lib/x86_64-linux-gnu/libsqlite3.so.0",
        },
      },
      scope = {
        enabled = true,
      },
      scroll = {
        enabled = true,
      },
      statuscolumn = {
        enabled = false, -- we set statuscolumn in options.lua
      },
      words = {
        enabled = true,
      },
    },
  },
}
