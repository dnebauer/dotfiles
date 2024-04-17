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
map({ "n", "v" }, "<CR>", ":", { desc = "Use <CR> for ':'" })

-- save and exit mappings
-- * ZZ : save and exit
map({ "i", "v" }, "ZZ", "<Esc>ZZ", { desc = "Save changes and exit" })
-- * ZQ : quit without saving
map({ "i", "v" }, "ZQ", "<Esc>ZQ", { desc = "Quit without saving" })

-- space is pagedown key
map({ "n", "v" }, "<Space>", "<PageDown>", { desc = "Page down" })

-- expand <Esc> functionality to dismiss Noice messages as well as clear hlsearch
map(
  { "i", "n" },
  "<Esc>",
  "<Esc><Cmd>noh<CR><Cmd>NoiceDismiss<CR>",
  { desc = "Escape, clear hlsearch, dismiss Noice messages" }
)

-- toggle undo map (plugin = sjl/gundo.vim)
map("n", "<Leader>u", "<Cmd>GundoToggle<CR>", { desc = "Toggle undo map" })

-- force magic regex during search
map("n", "/", "/\\m", { desc = "Force magic regex during forward search" })
map("v", "/", 'y/\\m<C-R>"', { desc = "Force magic regex during forward search for selected text" })
map("n", "?", "?\\m", { desc = "Force magic regex during backward search" })
map("v", "?", 'y?\\m<C-R>"', { desc = "Force magic regex during backward search for selected text" })
map("c", "%s/", "%s/\\m", { desc = "Force magic regex during search" })

-- spelling
-- • on/off/toggle with [os/]os/yos mappings from unimpaired.nvim plugin
-- • ]=,[= : correct next/previous bad word
map("n", "]=", "]sz=", { desc = "Jump to next bad word" })
map("n", "[=", "[sz=", { desc = "Jump to previous bad word" })

-- avoid accidental capitalisation of :w, :q, :e
map({ "n", "v", "o" }, ":W", ":w", { desc = "Prevent accidental capitalisation of ':w'" })
map({ "n", "v", "o" }, ":Q", ":q", { desc = "Prevent accidental capitalisation of ':q'" })
map({ "n", "v", "o" }, ":E", ":e", { desc = "Prevent accidental capitalisation of ':e'" })

-- when yank visual selection stay at end of selection
map("v", "y", "ygv<Esc>", { desc = "Stay at end of visual selection" })

-- cycle buffers with Tab, S-Tab
map("n", "<Tab>", "<Cmd>bnext<CR>", { silent = true, desc = "Cycle forward through tabs" })
map("n", "<S-Tab>", "<Cmd>bprevious<CR>", { silent = true, desc = "Cycle backwards through tabs" })

-- switch between alternate buffers with <BS>
map("n", "<BS>", ":b#<CR>", { silent = true, desc = "Switch between alternate buffers" })

-- move highlighted text vertically
map("v", "J", ":move '>+1<CR>gv==kgvo<esc>=kgvo", { desc = "Move highlighted text down" })
map("v", "K", ":move '<-2<CR>gv==jgvo<esc>=jgvo", { desc = "Move highlighted text up" })

-- delete whole words backwards
map("i", "<C-BS>", "<Esc>cvb", { desc = "Delete whole words backwards" })

-- enable insert new line without losing indent if escape immediately after
-- does not work if configured to delete trailing whitespace on InsertLeave
--map("n", "o", "o <BS>", { desc = "Insert newline but don't lose indent" })
--map("n", "O", "O <BS>", { desc = "Insert newline but don't lose indent" })

-- paste over currently selected text without yanking it
map("v", "p", '"_dP', { desc = "Paste over visual selection without yanking it" })

-- better escape using jk in insert and terminal mode
map("i", "jk", "<ESC>", { desc = "Alternative escape" })
map("t", "jk", "<C-\\><C-n>", { desc = "alternative escape" })

-- use alexghergh/nvim-tmux-navigation for nvim/tmux navigation
map({ "n", "t" }, "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", { silent = true, desc = "Move left to next pane/split" })
map({ "n", "t" }, "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", { silent = true, desc = "Move down to next pane/split" })
map({ "n", "t" }, "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", { silent = true, desc = "Move up to next pane/split" })
map({ "n", "t" }, "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", { silent = true, desc = "Move right to next pane/split" })
map(
  { "n", "t" },
  "<C-\\>",
  "<Cmd>NvimTmuxNavigateLastActive<CR>",
  { silent = true, desc = "Move to previous pane/split" }
)
