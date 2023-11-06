-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opt = vim.opt
local opt_local = vim.opt_local
local api = vim.api

-- WARN: don't need { remap = false } as this
--       is the default with vim.keymap.set()

-- <CR> to replace colon
map("n", "<CR>", ":", { desc = "use <CR> for : [n]" })

-- save and exit mappings
-- * ZZ : save and exit
map({ "i", "v" }, "ZZ", "<Esc>ZZ", { desc = "save changes and exit [i,v]" })
-- * ZQ : quit without saving
map({ "i", "v" }, "ZQ", "<Esc>ZQ", { desc = "quit without saving [i,v]" })

-- space is pagedown key
map({ "n", "v" }, "<Space>", "<PageDown>", { desc = "<Space> = PageDown [n,v]" })

-- toggle undo map (plugin = sjl/gundo.vim)
map("n", "<Leader>u", "<Cmd>GundoToggle<CR>", { desc = "toggle undo map" })

-- force magic regex during search
map({ "n", "v" }, "/", "/\\m", { desc = "force magic regex during forward search [n,v]" })
map({ "n", "v" }, "?", "?\\m", { desc = "force magic regex during backward search [n,v]" })
map("c", "%s/", "%s/\\m", { desc = "force magic regex during search [c]" })

-- spelling
local spell_status = function()
  local msg = { "spell checking is" }
  if opt.spell:get() then
    table.insert(msg, "ON (lang = " .. table.concat(opt.spelllang:get(), ",") .. ")")
  else
    table.insert(msg, "OFF")
  end
  api.nvim_echo({ { table.concat(msg, " ") } }, true, {})
end
-- \st = toggle spellcheck
map("n", "<Leader>st", function()
  -- INFO: ignore "Cannot assign `boolean` to `vim.opt.spell`" error
  opt_local.spell = not (opt_local.spell:get())
  vim.cmd([[redraw]])
  spell_status()
end, { desc = "toggle spellcheck [n]" })
-- \ss = show spellcheck status
map("n", "<Leader>ss", function()
  spell_status()
end, { desc = "show spellcheck status [n]" })
-- ]=,[= : correct next/previous bad word
map("n", "]=", "]sz=", { desc = "jump to next bad word [n]" })
map("n", "[=", "[sz=", { desc = "jump to previous bad word [n]" })

-- avoid accidental capitalisation of :w, :q, :e
map({ "n", "v", "o" }, ":W", ":w", { desc = "prevent accidental capitalisation of ':w' [n,v,o]" })
map({ "n", "v", "o" }, ":Q", ":q", { desc = "prevent accidental capitalisation of ':q' [n,v,o]" })
map({ "n", "v", "o" }, ":E", ":e", { desc = "prevent accidental capitalisation of ':e' [n,v,o]" })

-- when yank visual selection stay at end of selection
map("v", "y", "ygv<Esc>", { desc = "stay at end of visual selection [v]" })

-- cycle buffers with Tab, S-Tab
map("n", "<Tab>", "<Cmd>bnext<CR>", { silent = true, desc = "cycle forward through tabs [n]" })
map("n", "<S-Tab>", "<Cmd>bprevious<CR>", { silent = true, desc = "cycle backwards through tabs [n]" })

-- switch between alternate buffers with <BS>
map("n", "<BS>", ":b#<CR>", { silent = true, desc = "switch between alternate buffers [n]" })

-- always centre cursor line vertically
--map("n", "<C-d>", "<C-d>zz", { desc = "centre cursor line vertically after jump [n]" })
--map("n", "<C-u>", "<C-u>zz", { desc = "centre cursor line vertically after jump [n]" })
--map("n", "{", "{zz", { desc = "centre cursor line vertically after jump [n]" })
--map("n", "}", "}zz", { desc = "centre cursor line vertically after jump [n]" })
--map("n", "n", "nzz", { desc = "centre cursor line vertically after jump [n]" })
--map("n", "N", "Nzz", { desc = "centre cursor line vertically after jump [n]" })
--map("n", "G", "Gzz", { desc = "centre cursor line vertically after jump [n]" })
--map("n", "i", "zzi", { desc = "centre current line vertically before operation [n]" })
--map("n", "I", "zzI", { desc = "centre current line vertically before operation [n]" })
--map("n", "o", "zzo", { desc = "centre current line vertically before operation [n]" })
--map("n", "O", "zzO", { desc = "centre current line vertically before operation [n]" })
--map("n", "a", "zza", { desc = "centre current line vertically before operation [n]" })
--map("n", "A", "zzA", { desc = "centre current line vertically before operation [n]" })

-- move highlighted text vertically
map("v", "J", ":m '>+1<CR>gv==kgvo<esc>=kgvo", { desc = "move highlighted text down" })
map("v", "K", ":m '<-2<CR>gv==jgvo<esc>=jgvo", { desc = "move highlighted text up" })

-- delete whole words backwards
map("i", "<C-BS>", "<Esc>cvb", { desc = "delete whole words backwards [n]" })

-- enable insert new line without losing indent if escape immediately after
-- does not work if configured to delete trailing whitespace on InsertLeave
map("n", "o", "o <BS>")
map("n", "O", "O <BS>")
