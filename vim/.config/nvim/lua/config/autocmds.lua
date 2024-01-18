-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

--[[ functions ]]

-- predeclare function names {{{1
local augroup_create
local autocmd_create
local mail_md_mode
local option_local_append
local option_local_get
local option_local_set
local text_editing_settings
local var_buffer_exists
local var_buffer_remove
local var_buffer_set
local var_global_set

-- augroup_create(name, {opts}) {{{1
augroup_create = vim.api.nvim_create_augroup

-- autocmd_create(event, {opts}) {{{1
autocmd_create = vim.api.nvim_create_autocmd

-- mail_md_mode(mode) {{{1
-- • format mail message body as markdown
mail_md_mode = function()
  -- only do this once
  if var_buffer_exists("mail_mode_done") then
    return
  end
  var_buffer_set("mail_mode_done", 1)
  -- define syntax group list '@synMailIncludeMarkdown'
  -- • add 'contained' flag to all syntax items in 'syntax/markdown.vim'
  -- • add top-level syntax items in 'syntax/markdown.vim' to
  --   '@synMailIncludeMarkdown' syntax group list
  var_buffer_remove("current_syntax")
  vim.api.nvim_exec2("syntax include @synMailIncludeMarkdown syntax/markdown.vim", {})
  var_buffer_set("current_syntax", "mail")
  -- apply markdown region
  --       keepend: a match with an end pattern truncates any contained
  --                matches
  --         start: markdown region starts after first empty line
  --                • '\n' is newline [see ':h /\n']
  --                • '\_^$' is empty line [see ':h /\_^', ':h /$']
  --                • '\@1<=' means:
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
  --
  -- warning: keep syntax command below enclosed in [[]] rather than "",
  --          because using "" causes the command to fail and markdown syntax
  --          is not applied
  vim.api.nvim_exec2(
    [[syntax region synMailIncludeMarkdown keepend start='\n\@1<=\_^$' end='\%$' containedin=ALL contains=@synMailIncludeMarkdown]],
    {}
  )
  -- notify user
  vim.api.nvim_echo({ { "Using markdown syntax for mail body" } }, true, {})
end

-- option_local_append(name, new_item) {{{1
option_local_append = function(name, new_item)
  vim.opt_local[name]:append(new_item)
end

-- option_local_get(option) {{{1
option_local_get = function(option)
  vim.api.nvim_buf_get_option(0, option)
end

-- option_local_set(option, value) {{{1
option_local_set = function(option, value)
  vim.api.nvim_buf_set_option(0, option, value)
end

-- text_editing_settings() {{{1
text_editing_settings = function()
  -- sentence-based text objects are more sensible
  -- plugin: preservim/vim-textobj-sentence
  vim.api.nvim_call_function("textobj#sentence#init", {})
  -- rewrap paragraph using <M-q>, i.e., <Alt-q, {})
  vim.keymap.set("n", "<M-q>", '{gq}<Bar>:echo "Rewrapped paragraph"<CR>', { remap = false, silent = true })
  vim.keymap.set("i", "<M-q>", "<Esc>{gq}<CR>a", { remap = false, silent = true })
  -- sensible formatting
  option_local_set("formatexpr", "tqna1")
  -- autolist
  vim.keymap.set("i", "<CR>", "<CR><Cmd>AutolistNewBullet<CR>")
end

-- var_buffer_exists(name) {{{1
var_buffer_exists = function(name)
  local ok, _ = pcall(vim.api.nvim_buf_get_var, 0, name)
  return ok
end

-- var_buffer_remove(name) {{{1
var_buffer_remove = function(name)
  vim.api.nvim_buf_del_var(0, name)
end

-- var_buffer_set(name, value) {{{1
var_buffer_set = function(name, value)
  vim.api.nvim_buf_set_var(0, name, value)
end

-- var_global_set(name, value)
var_global_set = function(name, value)
  vim.api.nvim_set_var(name, value)
end
-- }}}1

--[[ global ]]

-- highlight on yank {{{1
-- • increase timeout from default 150 to 500 (ms)
-- • overwrite lazvim augroup from
--   ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/config/autocmds.lua
autocmd_create("TextYankPost", {
  group = augroup_create("lazyvim_highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 500 })
  end,
  desc = "Overwrite lazyvim autocmd|augroup to increase timeout from default 150 to 500 ms",
})

-- centre current line vertically after cursor moves {{{1
autocmd_create({ "CursorMoved", "CursorMovedI" }, {
  group = augroup_create("my_vert_centre", { clear = true }),
  callback = function()
    -- use brute force to ensure cursor column does not change
    local pos = vim.api.nvim_call_function("getpos", { "." }) -- (buf, line, col, offset)
    local cursor_args = { pos[2], pos[3] }
    vim.api.nvim_exec2("normal! zz", {})
    vim.api.nvim_call_function("cursor", { cursor_args }) -- (line, column)
  end,
  desc = "Centre current line vertically after cursor moves",
})

-- remove end-of-line whitespace on save {{{1
autocmd_create("BufWritePre", {
  group = augroup_create("my_delete_ws_on_save", { clear = true }),
  callback = function()
    vim.api.nvim_exec2("%s/\\s\\+$//e", {})
  end,
  desc = "Remove trailing whitespace on buffer save",
})

-- warn on opening a symlink {{{1
autocmd_create({ "BufNewFile", "BufReadPost" }, {
  group = augroup_create("my_warn_symlink", { clear = true }),
  pattern = "*",
  callback = function()
    -- only do this once
    if var_buffer_exists("my_checked_symlink") then
      return
    end
    var_buffer_set("my_checked_symlink", 1)
    -- only buffers associated with a file name (bufname ~= "")
    if vim.api.nvim_buf_get_name(0):len() == 0 then
      return
    end
    -- only check normal buffer (buftype == ""),
    -- noting option_local_get() returns nil for an empty string
    if option_local_get("buftype") then
      return
    end
    -- full_fp makes use of semi-broken nature of nvim_buf_get_name():
    -- • if the file is a symlink this expands to the full symlink path
    --     (with no symlinks resolved)
    -- • if the file is real but the dirpath includes a symlink,
    --     this expands to the full true filepath (with symlinks resolved)
    local full_fp = vim.api.nvim_buf_get_name(0)
    -- real_fp is the full true filepath of init_fp, with symlinks resolved
    local real_fp = vim.loop.fs_realpath(full_fp)
    -- check whether file is a symlink
    local is_symlink = vim.loop.fs_readlink(full_fp)
    if is_symlink then
      local file_name = vim.api.nvim_call_function("fnamemodify", { real_fp, ":t" })
      vim.api.nvim_echo({
        { file_name .. " is a symlink:\n", "WarningMsg" },
        { "- file path = " .. full_fp .. "\n", "WarningMsg" },
        { "- real path = " .. real_fp .. "\n", "WarningMsg" },
      }, true, {})
      return
    end
  end,
  desc = "Display warning if opening a file that is a symlink",
})
-- }}}1

-- [[ filetypes ]]

-- conf {{{1
autocmd_create({ "BufRead", "BufNewFile" }, {
  group = augroup_create("my_conf_support", { clear = true }),
  pattern = "*.conf",
  callback = function()
    option_local_set("filetype", "dosini")
  end,
  desc = "Force filetype for *.conf to 'dosini' for syntax support",
})

-- gnuplot {{{1
autocmd_create({ "BufRead", "BufNewFile" }, {
  group = augroup_create("my_gnuplot_support", { clear = true }),
  pattern = "*.plt",
  callback = function()
    option_local_set("filetype", "gnuplot")
  end,
  desc = "Force filetype for *.plt to 'gnuplot' for syntax support",
})

-- json {{{1
autocmd_create("FileType", {
  group = augroup_create("my_json_support", { clear = true }),
  pattern = { "json", "jsonl", "jsonp" },
  callback = function()
    option_local_set("foldmethod", "syntax")
  end,
  desc = "Fold json files on {} and [] blocks",
})

-- mail {{{1
autocmd_create("FileType", {
  pattern = "mail",
  group = augroup_create("my_mail_support", { clear = true }),
  callback = function()
    -- re-flow text support
    -- • set parameters to be consistent with re-flowing content
    --   e.g., in neomutt setting text_flowed to true
    option_local_set("textwidth", 72)
    option_local_append("formatoptions", "q")
    option_local_append("comments", "nb:>")
    -- fold quoted text
    -- • taken from 'mutt-trim' github repo README file
    --   (https://github.com/Konfekt/mutt-trim)
    option_local_set("foldexpr", "strlen(substitute(matchstr(getline(v:lnum),'\\v^\\s*%(\\>\\s*)+'),'\\s','','g'))")
    option_local_set("foldmethod", "expr")
    option_local_set("foldlevel", 1)
    option_local_set("foldminlines", 2)
    option_local_set("colorcolumn", "72")
    -- text edit settings
    text_editing_settings()
    -- set mapping to turn on markdown highlighting in message body
    vim.keymap.set({ "n", "i" }, "<Leader>md", mail_md_mode, { buffer = 0, silent = true })
  end,
  desc = "Support for mail filetype",
})

-- markdown/pandoc {{{1
autocmd_create("FileType", {
  group = augroup_create("my_markdown_support", { clear = true }),
  pattern = { "markdown", "markdown.pandoc", "pandoc" },
  callback = function()
    -- customise plugin 'echasnovski/mini.surround'
    local opts = {
      custom_surroundings = {
        b = { output = { left = "__", right = "__" } }, -- bold (strong emphasis)
        i = { output = { left = "_", right = "_" } }, -- italic (emphasis)
        ["`"] = { output = { left = "`", right = "`" } }, -- inline code
      },
    }
    var_buffer_set("minisurround_config", opts)
    -- text edit settings
    text_editing_settings()
  end,
  desc = "Support for markdown files",
})

-- msmtprc {{{1
-- • relies on syntax file from msmtp debian package
-- • as per package README.Debian file use command:
--     sudo vim-addons -w install msmtp
--   to install the syntax file:
--     /usr/share/vim/addons/syntax/msmtp.vim
-- • symlink to it from first directory in runtimepath:
--     ~/.config/nvim/syntax/msmtp.vim
vim.filetype.add({
  filename = {
    [".msmtprc"] = "msmtp",
    ["/etc/msmtprc"] = "msmtp",
  },
})

-- nsis {{{1
autocmd_create({ "BufRead", "BufNewFile" }, {
  group = augroup_create("my_nsis_support", { clear = true }),
  pattern = "*.nsh",
  callback = function()
    option_local_set("filetype", "nsis")
  end,
  desc = "Force filetype for nsis header files",
})

-- text {{{1
autocmd_create("FileType", {
  group = augroup_create("my_text_support", { clear = true }),
  pattern = "text",
  callback = text_editing_settings,
  desc = "Support for text files",
})

-- tiddlywiki {{{1
autocmd_create("FileType", {
  group = augroup_create("my_tiddlywiki_support", { clear = true }),
  pattern = "tiddlywiki",
  callback = function()
    -- default tiddler tags
    -- • space-separated list
    -- • enclose tag names containing spaces in doubled square brackets
    -- • added to tiddler when converting from 'tid' to 'tiddler' style files
    -- • using TWTidToTiddler command from tiddlywiki ftplugin
    var_global_set("default_tiddler_tags", "[[Computing]] [[Software]]")
    -- default tiddler creator
    -- • added to tiddler when converting from 'tid' to 'tiddler' style files
    -- • using TWTidToTiddler command from tiddlywiki ftplugin
    var_global_set("default_tiddler_creator", "David Nebauer")
  end,
  desc = "Support for tiddlywiki filetype",
})

-- txt2tags {{{1
autocmd_create({ "BufRead", "BufNewFile" }, {
  group = augroup_create("my_txt2tags_support", { clear = true }),
  pattern = "*.t2t",
  callback = function()
    option_local_set("filetype", "txt2tags")
  end,
  desc = "Force filetype for txt2tags syntax support",
})

-- xml {{{1
autocmd_create("FileType", {
  group = augroup_create("my_xml_support", { clear = true }),
  pattern = "xml",
  callback = function()
    option_local_set("foldmethod", "syntax")
  end,
  desc = "Support for xml files",
})

-- }}}1

-- vim:foldmethod=marker:
