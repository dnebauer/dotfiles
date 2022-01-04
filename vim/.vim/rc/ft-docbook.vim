" Vim configuration: docbook file support

function! s:DocbookSupport()
    " fold by syntax    {{{1
    setlocal foldmethod=syntax
    " snippets    {{{1
    if !exists('g:neosnippet#snippets_directory')
        let g:neosnippet#snippets_directory = []
    endif
    let l:repo = dn#rc#pluginsDir() . '/vim-snippets/snippets'
    if !count(g:neosnippet#snippets_directory, l:repo)
        call add(g:neosnippet#snippets_directory, l:repo)
    endif    " }}}1
endfunction

augroup vrc_docbook_files
    autocmd!
    autocmd FileType docbk call s:DocbookSupport()
augroup END

" vim:foldmethod=marker:
