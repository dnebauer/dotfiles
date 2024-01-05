--[[ tris203/hawtkeys.nvim : find/suggest keys for nvim shortcuts ]]

return {
  "tris203/hawtkeys.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "Hawtkeys", "HawtkeysAll", "HawtkeysDupes" },
  -- need 'config = true' or 'config = {}' command, or
  -- you get an error like this when using a plugin command:
  -- "Command `HawtkeysAll` not found after loading `hawtkeys.nvim`"
  config = {},
}
