" Vim configuration: tab behaviour

" Tab behaviour in insert mode    {{{1
" - governed by CoC, so see coc.vim

" Tab behaviour in normal mode    {{{1
" - find next item in quickfix or location window
function! s:TabNormalMode()                                          "    {{{2
    " is there a error to jump to in location or quickfix window?
    try | cnext  | return | catch | endtry
    try | cfirst | return | catch | endtry
    try | lnext  | return | catch | endtry
    try | lfirst | return | catch | endtry
endfunction    " }}}2
nnoremap <silent><Tab> :call <SID>TabNormalMode()<CR>

" Shift-Tab behaviour in normal mode    {{{1
" - find previous item in quickfix or location window
function! s:ShiftTabNormalMode()                                     "    {{{2
    " is there a error to jump to in location or quickfix window?
    try | cprev  | return | catch | endtry
    try | cfirst | return | catch | endtry
    try | lprev  | return | catch | endtry
    try | lfirst | return | catch | endtry
endfunction    " }}}2
nnoremap <silent><S-Tab> :call <SID>ShiftTabNormalMode()<CR>
" }}}1

" vim:foldmethod=marker:
