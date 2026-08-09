" Vim configuration: tex file support

function! s:TexSupport()
    " stub
endfunction

augroup vrc_tex_files
    autocmd!
    autocmd FileType tex,context call s:TexSupport()
augroup END

" vim:foldmethod=marker:
