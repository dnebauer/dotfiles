" Vim configuration: javascript file support

function! s:JavascriptSupport()
    " vim omnicompletion - yet to set up
    if dn#rc#isVim()
        " stub
    endif
endfunction

augroup vrc_javascript_files
    autocmd!
    autocmd FileType javascript call s:JavascriptSupport()
augroup END

" vim:foldmethod=marker:
