" Vim configuration: bash file support

function! s:BashSupport()
    " syntax checker shellcheck follows files ('-x')    {{{1
    " ale    {{{2
    if dn#rc#lintEngine() ==# 'ale'
        let g:ale_sh_shellcheck_options = '-x'
    endif
    " }}}1
endfunction

augroup vrc_bash_files
    autocmd!
    autocmd FileType bash call s:BashSupport()
augroup END

" vim:foldmethod=marker:
