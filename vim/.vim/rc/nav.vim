" Vim configuration: navigation

" Backspace    {{{1
" - set behaviour
set backspace=indent,eol,start
" - additional page up key [N,V] : <Backspace>
nnoremap <BS> <PageUp>
vnoremap <BS> <PageUp>

" Space    {{{1
" - additional page down key [N,V] : <Space>
nnoremap <Space> <PageDown>
vnoremap <Space> <PageDown>

" Arrows    {{{1
" - default to arrows off
augroup nav_easy_mode
    autocmd!
    autocmd VimEnter,BufNewFile,BufReadPost * silent! call EasyMode()
augroup END
" - toggle hardmode [N] : \hr
nnoremap <LocalLeader>hm <Esc>:call ToggleHardMode()<CR>

" Visual shift    {{{1
" - repeat visual shift operation [V]: <,>
vnoremap < <gv
vnoremap > >gv

" Tags    {{{1
" - asynchronous updating    {{{2
"   . easytags plugin
if exists(':UpdateTags') | let g:easytags_async = 1 | endif
" - autogeneration    {{{2
"   . gen_tags plugin
if exists(':GenCtags') | let g:gen_tags#ctags_auto_gen = 1 | endif
if exists(':GenGTAGS') | let g:gen_tags#gtags_auto_gen = 1 | endif
" - other tools providing ctags-compatible output    {{{2
" -- phpctags    {{{3
" --- easytags plugin
if !exists('g:easytags_languages') | let g:easytags_languages = {} | endif
let s:cmd = $HOME . '/.cache/dein/repos/github.com/vim-php/'
            \ . 'tagbar-phpctags.vim/bin/phpctags'
if filereadable(s:cmd)
    let g:easytags_languages.php = {'cmd' : s:cmd} 
endif
unlet s:cmd
" -- jsctags    {{{3
" --- easytags plugin
if filereadable('jsctags')
    let g:easytags_languages.php = {
                \ 'cmd'          : 'jsctags',
                \ 'recurse_flag' : '',
                \ }
endif

" Terminal window navigation (nvim-only)    {{{1
if exists(':Terminal')
    tnoremap <C-h> <C-\><C-n><C-w>h
    tnoremap <C-j> <C-\><C-n><C-w>j
    tnoremap <C-k> <C-\><C-n><C-w>k
    tnoremap <C-l> <C-\><C-n><C-w>l
endif
" }}}1

" vim:foldmethod=marker:
