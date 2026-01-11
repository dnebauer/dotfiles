--[[ okuuva/auto-save.nvim : event-based autosaving ]]

-- lua plugin

return {
  {
    "okuuva/auto-save.nvim",
    lazy = true,
    event = { "InsertLeave", "TextChanged" }, -- lazy load on trigger events
    opts = {
      condition = function(buf)
        -- no autosave on excluded buffer types
        local excluded_filetypes = {
          -- • useful if you use neovim as a commit message editor
          "gitcommit",
          -- • most of these are usually set to non-modifiable, which prevents
          --   autosaving by default, but it doesn't hurt to be extra safe
          "NvimTree",
          "Outline",
          "TelescopePrompt",
          "alpha",
          "dashboard",
          "lazygit",
          "neo-tree",
          "oil",
          "prompt",
          "toggleterm",
        }
        local filetype = vim.bo[buf].filetype
        if vim.tbl_contains(excluded_filetypes, filetype) then
          return false
        end
        -- no autosave on special buffers
        local buftype = vim.bo[buf].buftype
        if buftype:len() ~= 0 then
          return false
        end
        -- otherwise do autosave
        return true
      end,
    },
  },
}
