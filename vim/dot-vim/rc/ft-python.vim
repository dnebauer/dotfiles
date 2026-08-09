" Vim configuration: python file support

function! s:PythonSupport()
    " vim omnicompletion    {{{1
    if dn#rc#isVim()
        setlocal omnifunc=pythoncomplete#Complete
    endif
endfunction

augroup vrc_python_files
    autocmd!
    autocmd FileType python call s:PythonSupport()
augroup END

" vim:foldmethod=marker:
