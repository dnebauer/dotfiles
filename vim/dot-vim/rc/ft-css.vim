" Vim configuration: css file support

if dn#rc#isVim()  " vim
    function! s:VimCssSupport()
        " omnicompletion - yet to set up
    endfunction
    augroup vrc_css_files
        autocmd!
        autocmd FileType css call s:VimCssSupport()
    augroup END
endif

" vim:foldmethod=marker:
