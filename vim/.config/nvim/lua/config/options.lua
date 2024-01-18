-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- functions {{{1

-- predeclare functions
local fn_filereadable
local fn_stdpath
local option_append
local option_remove
local option_set
local var_exists
local var_set

-- fn_filereadable(file)
---Check whether a file is readable.
---@param file string File to check for
---@return boolean _ Whether file is readable
fn_filereadable = function(file)
  return vim.api.nvim_call_function("filereadable", { file }) ~= 0
end

-- fn_stdpath(what)
---Get paths of various default files and directories.
---@param what string The file or directory to get the path to
---@return string _ Path to file or directory
fn_stdpath = function(what)
  return vim.api.nvim_call_function("stdpath", { what })
end

-- option_append(name, value)
---Add a value to a list- or dictionary-type option.
---@param name string Option name
---@param value any Value to set option to
---@return nil _ No return value
option_append = function(name, value)
  vim.opt[name]:append(value)
end

-- option_remove(name, value)
---Remove a value from a list- or dictionary-type option.
---@param name string Option name
---@param value any Value to remove from option
---@return nil _ No return value
option_remove = function(name, value)
  vim.opt[name]:remove(value)
end

-- option_set(name, value, {opts})
---Set an option to a given value.
---@param name string Option name
---@param value any Value to set option to
---@param opts table|nil Optiona configuration parameters:
---• {scope} (string): Set to "global" or "local"
---  (optional, default = set both global and local values)
---@return nil _ No return value
option_set = function(name, value, opts)
  opts = opts or {}
  -- have to use vim.opts interface for table values
  if type(value) == "table" then
    vim.opt[name] = value
    return true
  end
  -- now handle regular values
  if opts.scope == "global" then
    vim.api.nvim_set_option(name, value)
  elseif opts.scope == "local" then
    vim.api.nvim_buf_set_option(0, name, value)
  else
    vim.api.nvim_set_option_value(name, value, {})
  end
end

-- var_exists(name)
---Determine whether a global variable exists.
---@param name string Variable to check for
---@return boolean _ Whether the variable exists
var_exists = function(name)
  local ok, _ = pcall(vim.api.nvim_get_var, name)
  return ok
end

-- var_set(name, value)
---Set a global variable to specified value.
---@param name string Name of variable
---@param value any Value to set variable to
---@return nil _ No return value
var_set = function(name, value)
  vim.api.nvim_set_var(name, value)
end
-- }}}1

--[[ mapleader ]]

var_set("mapleader", "\\")

--[[ variables ]]

-- checkhealth command recommends using g:python[3]_host_prog
local python2 = "/usr/bin/python2"
if fn_filereadable(python2) then
  var_set("python_host_prog", python2)
end
local python3 = "/usr/bin/python3"
if fn_filereadable(python3) then
  var_set("python3_host_prog", python3)
end

-- vimtex issues warning if tex_flavor not set
if var_exists("tex_flavor") then
  var_set("tex_flavor", "latex")
end

-- checkhealth recommends setting perl host (but it does not work!)
local perl = "/usr/bin/perl"
if fn_filereadable(perl) then
  var_set("perl_host_prog", perl)
end

--[[ options ]]

-- colour column: managed by "ecthelionvi/NeoColumn.nvim" plugin

-- language: trust nvim language selection

-- tabs, indenting
local tab_size = 2
option_set("tabstop", tab_size) -- number of spaces inserted by tab
option_set("softtabstop", 0) -- do NOT insert mix of {tabs,spaces} when tab while editing
option_set("shiftwidth", tab_size) -- number of spaces for autoindent
option_set("expandtab", true) -- expand tabs to this many spaces
option_set("autoindent", true) -- copy indent from current line to new
option_set("smartindent", true) -- attempt intelligent indenting

-- encoding for new files
option_set("fileencoding", "utf-8", { scope = "global" })

-- files to ignore when file matching
option_set("suffixes", ".bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc")

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
option_set("clipboard", "unnamed,unnamedplus")

-- treat all numerals as decimal
option_set("nrformats", "")

-- save undo history in a file
option_set("undofile", true)

-- change to file directory
option_set("autochdir", true)

-- case sensitivity
option_set("ignorecase", true) -- case insensitive matching if all lowercase
option_set("smartcase", true) -- case sensitive matching if any capital letters
option_set("infercase", true) -- intelligent case selection in autocompletion

-- 'g' flag now considered on by search/replace
-- using 'g' now toggles option off
option_set("gdefault", true)

-- progressive match with incremental search
option_set("incsearch", true)

-- spelling
option_set("spell", false) -- initially spelling is off
option_set("spelllang", "en_au")
local dictionaries = { "/usr/share/dict/words" }
for _, dict in ipairs(dictionaries) do
  if fn_filereadable(dict) then
    option_remove("dictionary", dict)
    option_append("dictionary", dict)
  end
end
local thesauruses = { fn_stdpath("config") .. "/thes/mthesaur.txt" }
for _, thes in ipairs(thesauruses) do
  if fn_filereadable(thes) then
    option_remove("thesaurus", thes)
    option_append("thesaurus", thes)
  end
end

-- autoinsert comment headers
option_append("formatoptions", "ro")

-- enable word wrap
option_set("linebreak", true)

-- don't wrap words by default
option_set("textwidth", 0)

-- don't jump to start of line after move commands
option_set("startofline", false)

-- show matching brackets
option_set("showmatch", true)

-- non-visible characters
--[[ ‹-› = U+2039-U+203a, single [left|right]-pointing angle quotation mark
      ★  = U+2605, black star
      »  = U+00bb, right-pointing double angle quotation mark
      «  = U+00ab, left-pointing double angle quotation mark
      •  = U+2022, bullet
--]]
option_set("list", true)
option_set("listchars", { tab = "‹-›", trail = "★", extends = "»", precedes = "«", nbsp = "•" })

-- vim:foldmethod=marker:
