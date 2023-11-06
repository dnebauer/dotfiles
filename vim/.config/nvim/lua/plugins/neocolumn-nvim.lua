--[[ ecthelionvi/NeoColumn.nvim : display colorcolumn ]]

return {
  {
    "ecthelionvi/NeoColumn.nvim",
    opts = {
      --[[ fg_color (string):
      * foreground color of the ColorColumn as a hex code, e.g., "#FF0000"
      * default = "", in which plugin falls back to the
        foreground color of the IncSearch highlight group
      ]]
      fg_color = "",
      --[[ bg_color (string):
      * foreground color of the ColorColumn as a hex code, e.g., "#FF0000"
      * default = "", in which case the plugin falls back to the
        background color of the IncSearch highlight group
      * set to #FFFFE0 = Light Yellow
      ]]
      bg_color = "#FFFFE6",
      --[[ NeoColumn (string/table):
      * default = "80"
      * string or table
      ]]
      NeoColumn = { "80" },
      --[[ always_on (boolean):
      * whether on by default at file open
      * default = false
      * set to true
      --]]
      always_on = true,
      --[[ custom_NeoColumn (table):
      * custom ColorColumn values for specific filetypes
      * example: { ruby = "120", java = { "180", "200"} }
      * default = {}
      ]]
      custom_NeoColumn = {},
      --[[ excluded_ft (table):
      * filetypes to exclude from the ColorColumn
      * default = { "text", "markdown" }
      * set to { "lazy", "mason", "help", "netrw" }
      --]]
      excluded_ft = { "lazy", "dashboard", "mason", "help", "netrw" },
    },
  },
}
