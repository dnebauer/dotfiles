--[[ vim-pandoc/vim-pandoc : pandoc integration ]]

-- vim plugin
-- not part of default LazyVim

return {
  {
    "vim-pandoc/vim-pandoc",
    ft = { "markdown", "markdown.pandoc", "pandoc" },
    config = function()
      -- WARNING: unable to move variables to an "init" field/function because
      -- if g:pandoc#filetypes#handled is in "init" it somehow causes an
      -- [[E716: Key not present in Dictionary: "markdown.pandoc"]] error when
      -- executing line 97 of
      -- ~/.local/share/nvim/lazy/vim-pandoc/plugin/pandoc.vim because
      -- g:pandoc_extensions_table does not have a matching key for
      -- "markdown.pandoc"
      --
      -- utility functions
      local error_msg = function(...)
        for _, msg in ipairs({ ... }) do
          vim.api.nvim_echo({ { msg } }, false, {})
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
      check_executables({ "pandoc", "pander" }, "Cannot find the executables needed to generate output")
      -- require pandoc-crossref filter for cross-referencing
      check_executables({ "pandoc-crossref" }, "Cannot find the pandoc-crossref filter")
      -- enable pandoc functionality for markdown files
      -- while using the markdown filetype and syntax
      vim.g["pandoc#filetypes#handled"] = {
        "pandoc",
        "markdown",
        "markdown.pandoc",
      }
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
      vim.g["pandoc#keyboard#sections#header_style"] = "a"
      -- do not set shortcuts for opening hypertext links
      -- • allow other plugins to manage this
      -- • e.g., do not override shortcuts set by 'gx.nvim' plugin
      vim.g["pandoc#hypertext#use_default_mappings"] = 0
    end,
  },
}
