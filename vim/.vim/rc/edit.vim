" Vim configuration: editing

scriptencoding utf8  " required for C-Space mapping

" Clipboard    {{{1
" - which X11 clipboard(s) to use    {{{2
" - PRIMARY X11 selection
"   . vim visual selection (y,d,p,c,s,x, middle mouse button)
"   . used in writing "* register
"   CLIPBOARD X11 selection
"   . X11 cut, copy, paste (Ctrl-c, Ctrl-v)
"   . used in writing "+ register
"   unnamed option
"   . use "* register
"   . available always in vim and nvim
"   unnamedplus option
"   . use "+ register
"   . available in nvim always
"   . available in vim if compiled in [has('unnamedplus')]
set clipboard=unnamed,unnamedplus
if dn#rc#isVim() && !has('unnamedplus')
    set clipboard-=unnamedplus
endif

" Yank behaviour    {{{1
" - let vim-cutlass and vim-yoink play nice together
let g:yoinkIncludeDeleteOperations = 1
" - traverse yank history with ]y, [y
nmap [y <plug>(YoinkRotateBack)
nmap ]y <plug>(YoinkRotateForward)
" - cut with x, xx, X
nnoremap x d
xnoremap x d
nnoremap xx dd
nnoremap X D

" Paste behaviour    {{{1
" - <C-=> : toggle (un)formatted after paste
nmap <c-=> <plug>(YoinkPostPasteToggleFormat)
" - preserve cursor position during paste
nmap y <plug>(YoinkYankPreserveCursorPosition)
xmap y <plug>(YoinkYankPreserveCursorPosition)

" Undo    {{{1
nnoremap <Leader>u :GundoToggle<CR>

" Insert hard space : S-F8    {{{1
" - map unicode non-breaking space (U+00A0) to C-Space
" - would prefer C-S-Space but terminal vim has a problem with mapping it
"   (see https://vi.stackexchange.com/a/13329 for details)
inoremap <buffer><silent> <S-F8> <C-v>xa0
nnoremap <buffer><silent> <S-F8> vc<C-v>xa0<Esc>

" Modify surround plugin mappings    {{{1
" - this is done to play nice with the sneak plugin
" - both sneak and surround mappings done in search.vim

" Delete trailing whitespace    {{{1
let g:DeleteTrailingWhitespace        = 1
let g:DeleteTrailingWhitespace_Action = 'delete'

" Move visual block up and down : J,K    {{{1
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Cycle through visual modes : v    {{{1
xnoremap <expr> v mode() ==# 'v' ? "\<C-V>"
            \                    : mode() ==# 'V'
            \                        ? 'v'
            \                        : 'V'

" Treat all numerals as decimal    {{{1
set nrformats=
" }}}1

" vim:foldmethod=marker:
