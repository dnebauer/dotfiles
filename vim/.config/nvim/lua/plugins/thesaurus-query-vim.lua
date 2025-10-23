--[[ Ron89/thesaurus_query.vim : local and online thesaurus ]]

-- vimscript plugin

return {
  {
    "Ron89/thesaurus_query.vim",
    init = function()
      vim.g.tq_map_keys = 0
      vim.g.tq_enabled_backends = { "openoffice_en", "mthesaur_txt" }
      vim.g.tq_openoffice_en_file = "/usr/share/mythes/th_en_AU_v2"
      vim.g.tq_mthesaur_file = "/home/david/.config/nvim/thes/mthesaur.txt"
      vim.g.tq_truncation_on_syno_list_size = 200
    end,
  },
  -- attempting to add 'cmd', 'opts', or 'config' fields causes error:
  --   Failed to load `plugins.thesaurus-query-vim`
  --   .../fragments.lua:109: attempt to call method 'find' (a nil value)
}
