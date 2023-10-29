--[[ godlygeek/tabular : align text ]]

return {
  {
    "godlygeek/tabular",

    -- utility error function
    config = function()
      local error_no_tabularize_cmd = function()
        vim.api.nvim_err_writeln("Cannot find the 'Tabularize' command - is the 'tabular' plugin loaded?")
      end

      -- mappings: 'a=', 'a:' [n,v]
      vim.keymap.set("n", "<Leader>a=", function()
        if vim.fn.exists(":Tabularize") ~= 0 then
          vim.cmd(":Tabularize /=/l1")
        else
          error_no_tabularize_cmd()
        end
      end)
      vim.keymap.set("n", "<Leader>a:", function()
        if vim.fn.exists(":Tabularize") ~= 0 then
          vim.cmd(":Tabularize /:/l1")
        else
          error_no_tabularize_cmd()
        end
      end, { silent = true, remap = false })

      -- mapping: '|' [i]
      -- on-the-fly formatting while typing
      -- based on https://gist.github.com/tpope/287147
      -- variables '{b,g}:dn_no_tab_pipe_align' suppress formatting if == 1
      -- note boolean vars set to 1|0 since test for 1|0, not truthy|falsy
      vim.keymap.set("i", "<Bar>", function()
        local ok, var
        local pattern = "^%s*|%s.*%s|%s*$"
        local lineNumber = vim.fn.line(".")
        local currentColumn = vim.fn.col(".")
        local previousLine = vim.fn.getline(lineNumber - 1)
        local currentLine = vim.fn.getline(".")
        local nextLine = vim.fn.getline(lineNumber + 1)
        ok, var = pcall(vim.api.nvim_get_var, "dn_no_tab_pipe_align")
        local globalSuppress = (ok and var ~= 0) and 1 or 0
        ok, var = pcall(vim.api.nvim_buf_get_var, 0, "dn_no_tab_pipe_align")
        local localSuppress = (ok and var ~= 0) and 1 or 0
        local markdownFiletype = vim.bo.filetype:find("markdown") and 1 or 0

        vim.cmd("normal! i|")

        if
          globalSuppress == 0
          and localSuppress == 0
          and markdownFiletype == 1
          and currentLine:match("^%s*|")
          and (previousLine:match(pattern) or nextLine:match(pattern))
        then
          if vim.fn.exists(":Tabularize") ~= 0 then
            local column = #currentLine:sub(1, currentColumn):gsub("[^|]", "")
            local position = #vim.fn.matchstr(currentLine:sub(1, currentColumn), ".*|\\s*\\zs.*")
            vim.cmd("Tabularize/|/l1") -- `l` means left aligned and `1` means one space of cell padding
            vim.cmd("normal! 0")
            vim.fn.search(("[^|]*|"):rep(column) .. ("\\s\\{-\\}"):rep(position), "ce", lineNumber)
          else
            error_no_tabularize_cmd()
          end
        end

        vim.cmd("startinsert!")
      end, { silent = true, remap = false })
    end,
  },
}
