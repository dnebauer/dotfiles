" Vim configuration: go file support

function! s:GoSupport()
    " tagbar support    
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
    " vim-go configuration    
    " - mappings    
    " - \r  : go run    
    nmap <Leader>r <Plug>(go-run)
    " - \b  : go build    
    nmap <Leader>b <Plug>(go-build)
    " - \t  : go test    
    nmap <Leader>t <Plug>(go-test)
    " - \c  : show coverage annotation    
    nmap <Leader>c <Plug>(go-coverage)
    " - \gd : open godoc for word under cursor    
    nmap <Leader>gd <Plug>(go-doc)
    " - \s  : show interfaces for type under cursor    
    nmap <Leader>s <Plug>(go-implements)
    " - \i  : show type info for word under cursor    
    nmap <Leader>i <Plug>(go-info)
    " - \e  : rename identifier under cursor    
    nmap <Leader>e <Plug>(go-rename)
    " - syntax highlight aggressively    
    let g:go_highlight_functions         = 1
    let g:go_highlight_methods           = 1
    let g:go_highlight_fields            = 1
    let g:go_highlight_types             = 1
    let g:go_highlight_operators         = 1
    let g:go_highlight_build_constraints = 1
    " - open new terminals in horizontal split    
    let g:go_term_mode = 'split'
    " - ensure command output is displayed    
    let g:go_list_type = 'quickfix'
    " linting    
    " 
endfunction

augroup vrc_go_files
    autocmd!
    autocmd FileType go call s:GoSupport()
augroup END

" vim:foldmethod=marker:
