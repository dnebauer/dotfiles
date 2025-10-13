-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- import/override with your plugins
    { import = "plugins" },
    -- ensure installed parsers are always updated to match nvim-treesitter
    { "nvim-treesitter/nvim-treesitter", branch = "master", lazy = false, build = ":TSUpdate" },
  },
  install = {
    colorscheme = {
      "tokyonight",
      --"habamax",
    },
  },
  checker = { enabled = false }, -- automatical checking for plugin updates
  ui = {
    custom_keys = {
      ["<localleader>l"] = false,
      ["<localleader>i"] = false,
      ["<localleader>t"] = false,
    },
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- have to force colorscheme because these do not work:
-- • install/colorscheme setting above
-- • adding it to the config() function of the colorscheme plugin file
vim.cmd.colorscheme("tokyonight")
