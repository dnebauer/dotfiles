--[[ vim-pandoc/vim-pandoc : pandoc integration ]]

return {
  {
    "vim-pandoc/vim-pandoc",
    ft = { "markdown", "markdown.pandoc", "pandoc" },
    config = function()
      -- utility functions
      local error_msg = function(...)
        for _, msg in ipairs({ ... }) do
          vim.api.nvim_err_writeln(msg)
        end
      end
      local check_executables = function(executables, msg)
        local missing_executables = {}
        for _, executable in ipairs(executables) do
          if vim.fn.executable(executable) ~= 1 then
            table.insert(missing_executables, executable)
          end
        end
        local next = next
        if next(missing_executables) ~= nil then
          error_msg(msg, "-- missing: " .. table.concat(missing_executables, ", "))
        end
      end
      -- require pandoc and pander for output generation
      check_executables({ "pandoc", "pander" }, "Cannot find all the executables needed to generate output")
      -- require pandoc-xnos filter suite for output generation
      check_executables(
        { "pandoc-eqnos", "pandoc-fignos", "pandoc-secnos", "pandoc-tablenos", "pandoc-xnos" },
        "Cannot find the entire pandoc-xnos filter suite used for cross-referencing"
      )
      -- enable pandoc functionality for markdown files
      -- while using the markdown filetype and syntax
      vim.g["pandoc#filetypes#handled"] = { "pandoc", "markdown" }
      vim.g["pandoc#filetypes#pandoc_markdown"] = 0
      -- formatting
      vim.g["pandoc#modules#enabled"] = {
        "command",
        "completion",
        "folding",
        "formatting",
        "hypertext",
        "keyboard",
        "toc",
        "yaml",
      }
      vim.g["pandoc#formatting#mode"] = "h"
      vim.g["pandoc#formatting#smart_autoformat_on_cursormoved"] = 1
      -- commands
      vim.g["pandoc#command#latex_engine"] = "xelatex"
      vim.cmd([[
        function! PandocOpen(file)
          return 'xdg-open ' . shellescape(expand(a:file,':p'))
        endfunc
      ]])
      vim.g["pandoc#command#custom_open"] = "PandocOpen"
      vim.g["pandoc#command#prefer_pdf"] = 1
      vim.g["pandoc#compiler#command"] = "pander"
      -- hashes at end as well as start of headings
      vim.g["pandoc#keyboard#sections#header_style"] = 2
    end,
  },
}
