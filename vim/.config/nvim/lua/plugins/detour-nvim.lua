--[[ carbon-steel/detour.nvim : use large popups for TUIs, scripts, commands ]]

-- lua plugin

return {
  {
    "carbon-steel/detour.nvim",
    config = function()
      -- create command 'DetourShellCommand' that executes a given
      -- shell command in a Detour popup
      -- • adapted from https://github.com/carbon-steel/detour.nvim#wrap-a-tui-top
      vim.api.nvim_create_user_command("DetourShellCommand", function(opts)
        -- make sure Detour is available and open a Detour popup
        local ok = require("detour").Detour()
        if not ok then
          return
        end

        -- assemble shell command
        local cmd = table.concat(opts.fargs, " ")

        -- open a terminal buffer
        vim.cmd.terminal(cmd)
        -- ensure the terminal closes when the window closes
        vim.bo.bufhidden = "delete"

        -- `<esc>` is often mapped to `<c-\><c-n>` for terminals, and
        -- this can get in the way when interacting with TUIs,
        -- so map the escape key back to itself for this buffer to fix this
        vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = true, desc = "Reset to default behaviour" })

        -- go into insert mode
        --
        -- WARNING: do not go straight to insert mode!
        -- Any command that runs and exits, like "ls", will run and stop with the
        -- "[Process exited 0]" message, but then startinsert() acts like a
        -- button press and the terminal exits immediately, and the popup closes
        -- as per the TermClose autocmd below.
        --
        --vim.schedule(function()
        --  vim.cmd.startinsert()
        --end)

        vim.api.nvim_create_autocmd({ "TermClose" }, {
          buffer = vim.api.nvim_get_current_buf(),
          callback = function()
            -- this automated keypress skips for you the "[Process exited 0]"
            -- message that the embedded terminal shows
            vim.api.nvim_feedkeys("i", "n", false)
          end,
        })
      end, { nargs = "+", complete = "shellcmd", desc = "Run shell command in Detour popup" })
    end,
  },
}
