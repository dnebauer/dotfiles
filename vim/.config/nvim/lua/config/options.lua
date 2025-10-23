-- options

--[[ mapleader ]]

vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

--[[ variables ]]

-- checkhealth command recommends using g:python[3]_host_prog
local python2 = "/usr/bin/python2"
if vim.fn.filereadable(python2) then
  vim.g.python_host_prog = python2
end
local python3 = "/usr/bin/python3"
if vim.fn.filereadable(python3) then
  vim.g.python3_host_prog = python3
end

-- vimtex issues warning if tex_flavor not set
if vim.fn.exists("g:tex_flavor") == 0 then
  vim.g.tex_flavor = "latex"
end

-- checkhealth recommends setting perl host
local perl = "/usr/bin/perl"
if vim.fn.filereadable(perl) then
  vim.g.perl_host_prog = perl
end

-- checkhealth recommends setting ruby host (but it does not work!)
local ruby = "/usr/local/bin/neovim-ruby-host" -- fails
--local ruby = "/usr/bin/ruby" -- fails
if vim.fn.filereadable(ruby) then
  vim.g.ruby_host_prog = ruby
end

-- snacks animations (folke/snacks.nvim)
-- set to `false` to globally disable all snacks animations
vim.g.snacks_animate = true

-- show the current document symbols location from Trouble in lualine
-- disable per buffer by setting `vim.b.trouble_lualine = false`
vim.g.trouble_lualine = true

-- fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- [[ set via functions ]]

-- diagnostic display options
vim.diagnostic.config({
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  virtual_text = {
    source = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
    texthl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
    },
  },
})

--[[ options ]]

-- colour
vim.o.termguicolors = true -- true color support (but nvim tries to use true color if present by default!)
-- • colour column: managed by "ecthelionvi/NeoColumn.nvim" plugin

-- language: trust nvim language selection

-- tabs, indenting
local tab_size = 2
vim.o.tabstop = tab_size -- number of spaces inserted by tab
vim.o.softtabstop = 0 -- do NOT insert mix of {tabs,spaces} when tab while editing
vim.o.shiftwidth = tab_size -- number of spaces for autoindent
vim.o.expandtab = true -- expand tabs to this many spaces
vim.o.autoindent = true -- copy indent from current line to new
vim.o.smartindent = true -- attempt intelligent indenting
vim.o.shiftround = true -- when changing indent with > and <, round off indent to a multiple of 'shiftwidth'

-- folding
vim.o.foldlevel = 99 -- open all folds by default (0 = close all folds)
vim.o.foldmethod = "indent" -- can also be marker/expr/manual/syntax/diff

-- line numbering
vim.o.number = true -- line number in front of (current) line
vim.o.relativenumber = true -- relative line numbers
vim.o.signcolumn = "yes" -- always show the signcolumn, otherwise it would shift the text each time

-- splits
vim.o.splitbelow = true -- put new windows below current when |:split|
vim.o.splitkeep = "screen" -- anchor current line within screen when horizontal split opens/closes/resizes
vim.o.splitright = true -- put new windows right of current when |:vsplit|
vim.o.winminwidth = 5 -- windows can't be squashed any smaller than this (default = 1)

-- mapping completion time
-- • lower than default (1000) to quickly trigger which-key
-- • unless using VSCode Neovim <http://github.com/vscode-neovim/vscode-neovim>
vim.o.timeoutlen = vim.g.vscode and 1000 or 300

-- file message behaviour
--[[
default flags:
• l = use "999L, 888B" instead of 999 lines, 888 bytes""
• t = if file message too long for line, truncate at start
• T = if non-file message too long for line, truncate in middle
• o = if file read message follows file write message, it overwrites
• O = file read message overwrites any previous message
• C = suppress messages while scanning for |ins-completion| items
• F = suppress file info when editing file
added flags:
• W = suppress "written" or "[w]" messages on file write
• I = suppress intro message at vim startup
• c = suppress |ins-completion-menu| messages
• C = suppress messages while scanning for |ins-completion| items
]]
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- status line
vim.o.statuscolumn = "" -- appears to have no effect on left side of screen
vim.o.laststatus = 3 -- global statusline
vim.o.ruler = false -- disable the default ruler (because statusline plugin)
vim.o.showmode = false -- dont show mode since we have a statusline

-- cursor and current line
vim.o.cursorline = true -- enable highlighting of the current line
vim.o.scrolloff = 4 -- lines of context kept above/below cursor
vim.o.sidescrolloff = 8 -- columns of context kept to left/right of cursor
vim.opt.virtualedit = { "block" } -- allow cursor to move where there is no text in visual block mode

-- popups
vim.opt.completeopt = { "menu", "menuone" } -- popup with default selection
--[[ when doing completion in command-line (with Tab or Ctrl-d):
• longest:full = complete to longest common string, and start 'wildmenu'
• full = complete the next full match, and start 'wildmenu'
]]
vim.opt.wildmode = { "longest:full", "full" }
vim.o.pumblend = 10 -- make popups pseudo-transparent
vim.o.pumheight = 0 -- popups use available screen space

-- save behaviour
vim.o.autowrite = true -- write file automatically on buffer switch
vim.o.confirm = true -- confirm to save changes before exiting modified buffer
vim.o.updatetime = 200 -- save swap file and trigger CursorHold quickly (default = 4000)

-- mouse
vim.o.mouse = "a" -- enable mouse mode

-- encoding for new files
vim.go.fileencoding = "utf-8"

-- |:mksession| command
vim.opt.sessionoptions = {
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
  "help",
  "globals",
  "skiprtp",
  "folds",
}

-- fill characters
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- files to ignore when file matching
vim.opt.suffixes = {
  ".bak",
  "~",
  ".swp",
  ".o",
  ".info",
  ".aux",
  ".log",
  ".dvi",
  ".bbl",
  ".blg",
  ".brf",
  ".cb",
  ".ind",
  ".idx",
  ".ilg",
  ".inx",
  ".out",
  ".toc",
}

--[[
clipboard:
• option 'unnamedplus' uses the clipboard register "+" instead of register "*"
  for all yank, delete, change and put operations which would normally go to
  the unnamed register
• when 'unnamed' is also included in the option, yank and delete operations
  (but not put) will additionally copy the text into register '*'
• PRIMARY X11 selection is used by middle mouse button
• CLIPBOARD X11 selection is used by X11 cut, copy, paste operations,
  e.g., (Ctrl-c, Ctrl-v) or (Ctrl-Shift-c, Ctrl-Shift-v)
]]
vim.opt.clipboard = { "unnamed", "unnamedplus" }

-- treat all numerals as decimal
vim.o.nrformats = ""

-- undo
vim.o.undofile = true -- save undo history in a file
vim.o.undolevels = 2000 -- default setting = 1000, LazyVim setting = 10000

-- change to file directory
vim.o.autochdir = true

-- search/replace (also see 'case sensitivity' below)
vim.o.gdefault = true -- 'g' flag considered on (using 'g' now toggles option off)
vim.o.incsearch = true -- progressive match with incremental search
vim.o.grepformat = "%f:%l:%c:%m" -- default for ripgrep
vim.o.inccommand = "nosplit" -- preview incremental substitute

-- case sensitivity
vim.o.ignorecase = true -- case insensitive matching if all lowercase
vim.o.smartcase = true -- case sensitive matching if any capital letters
vim.o.infercase = true -- intelligent case selection in autocompletion

-- spelling
vim.o.spell = false -- initially spelling is off
vim.opt.spelllang = { "en_au" }
local dictionaries = { "/usr/share/dict/words" }
for _, dict in ipairs(dictionaries) do
  if vim.fn.filereadable(dict) then
    vim.opt.dictionary:append(dict)
  end
end
local thesauruses = { vim.fn.stdpath("config") .. "/thes/mthesaur.txt" }
for _, thes in ipairs(thesauruses) do
  if vim.fn.filereadable(thes) then
    vim.opt.thesaurus:append(thes)
  end
end

-- wrapping
vim.o.wrap = false -- disable line wrap
vim.o.linebreak = true -- wrap virtually at a break character (newline NOT inserted)
vim.o.textwidth = 0 -- do not break line on text insertion to enforce width maximum
vim.o.smoothscroll = true -- signal if part of first line is beyond top of screen (due to wrapping)
--[[ formatoptions:
• j = remove comment leader when joining lines
• c = auto-wrap comments
• r = auto-insert comment-leader on pressing Enter
• o = auto-insert comment-leader on pressing 'o' or 'O'
• q = allow formatting of comments with 'gq'
• l = do not break long lines in insert mode
• n = recognise numbered list when formatting text
• t = auto-wrap text
]]
vim.opt.formatoptions = "jcroqlnt"

-- jumps
vim.o.jumpoptions = "view" -- restore view at mark
vim.o.startofline = false -- don't jump to start of line after move commands

-- show matching brackets
vim.o.showmatch = true

-- handle non-visible characters
--[[
‹-› = U+2039-U+203a, single [left|right]-pointing angle quotation mark
 ★  = U+2605, black star
 »  = U+00bb, right-pointing double angle quotation mark
 «  = U+00ab, left-pointing double angle quotation mark
 •  = U+2022, bullet
]]
vim.o.list = true -- use symbols to show different kinds of spaces (modified by 'listchars')
vim.opt.listchars = {
  tab = "‹-›",
  trail = "★",
  extends = "»",
  precedes = "«",
  nbsp = "•",
}
vim.o.conceallevel = 2 -- hide * markup for bold and italic, but not markers with substitutions

-- vim:foldmethod=marker:
