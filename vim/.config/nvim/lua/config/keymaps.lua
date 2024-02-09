-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--[[ functions ]]

-- predeclare functions {{{1
local map

-- map(mode, lhs, rhs, opts) {{{1
---Thin wrapper for |vim.keymap.set()| using the same function parameters.
---@param mode table|string Mode short name (see |nvim_set_keymap()|), can
---also be list of modes
---@param lhs string Left-hand side |{lhs}| of the mapping
---@param rhs string|function Right-hand side |{rhs}| of the mapping, can be
---a Lua function
---@param opts table|nil Table of |:map-arguments| as per |vim.keymap.set()|
---@return nil _ No return value
map = function(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
end
-- }}}1

-- [[ keymaps ]]

-- WARN: don't need { remap = false } as this
--       is the default with vim.keymap.set()

-- <CR> to replace colon
map({ "n", "v" }, "<CR>", ":", { desc = "use <CR> for : [n]" })

-- save and exit mappings
-- * ZZ : save and exit
map({ "i", "v" }, "ZZ", "<Esc>ZZ", { desc = "save changes and exit [i,v]" })
-- * ZQ : quit without saving
map({ "i", "v" }, "ZQ", "<Esc>ZQ", { desc = "quit without saving [i,v]" })

-- space is pagedown key
map({ "n", "v" }, "<Space>", "<PageDown>", { desc = "<Space> = PageDown [n,v]" })

-- expand <Esc> functionality to dismiss Noice messages as well as clear hlsearch
map(
  { "i", "n" },
  "<Esc>",
  "<Esc><Cmd>noh<CR><Cmd>NoiceDismiss<CR>",
  { desc = "Escape, clear hlsearch, dismiss Noice messages" }
)

-- toggle undo map (plugin = sjl/gundo.vim)
map("n", "<Leader>u", "<Cmd>GundoToggle<CR>", { desc = "toggle undo map" })

-- force magic regex during search
map("n", "/", "/\\m", { desc = "force magic regex during forward search [n]" })
map("v", "/", 'y/\\m<C-R>"', { desc = "force magic regex during forward search for selected text [v]" })
map("n", "?", "?\\m", { desc = "force magic regex during backward search [n]" })
map("v", "?", 'y?\\m<C-R>"', { desc = "force magic regex during backward search for selected text [v]" })
map("c", "%s/", "%s/\\m", { desc = "force magic regex during search [c]" })

-- spelling
-- • on/off/toggle with [os/]os/yos mappings from unimpaired.nvim plugin
-- • ]=,[= : correct next/previous bad word
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

-- move highlighted text vertically
map("v", "J", ":move '>+1<CR>gv==kgvo<esc>=kgvo", { desc = "move highlighted text down" })
map("v", "K", ":move '<-2<CR>gv==jgvo<esc>=jgvo", { desc = "move highlighted text up" })

-- delete whole words backwards
map("i", "<C-BS>", "<Esc>cvb", { desc = "delete whole words backwards [n]" })

-- enable insert new line without losing indent if escape immediately after
-- does not work if configured to delete trailing whitespace on InsertLeave
--map("n", "o", "o <BS>", { desc = "insert newline but don't lose indent" })
--map("n", "O", "O <BS>", { desc = "insert newline but don't lose indent" })

-- paste over currently selected text without yanking it
map("v", "p", '"_dP', { desc = "paste over visual selection without yanking it" })

-- better escape using jk in insert and terminal mode
map("i", "jk", "<ESC>", { desc = "alternative escape in insert mode" })
map("t", "jk", "<C-\\><C-n>", { desc = "alternative escape in terminal mode" })

-- use alexghergh/nvim-tmux-navigation for nvim/tmux navigation
vim.keymap.set({ "n", "t" }, "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", { silent = true })
vim.keymap.set({ "n", "t" }, "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", { silent = true })
vim.keymap.set({ "n", "t" }, "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", { silent = true })
vim.keymap.set({ "n", "t" }, "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", { silent = true })
vim.keymap.set({ "n", "t" }, "<C-\\>", "<Cmd>NvimTmuxNavigateLastActive<CR>", { silent = true })
