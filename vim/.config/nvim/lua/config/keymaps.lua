-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opt = vim.opt
local opt_local = vim.opt_local
local api = vim.api

-- use ; for : and vice versa
--[[ map({ "n", "v" }, ":", ";", { remap = false })
     map({ "n", "v" }, ";", ":", { remap = false })
]]

-- save and exit mappings
-- * ZZ : save and exit
map({ "i", "v" }, "ZZ", "<Esc>ZZ", { remap = false })
-- * ZQ : quit without saving
map({ "i", "v" }, "ZQ", "<Esc>ZQ", { remap = false })

-- space is pagedown key
map({ "n", "v" }, "<Space>", "<PageDown>", { remap = false })

--[[ plugin: sjl/gundo.vim ]]
-- toggle undo map
map("n", "<Leader>u", "<Cmd>GundoToggle<CR>", { remap = false })

-- force magic regex during search
map({ "n", "v" }, "/", "/\\m", { remap = false })
map({ "n", "v" }, "?", "?\\m", { remap = false })
map("c", "%s/", "%s/\\m", { remap = false })

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
end, { remap = false })
-- \ss = show spellcheck status
map("n", "<Leader>ss", function()
  spell_status()
end, { remap = false })
-- ]=,[= : correct next/previous bad word
map("n", "]=", "]sz=", { remap = false })
map("n", "[=", "[sz=", { remap = false })

-- avoid accidental capitalisation of :w, :q, :e
map({ "n", "v", "o" }, ":W", ":w")
map({ "n", "v", "o" }, ":Q", ":q")
map({ "n", "v", "o" }, ":E", ":e")
