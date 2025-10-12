--[[ MagicDuck/grug-far.nvim : find and replace for neovim ]]

-- lua plugin
-- part of default LazyVim

-- the oil.nvim plugin config uses grug-far

return {
  { "MagicDuck/grug-far.nvim" },
  -- WARN: any attempt to configure (see below) triggers error
  --   "attempt to call method 'find' (a nil value)"
  --opts = { headerMaxWidth = 80 },
  --cmd = { "GrugFar", "GrugFarWithin" },
  -- key mapping defined in config file 'autocmd.lua'
  --keys = {
  --  {
  --    "<leader>sr",
  --    function()
  --      local grug = require("grug-far")
  --      local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  --      grug.open({
  --        transient = true,
  --        prefills = {
  --          filesFilter = ext and ext ~= "" and "*." .. ext or nil,
  --        },
  --      })
  --    end,
  --    mode = { "n", "v" },
  --    desc = "Search and Replace",
  --  },
  --},
}
