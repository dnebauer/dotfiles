--[[ ggandor/leap.nvim : two-character motion plugin ]]

-- lua plugin

return {
  {
    "ggandor/leap.nvim",
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
      local function as_ft(key_specific_args)
        local common_args = {
          inputlen = 1,
          inclusive = true,
          opts = {
            labels = "", -- force autojump
            safe_labels = vim.fn.mode(1):match("[no]") and "" or nil, -- [1]
            case_sensitive = true, -- [2]
          },
        }
        return vim.tbl_deep_extend("keep", common_args, key_specific_args)
      end
      local clever = require("leap.user").with_traversal_keys -- [3]
      local key_args = {
        f = {
          args = { opts = clever("f") },
          keymap_opts = { desc = "Clever 1-key forward search" },
        },
        F = {
          args = { backward = true, opts = clever("F") },
          keymap_opts = { desc = "Clever 1-key backward search for char" },
        },
        t = {
          args = { offset = -1, opts = clever("t") },
          keymap_opts = { desc = "Clever 1-key forward search till char" },
        },
        T = {
          args = { backward = true, offset = 1, opts = clever("T") },
          keymap_opts = { desc = "Clever 1-key backward search till char" },
        },
      }
      for key, key_specific_args in pairs(key_args) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          require("leap").leap(as_ft(key_specific_args.args))
        end, key_specific_args.keymap_opts)
      end
      -- [1] Match the modes here for which you don't want to use labels
      --     (`:h mode()`, `:h lua-pattern`).
      -- [2] For 1-char search, you might want to aim for precision instead of
      --     typing comfort, to get as many direct jumps as possible.
      -- [3] This helper function makes it easier to set "clever-f"-like
      --     functionality (https://github.com/rhysd/clever-f.vim), returning
      --     an `opts` table derived from the defaults, where the given keys
      --     are added to `keys.next_target` and `keys.prev_target`
    end,
  },
}
