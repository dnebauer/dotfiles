--[[ dnebauer/dn-mail.nvim : mail file support ]]

-- lua plugin

return {
  {
    "dnebauer/dn-mail.nvim",
    ft = { "mail", "notmuch-compose" },
    opts = {}, -- required to force plugin loading
  },
  {
    -- mail body uses pandoc markdown formatting
    "dnebauer/dn-markdown.nvim",
    ft = { "mail", "notmuch-compose" },
    dependencies = { "dnebauer/dn-utils.nvim" },
    opts = {}, -- required for plugin to load
  },
}
