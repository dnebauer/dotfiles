--[[ kr40/nvim-macros : macro management ]]

-- lua plugin

return {
  {
    "kr40/nvim-macros",
    cmd = {
      "MacroSave",
      "MacroYank",
      "MacroSelect",
      "MacroDelete",
    },
    opts = {
      -- json_file_path: location where the macros will be stored
      json_file_path = vim.fs.normalize(vim.fn.stdpath("config") .. "/misc/kr40_nvim-macros/macros.json"),
      -- default_macro_register: use as default register for :Macro{Yank,Save,Select} Raw functions
      default_macro_register = "q",
      -- json_formatter: can be "none"|"jq"|"yq" used to pretty print the json file (choice must be installed!)
      json_formatter = "jq",
    },
  },
}
