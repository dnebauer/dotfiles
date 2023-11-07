-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

--[[ variables ]]

local create_autocmd = vim.api.nvim_create_autocmd
local create_augroup = vim.api.nvim_create_augroup
local opt_local = vim.opt_local

--[[ functions ]]

-- mail_md_mode_X(mode) {{{1
-- * format mail message body as markdown
local mail_md_mode_X = function(mode)
  -- only do this once
  local ok, _ = pcall(vim.api.nvim_buf_get_var, 0, "mail_mode_done")
  if ok then
    return
  end
  vim.b.mail_mode_done = 1
  -- exit insert mode if necessary
  if mode == "i" then
    vim.api.nvim_input("<Esc>")
  end
  -- define syntax group list '@synMailIncludeMarkdown'
  -- * add 'contained' flag to all syntax items in 'syntax/markdown.vim'
  -- * add top-level syntax items in 'syntax/markdown.vim' to
  --   '@synMailIncludeMarkdown' syntax group list
  vim.b.current_syntax = nil
  vim.cmd([[syntax include @synMailIncludeMarkdown syntax/markdown.vim]])
  vim.b.current_syntax = "mail"
  -- apply markdown region
  --       keepend: a match with an end pattern truncates any contained
  --                matches
  --         start: markdown region starts after first empty line
  --                * '\n' is newline [see ':h /\n']
  --                * '\_^$' is empty line [see ':h /\_^', ':h /$']
  --                * '\@1<=' means:
  --                  - must still match preceding ('\n') and following
  --                    ('\_^$') atoms in sequence
  --                  - the '1' means only search backwards 1 character for
  --                    the previous match
  --                  - although the following atom is required for a match,
  --                    the match is actually deemed to end before it begins
  --                    [see ':h /zero-width']
  --           end: markdown region ends at end of file
  --   containedin: markdown region can be included in any syntax group in
  --                'mail'
  --      contains: syntax group '@synMailIncludeMarkdown' is allowed to
  --                begin inside region
  vim.cmd(
    [[syntax region synMailIncludeMarkdown keepend start='\n\@1<=\_^$' end='\%$' containedin=ALL contains=@synMailIncludeMarkdown]]
  )
  -- notify user
  vim.api.nvim_echo({ { "Using markdown syntax for mail body" } }, true, {})
  -- enter insert mode if necessary
  if mode == "i" then
    vim.api.nvim_input("a")
  end
end

local mail_md_mode_n = function()
  mail_md_mode_X("n")
end

local mail_md_mode_i = function()
  mail_md_mode_X("i")
end

-- text_editing_settings() {{{1
local text_editing_settings = function()
  -- sentence-based text objects are more sensible
  -- plugin: preservim/vim-textobj-sentence
  vim.fn["textobj#sentence#init"]()
  -- rewrap paragraph using <M-q>, i.e., <Alt-q>
  vim.keymap.set("n", "<M-q>", '{gq}<Bar>:echo "Rewrapped paragraph"<CR>', { remap = false, silent = true })
  vim.keymap.set("i", "<M-q>", "<Esc>{gq}<CR>a", { remap = false, silent = true })
end
-- }}}1

--[[ global ]]

-- highlight on yank {{{1
-- * increase timeout from default 150 to 500 (ms)
-- * overwrite lazvim augroup from
--   ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/config/autocmds.lua
create_autocmd("TextYankPost", {
  group = create_augroup("lazyvim_highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 500 })
  end,
  desc = "Overwrite lazyvim autocmd|augroup to increase timeout from default 150 to 500 ms",
})

-- centre current line vertically after cursor moves {{{1
create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  group = create_augroup("my_vert_centre", { clear = true }),
  callback = function()
    -- use brute force to ensure cursor column does not change
    local pos = vim.fn.getpos(".") -- (buf, line, col, offset)
    local cursor_args = { pos[2], pos[3] }
    vim.cmd([[ normal! zz ]])
    vim.fn.cursor(cursor_args) -- (line, column)
  end,
  desc = "Centre current line vertically after cursor moves",
})

-- remove end-of-line whitespace on save {{{1
create_autocmd("BufWritePre", {
  group = create_augroup("my_delete_ws_on_save", { clear = true }),
  callback = function()
    vim.cmd("%s/\\s\\+$//e")
  end,
  desc = "Remove trailing whitespace on buffer save",
})

-- capture initial filepath {{{1
create_autocmd({ "BufNewFile", "BufReadPost" }, {
  group = create_augroup("my_initial_filepath", { clear = true }),
  pattern = "*",
  callback = function()
    local expanded = vim.fn.expand("%")
    vim.b.my_initial_cfp = vim.fn.simplify(expanded)
  end,
  desc = "Capture initial filepath",
})

-- warn on opening a symlink {{{1
create_autocmd({ "BufNewFile", "BufReadPost" }, {
  group = create_augroup("my_warn_symlink", { clear = true }),
  pattern = "*",
  callback = function()
    -- only do this once
    if vim.fn.exists("b:my_checked_symlink") ~= 0 then
      if vim.b.my_checked_symlink == 1 then
        return
      end
    end
    vim.b.my_checked_symlink = 1
    -- only buffers associated with a file name (bufname ~= "")
    if vim.fn.bufname("%") == "" then
      return
    end -- check buffer associated with file
    -- only check normal buffer (buftype == "")
    if vim.fn.getbufvar("%", "&buftype") ~= "" then
      return
    end
    -- do simple check for whether file is a symlink
    local file_path = vim.api.nvim_buf_get_name(0)
    local file_name = vim.fn.fnamemodify(file_path, ":t")
    local real_path
    if vim.fn.getftype(file_path) == "link" then
      real_path = vim.fn.resolve(file_path)
      vim.api.nvim_echo({
        { "Buffer file is a symlink\n", "WarningMsg" },
        { "- file path: " .. file_path .. "\n", "WarningMsg" },
        { "- real path: " .. real_path .. "\n", "WarningMsg" },
      }, true, {})
      return
    end
    -- if file is not symlink, check for symlink in full file path
    -- requires b:my_initial_cfp
    -- b:my_initial_cfp is set by augroup 'my_initial_filepath'
    if vim.fn.exists("b:my_initial_cfp") ~= 0 then
      return
    end
    -- if current directory has been changed requires b:my_initial_cwd
    -- b:my_initial_cwd is set by augroup 'my_local_dir'
    file_path = ""
    if vim.fn.haslocaldir() == 1 then
      -- then initial cwd was changed with :lcd or :tcd
      if vim.fn.exists("b:my_initial_cwd") == 0 then
        return
      end
      file_path = vim.b.my_initial_cwd .. "/" .. file_name
    else
      -- initial cwd has not been altered
      file_path = vim.fn.getcwd() .. "/" .. file_name
    end
    real_path = vim.fn.resolve(file_path)
    if file_path ~= real_path then
      vim.api.nvim_echo({
        { "Buffer file path includes at least one symlink", "WarningMsg" },
        { "- file path: " .. file_path .. "\n", "WarningMsg" },
        { "- real path: " .. real_path .. "\n", "WarningMsg" },
      }, true, {})
    end
  end,
  desc = "Display warning if opening a file that is a symlink",
})

-- cd to file directory {{{1
--create_autocmd("BufEnter", {
--  group = create_augroup("my_local_dir", { clear = true }),
--  pattern = "*",
--  callback = function()
--    -- INFO: ignore following "Fields cannot be injected" warning
--    vim.b.my_initial_cwd = vim.fn.getcwd()
--    local full_path = vim.fn.expand("%:p")
--    if not string.find(full_path, "://", 1, true) then
--      vim.cmd([[lcd %:p:h]])
--    end
--  end,
--  desc = "Change to file directory",
--})

-- }}}1

-- [[ filetypes ]]

-- conf {{{1
create_autocmd({ "BufRead", "BufNewFile" }, {
  group = create_augroup("my_conf_support", { clear = true }),
  pattern = "*.conf",
  callback = function()
    opt_local.filetype = "dosini"
  end,
  desc = "Force filetype for *.conf to 'dosini' for syntax support",
})

-- gnuplot {{{1
create_autocmd({ "BufRead", "BufNewFile" }, {
  group = create_augroup("my_gnuplot_support", { clear = true }),
  pattern = "*.plt",
  callback = function()
    opt_local.filetype = "gnuplot"
  end,
  desc = "Force filetype for *.plt to 'gnuplot' for syntax support",
})

-- json {{{1
create_autocmd("FileType", {
  group = create_augroup("my_json_support", { clear = true }),
  pattern = { "json", "jsonl", "jsonp" },
  callback = function()
    opt_local.foldmethod = "syntax"
  end,
  desc = "Fold json files on {} and [] blocks",
})

-- mail {{{1
create_autocmd("FileType", {
  pattern = "mail",
  group = create_augroup("my_mail_support", { clear = true }),
  callback = function()
    -- re-flow text support
    -- * set parameters to be consistent with re-flowing content
    --   e.g., in neomutt setting text_flowed to true
    opt_local.textwidth = 72
    opt_local.formatoptions:append("q")
    opt_local.comments:append("nb:>")
    -- fold quoted text
    -- * taken from 'mutt-trim' github repo README file
    --   (https://github.com/Konfekt/mutt-trim)
    opt_local.foldexpr = "strlen(substitute(matchstr(getline(v:lnum),'\\v^\\s*%(\\>\\s*)+'),'\\s','','g'))"
    opt_local.foldmethod = "expr"
    opt_local.foldlevel = 1
    opt_local.foldminlines = 2
    opt_local.colorcolumn = "72"
    -- text edit settings
    text_editing_settings()
    -- set mapping to turn on markdown highlighting in message body
    vim.keymap.set("n", "<Leader>md", mail_md_mode_n, { buffer = 0, silent = true })
    vim.keymap.set("i", "<Leader>md", mail_md_mode_i, { buffer = 0, silent = true })
  end,
  desc = "Support for mail filetype",
})

-- markdown/pandoc {{{1
create_autocmd("FileType", {
  group = create_augroup("my_markdown_support", { clear = true }),
  pattern = { "markdown", "markdown.pandoc", "pandoc" },
  callback = function()
    -- customise plugin 'echasnovski/mini.surround'
    -- INFO: ignore error messages 'Fields cannot be injected into the reference...'
    vim.b.minisurround_config = {
      custom_surroundings = {
        b = { output = { left = "__", right = "__" } }, -- bold (strong emphasis)
        i = { output = { left = "_", right = "_" } }, -- italic (emphasis)
        ["`"] = { output = { left = "`", right = "`" } }, -- inline code
      },
    }
    -- text edit settings
    text_editing_settings()
  end,
  desc = "Support for markdown files",
})

-- msmtprc {{{1
-- * relies on syntax file from msmtp debian package
-- * as per package README.Debian file use command:
--     sudo vim-addons -w install msmtp
--   to install the syntax file:
--     /usr/share/vim/addons/syntax/msmtp.vim
-- * symlink to it from first directory in runtimepath:
--     ~/.config/nvim/syntax/msmtp.vim
create_autocmd({ "BufRead", "BufNewFile" }, {
  group = create_augroup("my_msmtp_support", { clear = true }),
  pattern = { "/etc/msmtprc", vim.fn.expand("~") .. "/.msmtprc" },
  callback = function()
    opt_local.filetype = "msmtp"
  end,
  desc = "Force filetype for msmtp config files for syntax support",
})

-- nsis {{{1
create_autocmd({ "BufRead", "BufNewFile" }, {
  group = create_augroup("my_nsis_support", { clear = true }),
  pattern = "*.nsh",
  callback = function()
    opt_local.filetype = "nsis"
  end,
  desc = "Force filetype for nsis header files",
})

-- text {{{1
create_autocmd("FileType", {
  group = create_augroup("my_text_support", { clear = true }),
  pattern = "text",
  callback = text_editing_settings,
  desc = "Support for text files",
})

-- tiddlywiki {{{1
create_autocmd("FileType", {
  group = create_augroup("my_tiddlywiki_support", { clear = true }),
  pattern = "tiddlywiki",
  callback = function()
    -- default tiddler tags
    -- * space-separated list
    -- * enclose tag names containing spaces in doubled square brackets
    -- * added to tiddler when converting from 'tid' to 'tiddler' style files
    -- * using TWTidToTiddler command from tiddlywiki ftplugin
    vim.g.default_tiddler_tags = "[[Computing]] [[Software]]"
    -- default tiddler creator
    -- * added to tiddler when converting from 'tid' to 'tiddler' style files
    -- * using TWTidToTiddler command from tiddlywiki ftplugin
    vim.g.default_tiddler_creator = "David Nebauer"
  end,
  desc = "Support for tiddlywiki filetype",
})

-- txt2tags {{{1
create_autocmd({ "BufRead", "BufNewFile" }, {
  group = create_augroup("my_txt2tags_support", { clear = true }),
  pattern = "*.t2t",
  callback = function()
    opt_local.filetype = "txt2tags"
  end,
  desc = "Force filetype for txt2tags syntax support",
})

-- xml {{{1
create_autocmd("FileType", {
  group = create_augroup("my_xml_support", { clear = true }),
  pattern = "xml",
  callback = function()
    opt_local.foldmethod = "syntax"
  end,
  desc = "Support for xml files",
})

-- }}}1

-- vim:foldmethod=marker:
