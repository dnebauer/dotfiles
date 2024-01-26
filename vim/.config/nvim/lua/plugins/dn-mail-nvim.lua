--[[ dnebauer/dn-mail.nvim : mail file support ]]

return {
  {
    "dnebauer/dn-mail.nvim",
    ft = { "mail", "notmuch-compose" },
    config = function()
      require("dn-mail")
    end,
  },
}
