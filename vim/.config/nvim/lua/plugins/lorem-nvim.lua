--[[ derektata/lorem.nvim : generate text ]]

-- lua plugin

return {
  {
    "derektata/lorem.nvim",
    -- config field required by plugin (see ':h lorem.nvim-installation')
    -- • the 'format_defaults' field was added to satisfy LuaDiagnostics
    config = function()
      local opts = {
        comma_chance = 0.3, -- 30% chance to insert a comma
        debounce_ms = 200, -- default debounce time in milliseconds
        format_defaults = {}, -- required by LuaDiagnostics
        max_commas = 2, -- maximum 2 commas per sentence
        sentence_length = "mixed", -- using a default configuration
      }
      require("lorem").opts(opts)
    end,
  },
}
