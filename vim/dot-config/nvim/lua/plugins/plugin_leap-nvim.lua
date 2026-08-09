--[[ ggandor/leap.nvim : two-character motion plugin ]]

-- lua plugin

return {
  {
    "https://codeberg.org/andyg/leap.nvim",
    lazy = false,
    config = function()
      local leap = require("leap")
      local leap_user = require("leap.user")

      -- set s,S search keys
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)", { desc = "Leap Forward to" })
      vim.keymap.set({ "n", "x", "o" }, "S", function()
        require("leap").leap({ target_windows = { vim.fn.win_getid() } })
      end, { desc = "Leap Backward to" })

      -- exclude whitespace and the middle of alphabetic words from preview:
      --   foobar[baaz] = quux
      --   ^----^^^--^^-^-^--^
      leap.opts.preview_filter = function(ch0, ch1, ch2)
        return not (ch1:match("%s") or ch0:match("%a") and ch1:match("%a") and ch2:match("%a"))
      end

      -- define equivalence classes for brackets and quotes,
      -- in addition to the default whitespace group:
      leap.opts.equivalence_classes = { " \t\r\n" }

      -- use the traversal keys to repeat the previous motion
      -- without explicitly invoking Leap:
      leap_user.set_repeat_keys("<Enter>", "<Backspace>")

      -- enhance 1-key searching with f,F,t,T
      local function ft(key_specific_args)
        require("leap").leap(vim.tbl_deep_extend("keep", key_specific_args, {
          inputlen = 1,
          inclusive = true,
          opts = {
            -- force autojump
            labels = "",
            -- match the modes where you don't need labels (`:h mode()`)
            safe_labels = vim.fn.mode(1):match("o") and "" or nil,
          },
        }))
      end
      -- with_traversal_keys is a helper function making it easier to set
      -- "clever-f" behavior
      local clever = require("leap.user").with_traversal_keys
      local clever_f, clever_t = clever("f", "F"), clever("t", "T")
      vim.keymap.set({ "n", "x", "o" }, "f", function()
        ft({ opts = clever_f })
      end, { desc = "Clever 1-key forward search" })
      vim.keymap.set({ "n", "x", "o" }, "F", function()
        ft({ backward = true, opts = clever_f })
      end, { desc = "Clever 1-key backward search for char" })
      vim.keymap.set({ "n", "x", "o" }, "t", function()
        ft({ offset = -1, opts = clever_t })
      end, { desc = "Clever 1-key forward search till char" })
      vim.keymap.set({ "n", "x", "o" }, "T", function()
        ft({ backward = true, offset = 1, opts = clever_t })
      end, { desc = "Clever 1-key backward search till char" })
    end,
  },
}
