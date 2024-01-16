-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

--[[ mapleader ]]

vim.g.mapleader = "\\"

--[[ variables ]]

local opt = vim.opt
local hl = vim.api.nvim_set_hl
local tab_size = 2
local python2 = "/usr/bin/python2"
local python3 = "/usr/bin/python3"
-- checkhealth command recommends using g:python[3]_host_prog
if vim.fn.filereadable(python2) == 1 then
  vim.g.python_host_prog = python2
end
if vim.fn.filereadable(python3) == 1 then
  vim.g.python3_host_prog = python3
end
-- vimtex issues warning if tex_flavor not set
if vim.fn.exists("g:tex_flavor") == 0 then
  vim.g.tex_flavor = "latex"
end
local perl_exe = "/usr/bin/perl"
if vim.fn.filereadable(perl_exe) == 1 then
  vim.g.perl_host_prog = perl_exe
end

--[[ options ]]

-- colour column: managed by "ecthelionvi/NeoColumn.nvim" plugin

-- language: trust nvim language selection

-- tabs, indenting
opt.tabstop = tab_size -- number of spaces inserted by tab
opt.softtabstop = 0 -- do NOT insert mix of {tabs,spaces} when tab while editing
opt.shiftwidth = tab_size -- number of spaces for autoindent
opt.expandtab = true -- expand tabs to this many spaces
opt.autoindent = true -- copy indent from current line to new
opt.smartindent = true -- attempt intelligent indenting

-- encoding for new files
vim.opt_global.fileencoding = "utf-8"

-- files to ignore when file matching
opt.suffixes = ".bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc"

-- clipboard
--[[
Option 'unnamedplus' uses the clipboard register "+" instead of register "*"
for all yank, delete, change and put operations which would normally go to
the unnamed register. When 'unnamed' is also included in the option, yank
and delete operations (but not put) will additionally copy the text into
register '*'.

The PRIMARY X11 selection is used by middle mouse button.
The CLIPBOARD X11 selection is used by X11 cut, copy, paste operations,
e.g., (Ctrl-c, Ctrl-v).
]]
opt.clipboard = "unnamed,unnamedplus"

-- treat all numerals as decimal
vim.g.nrformats = ""

-- save undo history in a file
opt.undofile = true

-- change to file directory
opt.autochdir = true

-- case sensitivity
opt.ignorecase = true -- case insensitive matching if all lowercase
opt.smartcase = true -- case sensitive matching if any capital letters
opt.infercase = true -- intelligent case selection in autocompletion

-- 'g' flag now considered on by search/replace
-- using 'g' now toggles option off
opt.gdefault = true

-- progressive match with incremental search
opt.incsearch = true

-- spelling
opt.spell = false -- initially spelling is off
opt.spelllang = "en_au"
local dictionaries = { "/usr/share/dict/words" }
for _, dict in ipairs(dictionaries) do
  if vim.fn.filereadable(dict) ~= 0 then
    opt.dictionary:remove(dict)
    opt.dictionary:append(dict)
  end
end
local thesauruses = { vim.fn.stdpath("config") .. "/thes/mthesaur.txt" }
for _, thes in ipairs(thesauruses) do
  if vim.fn.filereadable(thes) ~= 0 then
    opt.thesaurus:remove(thes)
    opt.thesaurus:append(thes)
  end
end

-- autoinsert comment headers
opt.formatoptions:append("ro")

-- enable word wrap
opt.linebreak = true

-- don't wrap words by default
opt.textwidth = 0

-- don't jump to start of line after move commands
opt.startofline = false

-- show matching brackets
opt.showmatch = true

-- non-visible characters
--[[ ‹-› = U+2039-U+203a, single [left|right]-pointing angle quotation mark
      ★  = U+2605, black star
      »  = U+00bb, right-pointing double angle quotation mark
      «  = U+00ab, left-pointing double angle quotation mark
      •  = U+2022, bullet
]]
opt.list = true
opt.listchars = { tab = "‹-›", trail = "★", extends = "»", precedes = "«", nbsp = "•" }
