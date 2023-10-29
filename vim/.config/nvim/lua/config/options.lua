-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- reset mapleader from space to backslash
vim.g.mapleader = "\\"

-- checkhealth command recommends using g:python[3]_host_prog
if vim.fn.filereadable("/usr/bin/python2") == 1 then
  vim.g.python_host_prog = "/usr/bin/python2"
end
if vim.fn.filereadable("/usr/bin/python3") == 1 then
  vim.g.python3_host_prog = "/usr/bin/python3"
end
-- vimtex issues warning if tex_flavor not set
if vim.fn.exists("g:tex_flavor") == 0 then
  vim.g.tex_flavor = "latex"
end

local opt = vim.opt
--local opt_local = vim.opt_local
local hl = vim.api.nvim_set_hl

-- tabs, indenting
local tab_size = 2
opt.tabstop = tab_size -- number of spaces inserted by tab
opt.softtabstop = 0 -- do NOT insert mix of {tabs,spaces} when tab while editing
opt.shiftwidth = tab_size -- number of spaces for autoindent
opt.expandtab = true -- expand tabs to this many spaces
opt.autoindent = true -- copy indent from current line to new
opt.smartindent = true -- attempt intelligent indenting

-- colour column
opt.colorcolumn = "80"
-- * neither of the following commands works
-- * in vim highlight command works only in vimrc, and not in files called by vimrc
-- * tried both of these commands in ~/.config/nvim/init.lua but still don't work
vim.cmd([[highlight ColorColumn term=Reverse ctermbg=Yellow guibg=LightYellow]])
hl(0, "ColorColumn", {
  reverse = true,
  bg = "yellow",
  ctermbg = "yellow",
  fg = "yellow",
  ctermfg = "yellow",
})

-- encoding for new files
vim.opt_global.fileencoding = "utf-8"

-- language: trust nvim language selection

-- files to ignore when file matching
opt.suffixes = ".bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc"

-- clipboard
--[[ which X11 clipboard(s) to use:
     * PRIMARY X11 selection
       - vim visual selection (y,d,p,c,s,x, middle mouse button)
       - used in writing "* register
     * CLIPBOARD X11 selection
       - X11 cut, copy, paste (Ctrl-c, Ctrl-v)
       - used in writing "+ register
     * unnamed option
       - use "* register
       - available always in nvim
     * unnamedplus option
       - use "+ register
       - available in nvim always
]]
opt.clipboard = "unnamed,unnamedplus"

-- treat all numerals as decimal
vim.g.nrformats = ""

-- save undo history in a file
opt.undofile = true

-- case sensitivity
opt.ignorecase = true -- case insensitive matching if all lowercase
opt.smartcase = true -- case sensitive matching if any capital letters
opt.infercase = true -- intelligent case selection in autocompletion

-- act on all matches in line
-- * now if use 'g' it toggles matching to first only
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
