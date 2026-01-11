--[[ dnebauer/dn-mail.nvim : mail file support ]]

-- lua plugin

return {
  {
    "dnebauer/dn-mail.nvim",
    ft = { "mail", "notmuch-compose" },
    opts = {}, -- required to force plugin loading
  },
}
