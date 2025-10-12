--[[ ggandor/leap.nvim : two-character motion plugin ]]

-- lua plugin
-- part of default LazyVim

return {
  {
    "ggandor/leap.nvim",
    enabled = true,
    keys = {
      { "s", "<Plug>(leap)", mode = { "n", "x", "o" }, desc = "Leap Forward to" },
      { "S", "<Plug>(leap-from-window)", mode = { "n", "x", "o" }, desc = "Leap Backward to" },
    },
    opts = {},
    config = function(_, opts)
      local leap = require("leap")
      -- process option
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      -- exclude whitespace and the middle of alphabetic words from preview:
      --   foobar[baaz] = quux
      --   ^----^^^--^^-^-^--^
      leap.opts.preview_filter = function(ch0, ch1, ch2)
        return not (ch1:match("%s") or ch0:match("%a") and ch1:match("%a") and ch2:match("%a"))
      end
      -- define equivalence classes for brackets and quotes,
      -- in addition to the default whitespace group:
      leap.opts.equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" }
      -- use the traversal keys to repeat the previous motion
      -- without explicitly invoking Leap:
      leap.user.set_repeat_keys("<Enter>", "<Backspace>")
    end,
  },
}
