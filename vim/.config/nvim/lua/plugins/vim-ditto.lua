--[[ dbmrq/vim-ditto : highlight repeated words ]]

-- vimscript plugin

return {
  {
    "dbmrq/vim-ditto",
    keys = {
      {
        "<leader>di",
        "<Plug>ToggleDitto",
        { "n" },
        desc = "Toggle Ditto (highlight repeated words)",
      },
    },
    init = function()
      vim.g.ditto_hlgroups = { "TermCursor", "DiffAdd" }
    end,
    -- WARNING: Unable to add FileType autocmd to run 'DittoOn' command
    --          as per repo README either in "config" field here or in
    --          "autocmd.lua" -- it appears the command is not available
    --          at the time of the FileType event
  },
}
