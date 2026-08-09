--[[ preservim/vim-wordy : find usage problems ]]

-- vimscript plugin

return {
  {
    "preservim/vim-wordy",
    init = function()
      -- define ring of dictionaries to cycle through
      -- • this is the default value
      vim.g["wordy#ring"] = {
        "weak",
        { "being", "passive-voice" },
        "business-jargon",
        "weasel",
        "puffery",
        { "problematic", "redundant" },
        { "colloquial", "idiomatic", "similies" },
        "art-jargon",
        { "contractions", "opinion", "vague-time", "said-synonyms" },
        "adjectives",
        "adverbs",
      }
    end,
    config = function()
      -- ']w' and '[w' cycle between wordy dictionaries/modes
      local map = vim.keymap.set
      map({ "n", "x", "i" }, "]w", function()
        vim.cmd("NextWordy")
      end, { silent = true })
      map({ "n", "x", "i" }, "[w", function()
        vim.cmd("PrevWordy")
      end, { silent = true })
    end,
  },
}
