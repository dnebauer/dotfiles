" Vim configuration: aligning text

" Tabs    {{{1
" - set tab = 4 spaces
set tabstop=4
set softtabstop=4
" - force spaces for tabs
set expandtab

" Indenting    {{{1
" - copy indent from current line to new
set autoindent
" - attempt intelligent indenting
set smartindent
" - number of spaces to use for autoindent
set shiftwidth=4

" Align text    {{{1
" - align text on '=', ':' and '|'
nnoremap <Leader>a= :Tabularize /=<CR>
vnoremap <Leader>a= :Tabularize /=<CR>
nnoremap <Leader>a: :Tabularize /:\zs<CR>
vnoremap <Leader>a: :Tabularize /:\zs<CR>
nnoremap <Leader>a\| :Tabularize /\|<CR>
vnoremap <Leader>a\| :Tabularize /\|<CR>

" Colour column 80    {{{1
" - setting highlight group 'colorcolumn' here does not have any effect,
"   so set it in .vimrc
if exists('+colorcolumn')
    let &colorcolumn='80'
    "highlight ColorColumn term=Reverse ctermbg=Yellow guibg=LightYellow
else
    " fallback for Vim < v7.3
    augroup colorcolumn
        autocmd!
        autocmd BufWinEnter *
                    \ let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
    augroup END
endif
" }}}1

" vim:foldmethod=marker:
