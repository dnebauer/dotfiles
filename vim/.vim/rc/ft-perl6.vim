" Vim configuration: perl6 file support

function! s:Perl6Support()
    " linting    {{{1
    " }}}1
endfunction

augroup vrc_perl6_files
    autocmd!
    autocmd FileType perl6 call s:Perl6Support()
augroup END

" vim:foldmethod=marker:
