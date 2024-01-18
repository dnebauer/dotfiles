-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--[[ functions ]]

local option_local_get
local option_local_set

-- option_local_get(option)
---Get the value of a buffer/local option.
---@param name string Option name
---@return any _ Option value
option_local_get = function(name)
  return vim.opt_local[name]:get()
end

-- option_local_set(name, value)
---Set a buffer/local option value.
---@param name string Option name
---@param value any Value to set the option to
---@return nil _ No return value
option_local_set = function(name, value)
  vim.api.nvim_buf_set_option(0, name, value)
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
  if option_local_get("spell") then
    option_local_set("spell", false)
  else
    option_local_set("spell", true)
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
