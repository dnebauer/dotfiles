--[[ gaoDean/autolist.nvim : automatic list continuation and formatting for neovim ]]

return {
  "gaoDean/autolist.nvim",
  ft = {
    "markdown",
    "text",
    "tex",
    "plaintex",
    "norg",
  },
  config = function()
    require("autolist").setup()

    vim.keymap.set("i", "<Tab>", "<Cmd>AutolistTab<CR>")
    vim.keymap.set("i", "<S-Tab>", "<Cmd>AutolistShiftTab<CR>")
    -- overridden by MiniPairs so put map in personal keymaps.lua to override
    --vim.keymap.set("i", "<CR>", "<CR><Cmd>AutolistNewBullet<CR>")
    -- below is attempted solution based on
    -- github.com/gaoDean/autolist.nvim/issues/77#issuecomment-1627898407
    -- but it did not work
    --[[
    vim.keymap.set("i", "<CR>", function()
      -- run autolist-new-bullet after the <cr> of nvim-autopairs-cr
      -- timeout of 0ms delays enough for my computer but u might need to adjust
      local timeoutms = 0
      vim.loop.new_timer():start(
        timeoutms,
        0,
        vim.schedule_wrap(function()
          require("autolist").new_bullet()
        end)
      )
      return require("mini.pairs").cr()
    end, { expr = true, noremap = true })
    --]]
    vim.keymap.set("n", "o", "o<Cmd>AutolistNewBullet<CR>")
    vim.keymap.set("n", "O", "O<Cmd>AutolistNewBulletBefore<CR>")
    -- conflicts with mapping <CR> to ":" in normal mode
    --vim.keymap.set("n", "<CR>", "<Cmd>AutolistToggleCheckbox<CR><CR>")
    vim.keymap.set("n", "<C-r>", "<Cmd>AutolistRecalculate<CR>")

    -- cycle list types with dot-repeat
    vim.keymap.set("n", "<leader>cn", require("autolist").cycle_next_dr, { expr = true })
    vim.keymap.set("n", "<leader>cp", require("autolist").cycle_prev_dr, { expr = true })

    -- if you don't want dot-repeat
    -- vim.keymap.set("n", "<leader>cn", "<Cmd>AutolistCycleNext<CR>")
    -- vim.keymap.set("n", "<leader>cp", "<Cmd>AutolistCycleNext<CR>")

    -- functions to recalculate list on edit
    vim.keymap.set("n", ">>", ">><Cmd>AutolistRecalculate<CR>")
    vim.keymap.set("n", "<<", "<<<Cmd>AutolistRecalculate<CR>")
    vim.keymap.set("n", "dd", "dd<Cmd>AutolistRecalculate<CR>")
    vim.keymap.set("v", "d", "d<Cmd>AutolistRecalculate<CR>")
  end,
}
