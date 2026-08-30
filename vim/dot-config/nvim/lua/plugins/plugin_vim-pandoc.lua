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
          vim.api.nvim_echo({ { msg } }, true, { err = true })
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
      -- require pandoc and my-panzer for output generation
      check_executables({ "pandoc", "my-panzer" }, "Cannot find the executables needed to generate output")
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
      vim.g["pandoc#compiler#command"] = "my-panzer"
      -- hashes at end as well as start of headings
      vim.g["pandoc#keyboard#sections#header_style"] = "a"
      -- do not set shortcuts for opening hypertext links
      -- • allow other plugins to manage this
      -- • e.g., do not override shortcuts set by 'gx.nvim' plugin
      vim.g["pandoc#hypertext#use_default_mappings"] = 0
      -- set up command to populate yaml for Letter style
      local util = require("dn-utils")
      local insert_letter_yaml = function()
        -- assemble yaml metadata line for 'date' keyword
        local raw_day = os.date("%d")
        if type(raw_day) ~= "string" then
          util.error("Unable to extract date")
          return
        end
        local day = raw_day:match("^0?(%d+)$")
        local month_year = os.date("%B %Y")
        local today = day .. " " .. month_year
        local date_yaml_line = "date: " .. today
        -- yaml metadata to insert
        -- • use list of subtables to preserve keyword order
        local letter_metadata = {
          { style = { "style: Letter" } },
          { author = { "author:", "  - David Nebauer", "  - Your Organization" } },
          { subject = { "subject: Excepteur sint occaecat cupidatat non proident" } },
          { opening = { "opening: To whom it may concern," } },
          { closing = { "closing: Yours faithfully," } },
          { date = { date_yaml_line } },
          { address = { "address:", "  - Carlton Community Centre", "  - 3376 Hyde Street", "  - CARLTON NSW 2218" } },
          {
            ["return-address"] = {
              "return-address:",
              "  - David Nebauer",
              "  - U 7 37 Charlotte St",
              "  - Fannie Bay NT 0820",
            },
          },
          { cc = { "cc:", "  - Recipient 1", "  - Recipient 2" } },
          { encl = { "encl:", "  - Enclosure 1", "  - Enclosure 2" } },
          { ps = { "ps: |", "  PS Lorem ipsum dolor sit amet, *consectetur* adipiscing elit." } },
          { fontfamily = { "fontfamily: mathpazo" } },
          { fontsize = { "fontsize: 12pt" } },
          { papersize = { "papersize: A4" } },
          { geometry = { "geometry: margin=2.5cm" } },
          { blockquote = { "blockquote: true" } },
          { letterhead = { "letterhead: example/letterhead.pdf" } },
          { signature = { "signature: example/signature.pdf" } },
          { ["signature-before"] = { "signature-before: -8ex" } },
          { ["signature-after"] = { "signature-after: 0ex" } },
          { ["closing-indentation"] = { "closing-indentation: 0pt" } },
          { ["links-as-notes"] = { "links-as-notes: true" } },
          { colorlinks = { "colorlinks: true" } },
        }
        -- get file content
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
        -- check for yaml metadata block
        if lines[1] ~= "---" then
          util.error("Can't find yaml metadata block at top of file")
          return
        end
        -- extract yaml keywords
        local found_keywords = {}
        local metadata_end_line
        for lnum, line in ipairs(lines) do
          -- match only till end of yaml
          -- • skip first line to avoid matching yaml start again
          if lnum > 1 and (line:match("^---$") or line:match("^%.%.%.$")) then
            metadata_end_line = lnum
            break
          end
          -- harvest keywords
          local keyword = line:match("^([%w_-]+):.*$")
          if keyword then
            table.insert(found_keywords, keyword)
          end
        end
        if type(metadata_end_line) == "nil" then
          util.error("Unable to find end of metadata yaml block")
          return
        end
        metadata_end_line = metadata_end_line - 1
        -- assemble missing yaml metadata
        local missing_metadata = {}
        for _, subtable in ipairs(letter_metadata) do
          for keyword, keyword_metadata in pairs(subtable) do
            if not vim.list_contains(found_keywords, keyword) then
              vim.list_extend(missing_metadata, keyword_metadata)
            end
          end
        end
        if next(missing_metadata) == nil then
          util.info("All letter metadata keywords are already present")
          return
        end
        -- insert new yaml metadata
        vim.api.nvim_buf_set_lines(0, metadata_end_line, metadata_end_line, true, missing_metadata)
      end
      vim.api.nvim_create_user_command(
        "PZLetterYAML",
        insert_letter_yaml,
        { desc = "Insert missing my-panzer Letter-related metadata" }
      )
    end,
  },
}
