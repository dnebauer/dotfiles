" Vim configuration: java file support

function! s:JavaSupport()
    " vim omnicompletion    {{{1
    if dn#rc#isVim()
        setlocal omnifunc=javacomplete#Complete
    endif
endfunction

augroup vrc_java_files
    autocmd!
    autocmd FileType java call s:JavaSupport()
augroup END

" vim:foldmethod=marker:
