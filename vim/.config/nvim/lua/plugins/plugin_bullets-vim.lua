--[[ bullets-vim/bullets.vim : vim plugin for automated bullet lists ]]

-- vimscript plugin

return {
  {
    "bullets-vim/bullets.vim",
    lazy = true,
    ft = {
      "markdown",
      "markdown.pandoc",
      "pandoc",
      "text",
      "gitcommit",
      "scratch",
    },
    init = function()
      -- which filetypes the plugin will work with
      -- (default = 'markdown', 'text', 'gitcommit')
      vim.g.bullets_enabled_file_types = {
        "markdown",
        "markdown.pandoc",
        "pandoc",
        "text",
        "gitcommit",
        "scratch",
      }
      -- whether enabled in buffers with no filetype (default = true)
      vim.g.bullets_enable_in_empty_buffers = true
      -- whether to set default key mappings (default = true)
      vim.g.bullets_set_mappings = false
      -- whether to delete the last empty bullet when hitting
      -- '<cr>' in insert mode or 'o'  in normal mode (default = 1)
      --  • 2 = on first '<cr>' or 'o' decrease bullet level
      --        and on second '<cr>' delete bullet
      vim.g.bullets_delete_last_bullet_if_empty = 2
      -- line spacing between bullets: blank lines = value - 1
      -- (default = 1, i.e., no blank lines)
      vim.g.bullets_line_spacing = 1
      -- whether to right-pad text if bullets are multi-character
      -- (default = true)
      vim.g.bullets_pad_right = true
      -- whether to indent new bullets when the previous bullet text
      -- ends with a colon (default = true)
      vim.g.bullets_auto_indent_after_colon = true
      -- maximum number of alpha chars to use (default = 2)
      vim.g.bullets_max_alpha_characters = 2
      -- nested outline levels
      -- (default = 'ROM', 'ABC', 'num', 'abc', 'rom', 'std-', 'std*', 'std+')
      -- • ROM/rom = upper/lower case Roman numerals (e.g., I, II, III, IV)
      -- • ABC/abc = upper/lower case alphabetic characters (e.g., A, B, C)
      -- • std[-/*/+] = standard bullets using a hyphen (-), asterisk (*),
      --                or plus (+) as the marker
      -- • chk = checkbox (- [ ])
      vim.g.bullets_outline_levels = {}
      -- autorenumber if change indent level or insert bullet (default = true)
      vim.g.bullets_renumber_on_change = true
      -- check child checkboxes if parent checked (default = true)
      vim.g.bullets_nested_checkboxes = true
      -- checkbox markers (default = ' .oOX')
      -- • set to ' X' to disable partial markers
      vim.g.bullets_checkbox_markers = " X"
      -- whether toggling partial checkbox makes it checked or unchecked
      -- (default = true, i.e., make unchecked)
      vim.g.bullets_checkbox_partials_toggle = false
      -- whether to set default mappings (default = true)
      -- • will set manually in 'config' for maximal control
      vim.g.bullets_set_mappings = false
      -- leader key to add before default mappings (default = "")
      vim.g.bullets_mapping_leader = ""
    end,
    config = function()
      -- set key mappings
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = 0, silent = true, desc = desc })
      end
      map("i", "<cr>", "<Plug>(bullets-newline)", "Insert bullet on newline")
      map("n", "o", "<Plug>(bullets-newline)", "Insert bullet on newline")
      map("v", ">", "<Plug>(bullets-demote)", "Demote selected bullets")
      map("v", "<", "<Plug>(bullets-promote)", "Promote selected bullets")
      map("n", ">>", "<Plug>(bullets-demote)", "Demote current bullet")
      map("n", "<<", "<Plug>(bullets-promote)", "Promote current bullet")
    end,
  },
}
