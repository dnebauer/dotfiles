" Vim configuration: sh file support

function! s:ShSupport()
    " linter shellcheck follows files ('-x')    {{{1
    " ale    {{{2
    if dn#rc#lintEngine() ==# 'ale'
        let g:ale_sh_shellcheck_options = '-x'
    endif
    " }}}1
endfunction

augroup vrc_sh_files
    autocmd!
    autocmd FileType sh call s:ShSupport()
augroup END

" vim:foldmethod=marker:
