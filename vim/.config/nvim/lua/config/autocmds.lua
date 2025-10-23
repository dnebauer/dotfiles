-- autocmds

-- plugins used:
-- • gaoDean/autolist.nvim
-- • echasnovski/mini.surround

--[[ functions ]]

local augroup_create = vim.api.nvim_create_augroup
local autocmd_create = vim.api.nvim_create_autocmd
local map = vim.keymap.set

--[[ global ]]

-- check if we need to reload the file when it has changed {{{1
autocmd_create({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup_create("my_checktime", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- resize splits if window got resized {{{1
autocmd_create({ "VimResized" }, {
  group = augroup_create("my_resize_splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- go to last loc when opening a buffer {{{1
autocmd_create("BufReadPost", {
  group = augroup_create("my_last_loc", { clear = true }),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].my_last_loc then
      return
    end
    vim.b[buf].my_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q> {{{1
autocmd_create("FileType", {
  group = augroup_create("my_close_with_q", { clear = true }),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- fix conceallevel for json files {{{1
autocmd_create({ "FileType" }, {
  group = augroup_create("my_json_conceal", { clear = true }),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- auto create dir when saving a file {{{1
-- • in case some intermediate directory does not exist
autocmd_create({ "BufWritePre" }, {
  group = augroup_create("my_auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- prolong highlight of yanked text {{{1
autocmd_create("TextYankPost", {
  group = augroup_create("my_prolong_yank_highlight", { clear = true }),
  callback = function()
    (vim.hl or vim.highlight).on_yank({ timeout = 500 })
  end,
  desc = "Prolong yanked text highlight time to 500 ms",
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
    if vim.fn.exists("b:my_checked_symlink") ~= 0 then
      return
    end
    vim.b.my_checked_symlink = 1
    -- only buffers associated with a file name (bufname ~= "")
    if vim.api.nvim_buf_get_name(0):len() == 0 then
      return
    end
    -- only check normal buffer (buftype == ""),
    local opt_buftype = vim.bo.buftype
    if opt_buftype:len() ~= 0 then
      return
    end
    -- full_fp makes use of semi-broken nature of nvim_buf_get_name():
    -- • if the file is a symlink this expands to the full symlink path
    --   (with no symlinks resolved)
    -- • if the file is real but the dirpath includes a symlink,
    --   this expands to the full true filepath (with symlinks resolved)
    local full_fp = vim.api.nvim_buf_get_name(0)
    -- real_fp is the full true filepath of init_fp, with symlinks resolved
    local real_fp = vim.uv.fs_realpath(full_fp)
    -- check whether file is a symlink
    local is_symlink = vim.uv.fs_readlink(full_fp)
    if is_symlink then
      assert(type(real_fp) == "string", "Expected string, got " .. type(real_fp))
      local file_name = vim.fn.fnamemodify(real_fp, ":t")
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

-- delete K mapping if LSP provides hover {{{1
autocmd_create("LspAttach", {
  group = augroup_create("my_delete_k_mapping", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.hoverProvider then
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
    end
  end,
  desc = "Delete K mapping if LSP provides hover",
})
-- }}}1

-- [[ filetypes ]]

-- conf {{{1
autocmd_create({ "BufRead", "BufNewFile" }, {
  group = augroup_create("my_conf_support", { clear = true }),
  pattern = "*.conf",
  callback = function()
    vim.bo.filetype = "dosini"
  end,
  desc = "Force filetype for *.conf to 'dosini' for syntax support",
})

-- gnuplot {{{1
autocmd_create({ "BufRead", "BufNewFile" }, {
  group = augroup_create("my_gnuplot_support", { clear = true }),
  pattern = "*.plt",
  callback = function()
    vim.bo.filetype = "gnuplot"
  end,
  desc = "Force filetype for *.plt to 'gnuplot' for syntax support",
})

-- json {{{1
autocmd_create("FileType", {
  group = augroup_create("my_json_support", { clear = true }),
  pattern = { "json", "jsonl", "jsonp" },
  callback = function()
    vim.wo.foldmethod = "syntax"
  end,
  desc = "Fold json files on {} and [] blocks",
})

-- markdown/pandoc {{{1
autocmd_create("FileType", {
  group = augroup_create("my_markdown_support", { clear = true }),
  pattern = { "markdown", "markdown.pandoc", "pandoc" },
  callback = function()
    -- plugin: echasnovski/mini.surround
    local opts = {
      custom_surroundings = {
        b = { output = { left = "__", right = "__" } }, -- bold (strong emphasis)
        i = { output = { left = "_", right = "_" } }, -- italic (emphasis)
        ["`"] = { output = { left = "`", right = "`" } }, -- inline code
      },
    }
    vim.b.minisurround_config = opts
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
    vim.bo.filetype = "nsis"
  end,
  desc = "Force filetype for nsis header files",
})

-- text {{{1
autocmd_create("FileType", {
  group = augroup_create("my_text_support", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown", "pandoc", "markdown.pandoc" },
  callback = function()
    -- rewrap paragraph using <M-q>, i.e., <Alt-q>
    map(
      "n",
      "<M-q>",
      '{gq}<Bar>:echo "Rewrapped paragraph"<CR>',
      { remap = false, silent = true, desc = "Rewrap paragraph" }
    )
    map("i", "<M-q>", "<Esc>{gq}<CR>a", { remap = false, silent = true, desc = "Rewrap paragraph" })
    -- turn on spelling
    vim.wo.spell = true
    -- sensible formatting
    vim.bo.formatexpr = "tqna1"
  end,
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
    vim.g.default_tiddler_tags = "[[Computing]] [[Software]]"
    -- default tiddler creator
    -- • added to tiddler when converting from 'tid' to 'tiddler' style files
    -- • using TWTidToTiddler command from tiddlywiki ftplugin
    vim.g.default_tiddler_creator = "David Nebauer"
  end,
  desc = "Support for tiddlywiki filetype",
})

-- txt2tags {{{1
autocmd_create({ "BufRead", "BufNewFile" }, {
  group = augroup_create("my_txt2tags_support", { clear = true }),
  pattern = "*.t2t",
  callback = function()
    vim.bo.filetype = "txt2tags"
  end,
  desc = "Force filetype for txt2tags syntax support",
})

-- xml {{{1
autocmd_create("FileType", {
  group = augroup_create("my_xml_support", { clear = true }),
  pattern = "xml",
  callback = function()
    vim.bo.foldmethod = "syntax"
  end,
  desc = "Support for xml files",
})
-- }}}1

-- vim:foldmethod=marker:
