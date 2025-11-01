--[[ ibhagwan/fzf-lua : fuzzy finder over lists ]]

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    config = function()
      local map = vim.keymap.set

      -- \ca :: LSP Code Actions

      map("n", "<leader>ca", function()
        require("fzf-lua").lsp_code_actions({
          winopts = { relative = "cursor", row = 1.01, col = 0, height = 0.2, width = 0.4 },
        })
      end, { desc = "Code Actions" })

      -- \cd :: Document Diagnostics

      map("n", "<leader>cd", function()
        require("fzf-lua").diagnostics_document({ fzf_opts = { ["--wrap"] = true } })
      end, { desc = "Document Diagnostics" })

      -- \cr :: LSP References

      map("n", "<leader>cr", require("fzf-lua").lsp_references, { desc = "LSP References" })

      -- \cs :: LSP Document Symbols

      map("n", "<leader>cs", function()
        require("fzf-lua").lsp_document_symbols({ winopts = { preview = { wrap = true } } })
      end, { desc = "Document Symbols" })

      -- \fb :: Buffers

      map("n", "<leader>fb", require("fzf-lua").buffers, { desc = "Buffers" })

      -- \ff :: FZF Files

      map("n", "<leader>ff", require("fzf-lua").files, { desc = "FZF Files" })

      -- \fg :: FZF Grep

      map("n", "<leader>fg", require("fzf-lua").live_grep, { desc = "FZF Grep" })

      -- \fk :: Keymaps

      map("n", "<leader>fk", require("fzf-lua").keymaps, { desc = "Keymaps" })

      -- \fm :: Marks

      map("n", "<leader>fm", require("fzf-lua").marks, { desc = "Marks" })

      -- \fr :: Registers

      map("n", "<leader>fr", require("fzf-lua").registers, { desc = "Registers" })

      -- \gc :: Browse Git Commits

      map("n", "<leader>gc", require("fzf-lua").git_bcommits, { desc = "Browse File Commits" })

      -- \gs :: Git Status

      map("n", "<leader>gs", require("fzf-lua").git_status, { desc = "Git Status" })

      -- \jd :: Jump to Definition

      map("n", "<leader>jd", require("fzf-lua").lsp_definitions, { desc = "Jump to Definition" })

      -- \rw :: Resume Work

      map("n", "<leader>rw", require("fzf-lua").resume, { desc = "Resume Work" })

      -- \sp :: Spelling Suggestions

      map("n", "<leader>sp", require("fzf-lua").spell_suggest, { desc = "Spelling Suggestions" })

      -- \sv :: Selection Grep

      map("v", "<leader>sv", require("fzf-lua").grep_visual, { desc = "Selection Grep" })

      -- \sw :: Word Grep

      map("n", "<leader>sw", require("fzf-lua").grep_cword, { desc = "Word Grep" })
    end,
  },
}
