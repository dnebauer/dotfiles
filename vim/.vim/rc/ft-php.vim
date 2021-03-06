" Vim configuration: php file support

function! s:PhpSupport()
    " tagbar support    {{{1
    " - from https://github.com/vim-php/tagbar-phpctags.vim
    let l:bin = dn#rc#pluginsDir()
                \ . '/tagbar-phpctags.vim/build/phpctags-master/bin/phpctags'
    if filereadable(l:bin)
        let g:tagbar_phpctags_bin = l:bin
    endif    " }}}1
endfunction

augroup vrc_php_files
    autocmd!
    autocmd FileType php call s:PhpSupport()
augroup END

" vim:foldmethod=marker:
