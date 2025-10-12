-- keymaps

local map = vim.keymap.set

-- INFO: don't need { remap = false } as this
--       is the default with vim.keymap.set()

-- [[ general ]]

-- <cr> to replace colon
map({ "n", "v" }, "<cr>", ":", { desc = "Use <cr> for ':'" })

-- save and exit mappings
-- • ZZ : save and exit
map({ "i", "v" }, "ZZ", "<esc>ZZ", { desc = "Save changes and exit" })
-- • ZQ : quit without saving
map({ "i", "v" }, "ZQ", "<esc>ZQ", { desc = "Quit without saving" })
-- • Ctrl-s : save file
map({ "i", "x", "n", "s" }, "<c-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- space is pagedown key
map({ "n", "v" }, "<space>", "<pagedown>", { desc = "Page down" })

-- expand <esc> functionality to dismiss Noice messages as well as clear hlsearch
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("nohlsearch")
  vim.cmd("NoiceDismiss")
  return "<esc>"
end, { expr = true, desc = "Escape, clear hlsearch, dismiss Noice messages" })

-- toggle undo map (plugin = sjl/gundo.vim)
map("n", "<leader>u", "<cmd>GundoToggle<cr>", { desc = "Toggle undo map" })

-- force magic regex during search
map("n", "/", "/\\m", { desc = "Force magic regex during forward search" })
map("v", "/", 'y/\\m<c-r>"', { desc = "Force magic regex during forward search for selected text" })
map("n", "?", "?\\m", { desc = "Force magic regex during backward search" })
map("v", "?", 'y?\\m<c-r>"', { desc = "Force magic regex during backward search for selected text" })
map("c", "%s/", "%s/\\m", { desc = "Force magic regex during search" })

-- search result navigation: 'n' always forward, 'N' always backwards
-- • from <https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n>
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- spelling
-- • on/off/toggle with [os/]os/yos mappings from unimpaired.nvim plugin
-- • ]=,[= : correct next/previous bad word
map("n", "]=", "]sz=", { desc = "Jump to next bad word" })
map("n", "[=", "[sz=", { desc = "Jump to previous bad word" })

-- keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- avoid accidental capitalisation of :w, :q, :e
map({ "n", "v", "o" }, ":W", ":w", { desc = "Prevent accidental capitalisation of ':w'" })
map({ "n", "v", "o" }, ":Q", ":q", { desc = "Prevent accidental capitalisation of ':q'" })
map({ "n", "v", "o" }, ":E", ":e", { desc = "Prevent accidental capitalisation of ':e'" })

-- when yank visual selection stay at end of selection
map("v", "y", "ygv<esc>", { desc = "Stay at end of visual selection" })

-- cycle buffers with Tab, S-Tab
map("n", "<tab>", "<cmd>bnext<cr>", { silent = true, desc = "Cycle forward through tabs" })
map("n", "<s-tab>", "<cmd>bprevious<cr>", { silent = true, desc = "Cycle backwards through tabs" })

-- switch between alternate buffers with <bs>
map("n", "<bs>", ":b#<cr>", { silent = true, desc = "Switch between alternate buffers" })

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- move lines
map("n", "<a-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<a-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<a-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<a-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<a-j>", ":<c-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<a-k>", ":<c-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers
map("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })

-- move highlighted text vertically
map("v", "J", ":move '>+1<cr>gv==kgvo<esc>=kgvo", { desc = "Move highlighted text down" })
map("v", "K", ":move '<-2<cr>gv==jgvo<esc>=jgvo", { desc = "Move highlighted text up" })

-- delete whole words backwards
map("i", "<c-BS>", "<esc>cvb", { desc = "Delete whole words backwards" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- enable insert new line without losing indent if escape immediately after
-- does not work if configured to delete trailing whitespace on InsertLeave
--map("n", "o", "o <bs>", { desc = "Insert newline but don't lose indent" })
--map("n", "O", "O <bs>", { desc = "Insert newline but don't lose indent" })

-- paste over currently selected text without yanking it
map("v", "p", '"_dP', { desc = "Paste over visual selection without yanking it" })

-- better escape using jk in insert and terminal mode
map("i", "jk", "<esc>", { desc = "Alternative escape" })
map("t", "jk", "<c-\\><c-n>", { desc = "alternative escape" })

-- location list
map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })

-- quickfix list
map("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })

-- [[ tmux ]]

-- use alexghergh/nvim-tmux-navigation for nvim/tmux navigation
map({ "n", "t" }, "<c-h>", "<cmd>NvimTmuxNavigateLeft<cr>", { silent = true, desc = "Move left to next pane/split" })
map({ "n", "t" }, "<c-j>", "<cmd>NvimTmuxNavigateDown<cr>", { silent = true, desc = "Move down to next pane/split" })
map({ "n", "t" }, "<c-k>", "<cmd>NvimTmuxNavigateUp<cr>", { silent = true, desc = "Move up to next pane/split" })
map({ "n", "t" }, "<c-l>", "<cmd>NvimTmuxNavigateRight<cr>", { silent = true, desc = "Move right to next pane/split" })
map(
  { "n", "t" },
  "<c-\\>",
  "<cmd>NvimTmuxNavigateLastActive<cr>",
  { silent = true, desc = "Move to previous pane/split" }
)

-- [[ mini-surround ]]

-- mappings for nvim-mini/mini-surround
-- • remap adding surrounding to Visual mode selection
map("x", "z", ":<c-u>lua MiniSurround.add('visual')<cr>", { silent = true, desc = "Add Surrounding to Selection" })
-- • make special mapping for "add surrounding for line"
map("n", "yzz", "yz_", { remap = true, desc = "Add Surrounding for Line" })

--[[ grug-far ]]

-- trying to define within plugin file causes error:
--   "attempt to call method 'find' (a nil value)"
map({ "n", "v" }, "<leader>sr", function()
  local grug = require("grug-far")
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  grug.open({
    transient = true,
    prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
  })
end, { desc = "Search and Replace" })
