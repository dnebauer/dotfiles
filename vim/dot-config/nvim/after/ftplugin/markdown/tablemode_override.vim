" overriding setting in plugin: dhruvasagar/vim-table-mode
" * unable to set table_corner_mode in plugin setup by setting
"   'g:table_mode_corner' or 'b:table_mode_corner' because the
"   plugin file "tablemode_markdown.vim" sets
"   'b:table_mode_corner' to "|" which overrides them
" * the override technique using an 'after' file is described in
"   https://github.com/dhruvasagar/vim-table-mode/issues/185
let b:table_mode_corner = '+'
