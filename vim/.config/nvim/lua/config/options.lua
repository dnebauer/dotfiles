-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- functions {{{1

-- predeclare functions
local option
local var_exists
local var_set

-- option("get", name, {opts})
-- option("set|append|prepend|remove", name, value, {opts}) {{{1
---Universal function for option manipulation. There are 2 function
---signatures: one for a get operation, and another for set, append, prepend,
---and remove operations.
---
---The "get" operation returns a table for list- and map-style options, as
---per |vim.opt|. The remaining operations accept table values as per
---|vim.opt|.
---@param operation string Operation to perform (get|set|append|prepend|remove)
---@param name string Name of option to operate upon
---@param arg3 table|string|number|boolean|nil Depends on operation:
---• "get": Optional configuration dict
---• other: Value to set, append, prepend, or remove
---@param arg4 table|string|number|boolean|nil Depends on operation:
---• "get": Not used
---• other: Optional configuration dict
---
---The optional configuration dict has only 1 valid key:
---• {scope} (string): Can be "local" (behaves as `:setlocal`),
---  "global" (behaves as `:setglobal`), or
---  nil (behaves as ":set", see |set-args|)
---@return any|nil _ Depends on operation:
---• "get": Value of option
---• other: nil
option = function(operation, name, arg3, arg4)
  -- functions
  -- • check param is a non-empty string
  local _check_string_param = function(_name)
    assert(
      type(_name) == "string" and string.len(_name) > 0,
      "Expected non-empty string, got " .. type(_name) .. ": " .. tostring(_name)
    )
  end
  -- • check option name
  local _check_option_name = function(_name)
    local ok = pcall(function()
      local _ = vim.opt[name]
    end)
    assert(ok, "Invalid option name: " .. name)
  end
  -- check params
  -- • operation
  assert(type(operation) == "string", "Expected string, got " .. type(string))
  local valid_operations = { "get", "set", "append", "prepend", "remove" }
  assert(vim.tbl_contains(valid_operations, operation), "Invalid operation: " .. operation)
  -- • name
  _check_string_param(name)
  _check_option_name(name)
  -- • arg3 ('value' or 'opts')
  local opts, value = {}, nil
  local value_types = { "table", "number", "integer", "string", "boolean", "nil" }
  if operation == "get" then
    -- arg3 is 'opts'
    opts = opts or {}
    local valid_arg3_types = { "table", "nil" }
    assert(vim.tbl_contains(valid_arg3_types, type(arg3)), "Expected table, got " .. type(arg3))
    if type(arg3) == "table" then
      for key, val in ipairs(arg3) do
        opts[key] = val
      end
    end
  else
    -- arg3 is 'value'
    assert(vim.tbl_contains(value_types, type(arg3)), "Invalid option value type: " .. type(arg3))
    value = arg3
  end
  -- • arg4 ('opts' or nil)
  if vim.tbl_contains({ "set", "append", "prepend", "remove" }, operation) then
    -- arg4 is 'opts'
    opts = opts or {}
    local valid_arg4_types = { "table", "nil" }
    assert(vim.tbl_contains(valid_arg4_types, type(arg4)), "Expected table, got " .. type(arg4))
    if type(arg4) == "table" then
      for key, val in ipairs(arg4) do
        opts[key] = val
      end
    end
  end
  -- • opts
  for key, val in pairs(opts) do
    if key == "scope" then
      local valid_scopes = { "local", "global" }
      assert(type(val) == "string", "Expected string scope, got " .. type(val))
      assert(vim.tbl_contains(valid_scopes, val), "Invalid scope: " .. val)
    else
      error("Invalid configuration option: " .. key)
    end
  end
  -- get option verb
  local opt_verb = "opt"
  if opts.scope then
    opt_verb = opts.scope
  end
  -- perform operations
  if operation == "get" then
    return vim[opt_verb][name]:get()
  elseif operation == "set" then
    vim[opt_verb][name] = value
  elseif operation == "append" then
    vim[opt_verb][name]:append(value)
  elseif operation == "prepend" then
    vim[opt_verb][name]:prepend(value)
  elseif operation == "remove" then
    vim[opt_verb][name]:remove(value)
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
if vim.fn.filereadable(python2) then
  var_set("python_host_prog", python2)
end
local python3 = "/usr/bin/python3"
if vim.fn.filereadable(python3) then
  var_set("python3_host_prog", python3)
end

-- vimtex issues warning if tex_flavor not set
if var_exists("tex_flavor") then
  var_set("tex_flavor", "latex")
end

-- checkhealth recommends setting perl host (but it does not work!)
local perl = "/usr/bin/perl"
if vim.fn.filereadable(perl) then
  var_set("perl_host_prog", perl)
end

--[[ options ]]

-- colour column: managed by "ecthelionvi/NeoColumn.nvim" plugin

-- language: trust nvim language selection

-- tabs, indenting
local tab_size = 2
option("set", "tabstop", tab_size) -- number of spaces inserted by tab
option("set", "softtabstop", 0) -- do NOT insert mix of {tabs,spaces} when tab while editing
option("set", "shiftwidth", tab_size) -- number of spaces for autoindent
option("set", "expandtab", true) -- expand tabs to this many spaces
option("set", "autoindent", true) -- copy indent from current line to new
option("set", "smartindent", true) -- attempt intelligent indenting

-- encoding for new files
option("set", "fileencoding", "utf-8", { scope = "global" })

-- files to ignore when file matching
option("set", "suffixes", ".bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc")

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
option("set", "clipboard", "unnamed,unnamedplus")

-- treat all numerals as decimal
option("set", "nrformats", "")

-- save undo history in a file
option("set", "undofile", true)

-- change to file directory
option("set", "autochdir", true)

-- case sensitivity
option("set", "ignorecase", true) -- case insensitive matching if all lowercase
option("set", "smartcase", true) -- case sensitive matching if any capital letters
option("set", "infercase", true) -- intelligent case selection in autocompletion

-- 'g' flag now considered on by search/replace
-- using 'g' now toggles option off
option("set", "gdefault", true)

-- progressive match with incremental search
option("set", "incsearch", true)

-- spelling
option("set", "spell", false) -- initially spelling is off
option("set", "spelllang", "en_au")
local dictionaries = { "/usr/share/dict/words" }
for _, dict in ipairs(dictionaries) do
  if vim.fn.filereadable(dict) then
    option("remove", "dictionary", dict)
    option("append", "dictionary", dict)
  end
end
local thesauruses = { vim.fn.stdpath("config") .. "/thes/mthesaur.txt" }
for _, thes in ipairs(thesauruses) do
  if vim.fn.filereadable(thes) then
    option("remove", "thesaurus", thes)
    option("append", "thesaurus", thes)
  end
end

-- autoinsert comment headers
option("append", "formatoptions", "ro")

-- enable word wrap
option("set", "linebreak", true)

-- don't wrap words by default
option("set", "textwidth", 0)

-- don't jump to start of line after move commands
option("set", "startofline", false)

-- show matching brackets
option("set", "showmatch", true)

-- non-visible characters
--[[ ‹-› = U+2039-U+203a, single [left|right]-pointing angle quotation mark
      ★  = U+2605, black star
      »  = U+00bb, right-pointing double angle quotation mark
      «  = U+00ab, left-pointing double angle quotation mark
      •  = U+2022, bullet
--]]
option("set", "list", true)
option("set", "listchars", { tab = "‹-›", trail = "★", extends = "»", precedes = "«", nbsp = "•" })

-- vim:foldmethod=marker:
