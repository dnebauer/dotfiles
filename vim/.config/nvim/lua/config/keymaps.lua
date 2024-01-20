-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--[[ functions ]]

local option

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

-- [[ keymaps ]]

-- WARN: don't need { remap = false } as this
--       is the default with vim.keymap.set()

-- <CR> to replace colon
vim.keymap.set({ "n", "v" }, "<CR>", ":", { desc = "use <CR> for : [n]" })

-- save and exit mappings
-- * ZZ : save and exit
vim.keymap.set({ "i", "v" }, "ZZ", "<Esc>ZZ", { desc = "save changes and exit [i,v]" })
-- * ZQ : quit without saving
vim.keymap.set({ "i", "v" }, "ZQ", "<Esc>ZQ", { desc = "quit without saving [i,v]" })

-- space is pagedown key
vim.keymap.set({ "n", "v" }, "<Space>", "<PageDown>", { desc = "<Space> = PageDown [n,v]" })

-- toggle undo map (plugin = sjl/gundo.vim)
vim.keymap.set("n", "<Leader>u", "<Cmd>GundoToggle<CR>", { desc = "toggle undo map" })

-- force magic regex during search
vim.keymap.set({ "n", "v" }, "/", "/\\m", { desc = "force magic regex during forward search [n,v]" })
vim.keymap.set({ "n", "v" }, "?", "?\\m", { desc = "force magic regex during backward search [n,v]" })
vim.keymap.set("c", "%s/", "%s/\\m", { desc = "force magic regex during search [c]" })

-- spelling
local spell_status = function()
  local msg = { "spell checking is" }
  if vim.opt.spell:get() then
    table.insert(msg, "ON (lang = " .. table.concat(vim.opt.spelllang:get(), ",") .. ")")
  else
    table.insert(msg, "OFF")
  end
  vim.api.nvim_echo({ { table.concat(msg, " ") } }, true, {})
end
-- \st = toggle spellcheck
vim.keymap.set("n", "<Leader>st", function()
  if option("get", "spell", { scope = "local" }) then
    option("set", "spell", false, { scope = "local" })
  else
    option("set", "spell", true, { scope = "local" })
  end
  vim.api.nvim_exec2("redraw", {})
  spell_status()
end, { desc = "toggle spellcheck [n]" })
-- \ss = show spellcheck status
vim.keymap.set("n", "<Leader>ss", function()
  spell_status()
end, { desc = "show spellcheck status [n]" })
-- ]=,[= : correct next/previous bad word
vim.keymap.set("n", "]=", "]sz=", { desc = "jump to next bad word [n]" })
vim.keymap.set("n", "[=", "[sz=", { desc = "jump to previous bad word [n]" })

-- avoid accidental capitalisation of :w, :q, :e
vim.keymap.set({ "n", "v", "o" }, ":W", ":w", { desc = "prevent accidental capitalisation of ':w' [n,v,o]" })
vim.keymap.set({ "n", "v", "o" }, ":Q", ":q", { desc = "prevent accidental capitalisation of ':q' [n,v,o]" })
vim.keymap.set({ "n", "v", "o" }, ":E", ":e", { desc = "prevent accidental capitalisation of ':e' [n,v,o]" })

-- when yank visual selection stay at end of selection
vim.keymap.set("v", "y", "ygv<Esc>", { desc = "stay at end of visual selection [v]" })

-- cycle buffers with Tab, S-Tab
vim.keymap.set("n", "<Tab>", "<Cmd>bnext<CR>", { silent = true, desc = "cycle forward through tabs [n]" })
vim.keymap.set("n", "<S-Tab>", "<Cmd>bprevious<CR>", { silent = true, desc = "cycle backwards through tabs [n]" })

-- switch between alternate buffers with <BS>
vim.keymap.set("n", "<BS>", ":b#<CR>", { silent = true, desc = "switch between alternate buffers [n]" })

-- always centre cursor line vertically
--vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "centre cursor line vertically after jump [n]" })
--vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "centre cursor line vertically after jump [n]" })
--vim.keymap.set("n", "{", "{zz", { desc = "centre cursor line vertically after jump [n]" })
--vim.keymap.set("n", "}", "}zz", { desc = "centre cursor line vertically after jump [n]" })
--vim.keymap.set("n", "n", "nzz", { desc = "centre cursor line vertically after jump [n]" })
--vim.keymap.set("n", "N", "Nzz", { desc = "centre cursor line vertically after jump [n]" })
--vim.keymap.set("n", "G", "Gzz", { desc = "centre cursor line vertically after jump [n]" })
--vim.keymap.set("n", "i", "zzi", { desc = "centre current line vertically before operation [n]" })
--vim.keymap.set("n", "I", "zzI", { desc = "centre current line vertically before operation [n]" })
--vim.keymap.set("n", "o", "zzo", { desc = "centre current line vertically before operation [n]" })
--vim.keymap.set("n", "O", "zzO", { desc = "centre current line vertically before operation [n]" })
--vim.keymap.set("n", "a", "zza", { desc = "centre current line vertically before operation [n]" })
--vim.keymap.set("n", "A", "zzA", { desc = "centre current line vertically before operation [n]" })

-- move highlighted text vertically
vim.keymap.set("v", "J", ":move '>+1<CR>gv==kgvo<esc>=kgvo", { desc = "move highlighted text down" })
vim.keymap.set("v", "K", ":move '<-2<CR>gv==jgvo<esc>=jgvo", { desc = "move highlighted text up" })

-- delete whole words backwards
vim.keymap.set("i", "<C-BS>", "<Esc>cvb", { desc = "delete whole words backwards [n]" })

-- enable insert new line without losing indent if escape immediately after
-- does not work if configured to delete trailing whitespace on InsertLeave
--vim.keymap.set("n", "o", "o <BS>", { desc = "insert newline but don't lose indent" })
--vim.keymap.set("n", "O", "O <BS>", { desc = "insert newline but don't lose indent" })

-- paste over currently selected text without yanking it
vim.keymap.set("v", "p", '"_dP', { desc = "paste over visual selection without yanking it" })

-- better escape using jk in insert and terminal mode
vim.keymap.set("i", "jk", "<ESC>", { desc = "alternative escape in insert mode" })
vim.keymap.set("t", "jk", "<C-\\><C-n>", { desc = "alternative escape in terminal mode" })
