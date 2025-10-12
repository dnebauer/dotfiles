--[[ nvim-mini/mini.ai : extend and create a/i textobjects ]]

-- lua plugin

return {
  {
    "nvim-mini/mini.ai",
    lazy = true,
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          -- code block
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          -- function
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          -- class
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          -- tags
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          -- digits
          d = { "%f[%d]%d+" },
          -- Word with case
          e = {
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          -- buffer
          g = function()
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line("$"),
              col = math.max(vim.fn.getline("$"):len(), 1),
            }
            return { from = from, to = to }
          end,
          -- u for "Usage"
          u = ai.gen_spec.function_call(),
          -- without dot in function name
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
        },
      }
    end,
  },
}
