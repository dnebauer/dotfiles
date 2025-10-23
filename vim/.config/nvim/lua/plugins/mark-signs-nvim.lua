--[[ insanum/mark-signs.nvim : view marks in the sign column ]]

return {
  {
    "insanum/mark-signs.nvim",
    event = "VeryLazy",
    opts = {
      -- clear mappings
      -- • method "mappings = {}" from repo README.md does not work
      -- • this method is from ":h mark-sisn-mappings"
      mappings = {
        delete = false,
        set = false,
      },
    },
  },
}
