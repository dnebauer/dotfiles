--[[ dnebauer/dn-mail.nvim : mail file support ]]

-- lua plugin
-- not part of default LazyVim

return {
  {
    "dnebauer/dn-mail.nvim",
    ft = { "mail", "notmuch-compose" },
    config = function()
      require("dn-mail")
    end,
  },
}
