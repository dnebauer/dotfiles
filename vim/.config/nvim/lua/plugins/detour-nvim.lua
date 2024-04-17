--[[ carbon-steel/detour.nvim : use large popups for TUIs, scripts, commands ]]

return {
  "carbon-steel/detour.nvim",
  config = function()
    -- adapted from https://github.com/carbon-steel/detour.nvim#wrap-a-tui-top
    vim.api.nvim_create_user_command("DetourShellCommand", function(opts)
      -- Make sure Detour is available and open a Detour popup.
      local ok = require("detour").Detour()
      if not ok then
        return
      end

      -- Assemble shell command.
      local cmd = table.concat(opts.fargs, " ")

      -- Open a terminal buffer.
      -- Ensure the terminal closes when the window closes.
      vim.cmd.terminal(cmd)
      vim.bo.bufhidden = "delete"

      -- It's common for people to have `<Esc>` mapped to `<C-\><C-n>` for
      -- terminals.
      -- This can get in the way when interacting with TUIs.
      -- This maps the escape key back to itself (for this buffer) to fix this
      -- problem.
      vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = true, desc = "Reset to default behaviour" })

      -- Go into insert mode.
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
          -- This automated keypress skips for you the "[Process exited 0]"
          -- message that the embedded terminal shows.
          vim.api.nvim_feedkeys("i", "n", false)
        end,
      })
    end, { nargs = "+", complete = "shellcmd", desc = "Run shell command in Detour popup" })
  end,
}
