--[[ tummetott/unimpaired.nvim : complementary and useful mappings ]]

return {
  "tummetott/unimpaired.nvim",
  config = function()
    require("unimpaired").setup({
      keymaps = {
        previous = false, -- [a
        next = false, -- ]a
        first = false, -- [A
        last = false, --]A

        bprevious = false, -- [b
        bnext = false, -- ]b
        bfirst = false, -- [B
        blast = false, -- ]B

        -- keep loclist prev/next/first/last mappings: [l, ]l, [L, ]L
        lpfile = false, -- [<C-l>
        lnfile = false, -- ]<C-l>

        cprevious = false, -- [q
        cnext = false, -- ]q
        -- keep qflist first/last mappings: [Q, ]Q
        cpfile = false, -- [<C-q>
        cnfile = false, -- ]<C-q>

        tprevious = false, -- [t
        tnext = false, -- ]t
        tfirst = false, -- [T
        tlast = false, -- ]T

        ptprevious = false, -- [<C-t>
        ptnext = false, -- ]<C-t>
        previous_file = false, -- [f
        next_file = false, -- ]f

        -- keep blank line above/below mappings: [<Space>, ]<Space>
        -- keep exchange line above/below mappings: [e, ]e
        exchange_section_above = false, -- [e
        exchange_section_below = false, -- ]e

        enable_cursorline = false, -- [oc
        disable_cursorline = false, -- ]oc
        toggle_cursorline = false, -- yoc

        enable_diff = false, -- [od
        disable_diff = false, -- ]od
        toggle_diff = false, -- yod

        enable_hlsearch = false, -- [oh
        disable_hlsearch = false, -- ]oh
        toggle_hlsearch = false, -- yoh

        enable_ignorecase = false, -- [oi
        disable_ignorecase = false, -- ]oi
        toggle_ignorecase = false, -- yoi

        enable_list = false, -- [ol
        disable_list = false, -- [ol
        toggle_list = false, -- yol

        enable_number = false, -- [on
        disable_number = false, -- [on
        toggle_number = false, -- yon

        enable_relativenumber = false, -- [or
        disable_relativenumber = false, -- ]or
        toggle_relativenumber = false, -- yor

        -- keep spell on/off/toggle mappings: [os, ]os, yos

        enable_background = false, -- [ob
        disable_background = false, -- ]ob
        toggle_background = false, -- yob

        enable_colorcolumn = false, -- [ot
        disable_colorcolumn = false, -- ]ot
        toggle_colorcolumn = false, -- yot

        enable_cursorcolumn = false, -- [ou
        disable_cursorcolumn = false, -- ]ou
        toggle_cursorcolumn = false, -- you

        enable_virtualedit = false, -- [ov
        disable_virtualedit = false, -- ]ov
        toggle_virtualedit = false, -- yov

        enable_wrap = false, -- [ow
        disable_wrap = false, -- ]ow
        toggle_wrap = false, -- yow

        enable_cursorcross = false, -- [ox
        disable_cursorcross = false, -- ]ox
        toggle_cursorcross = false, -- yox
      },
    })
  end,
}
