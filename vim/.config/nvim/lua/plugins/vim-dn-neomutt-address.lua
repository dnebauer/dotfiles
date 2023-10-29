--[[ dnebauer/vim-dn-neomutt-address : neomutt email addresses ]]

-- requires: neomutt
if not vim.fn.executable("neomutt") then
  return {}
end

-- filetypes: mail, notmuch-compose
return {
  {
    "dnebauer/vim-dn-neomutt-address",
    ft = { "mail", "notmuch-compose" },
  },
}
