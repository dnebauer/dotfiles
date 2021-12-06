" Vim configuration: go file support

function! s:GoSupport()
    " tagbar support    {{{1
    " - from https://github.com/majutsushi/tagbar/wiki
    if executable('go')
        let g:tagbar_type_go = {
            \ 'ctagstype' : 'go',
            \ 'kinds'     : ['p:package',
            \                'f:function',
            \                'v:variables',
            \                't:type',
            \                'c:const'],
            \ }
    endif
    " vim-go configuration    {{{1
    " - mappings    {{{2
    " - \r  : go run    {{{3
    nmap <leader>r <Plug>(go-run)
    " - \b  : go build    {{{3
    nmap <leader>b <Plug>(go-build)
    " - \t  : go test    {{{3
    nmap <leader>t <Plug>(go-test)
    " - \c  : show coverage annotation    {{{3
    nmap <leader>c <Plug>(go-coverage)
    " - \gd : open godoc for word under cursor    {{{3
    nmap <Leader>gd <Plug>(go-doc)
    " - \s  : show interfaces for type under cursor    {{{3
    nmap <Leader>s <Plug>(go-implements)
    " - \i  : show type info for word under cursor    {{{3
    nmap <Leader>i <Plug>(go-info)
    " - \e  : rename identifier under cursor    {{{3
    nmap <Leader>e <Plug>(go-rename)
    " - syntax highlight aggressively    {{{2
    let g:go_highlight_functions         = 1
    let g:go_highlight_methods           = 1
    let g:go_highlight_fields            = 1
    let g:go_highlight_types             = 1
    let g:go_highlight_operators         = 1
    let g:go_highlight_build_constraints = 1
    " - open new terminals in horizontal split    {{{2
    let g:go_term_mode = 'split'
    " - ensure command output is displayed    {{{2
    let g:go_list_type = 'quickfix'
    " linting    {{{1
    " }}}1
endfunction

augroup vrc_go_files
    autocmd!
    autocmd FileType go call s:GoSupport()
augroup END

" vim:foldmethod=marker:
