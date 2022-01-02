" Vim configuration: syntax checking

function! s:BufferIsFile()    " {{{1
    return strlen(bufname('%')) > 0
endfunction

" note on E676 error    {{{1

" Nvim can give an E676 error ('No matching commands for acwrite buffer'),
" even though there ARE matching autocommands, when editing buffers with
" filetype 'acwrite'.
" The 'acwrite' filetype is set by the vim-gnupg plugin
" when editing '*.gpg' files.
" This error should be caught and handled when
" setting autocommands.

" linting    {{{1
if dn#rc#lintEngine() ==# 'ale'
    " integrate ALE with airline    {{{2
    let g:airline#extensions#ale#enabled = 1
    " save file after alteration    {{{2
    " - because some linters can't be run on buffer contents, only saved file
    " - handle E676 error as described above
    function! s:SaveAfterAlteration()
        "if s:BufferIsFile()
        if strlen(bufname('%')) > 0
            try | update! | catch /^Vim\%((\a\+)\)\=:E676/ | endtry
        endif
    endfunction
    augroup vrc_ale
        autocmd!
        autocmd InsertLeave,TextChanged * call s:SaveAfterAlteration()
    augroup END
    " force remark plugin to use global config file    {{{2
    let b:ale_markdown_remark_lint_use_global = 1
    let b:ale_markdown_remark_lint_options = '-r ~/.remarkrc.yml'
    " }}}2
endif    " }}}1

" vim:foldmethod=marker:
