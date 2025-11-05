--[[ whynothugo/lsp_lines.nvim : render diagnostics using virtual lines ]]

-- lua plugin

return {
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    init = function()
      -- enable plugin by default
      vim.diagnostic.config({
        virtual_lines = false,
        virtual_text = true,
      })
    end,
    config = function()
      -- run setup
      require("lsp_lines").setup()
      -- define toggle key and toggle command
      local function toggle_lsp_lines()
        local virtual_lines = not vim.diagnostic.config().virtual_lines
        local virtual_text = not virtual_lines
        vim.diagnostic.config({
          virtual_lines = virtual_lines,
          virtual_text = virtual_text,
        })
      end
      vim.keymap.set({ "n" }, "<Leader>tv", toggle_lsp_lines, { desc = "Toggle lsp_lines" })
      vim.api.nvim_create_user_command("LspLinesToggle", toggle_lsp_lines, { desc = "Toggle lsp_lines" })
    end,
  },
}
