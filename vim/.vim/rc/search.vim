" Vim configuration: search

" Highlighting matches    {{{1
" - highlight all current matches
set hlsearch
" - turn off match highlighting [N] : <BS>
nnoremap <silent> <BS> :nohlsearch<CR>

" Case sensitivity    {{{1
" - case insensitive matching if all lowercase
set ignorecase
" - case sensitive matching if any capital letters
set smartcase
" - intelligent case selection in autocompletion
set infercase

" Find all matches in line    {{{1
" - 'g' now toggles to first only
set gdefault

" Progressive match with incremental search    {{{1
set incsearch

" Force magic regex during search    {{{1
nnoremap / /\m
nnoremap ? ?\m
vnoremap / /\m
vnoremap ? ?\m
cnoremap %s/ %s/\m

" Mute search highlighting as part of screen redraw    {{{1
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" Sneak plugin    {{{1
" - interact with ;/: (as swapped in basic.vim)
nmap <expr> ; (exists('*sneak#is_sneaking') && sneak#is_sneaking())
            \ ? '<Plug>SneakNext'
            \ : ':'
if !has('nvim')
    " - emulate easymotion interface
    let g:sneak#label = 1
    " - replace 'f' and 't' with 1-char sneak    {{{2
    nmap f <Plug>Sneak_f
    nmap F <Plug>Sneak_F
    xmap f <Plug>Sneak_f
    xmap F <Plug>Sneak_F
    omap f <Plug>Sneak_f
    omap F <Plug>Sneak_F
    nmap t <Plug>Sneak_t
    nmap T <Plug>Sneak_T
    xmap t <Plug>Sneak_t
    xmap T <Plug>Sneak_T
    omap t <Plug>Sneak_t
    omap T <Plug>Sneak_T
    " }}}2
    " - enable clever s
    let g:sneak#s_next = 1
endif

" Mappings for motion plugins and Surround plugin    {{{1
" - sneak- and Surround-based mappings based on gist
"   "LanHikari22/vim-sneak - use s in operator mode.vim"
"   (https://gist.github.com/LanHikari22/6b568683d81cbb7a2252fac86f6f4a4b)
"   and sneak issue #268 (https://github.com/justinmk/vim-sneak/issues/268)
" - ensures sneak visual mode mappings all use s|S (not s|Z)
" - does this by changing surround visual mappings to use z
" - while dz and cz created for uniformity, ds and cs are retained
let g:surround_no_mappings = 1
xmap  z      <Plug>VSurround
nmap  yzz    <Plug>Yssurround
nmap  yz     <Plug>Ysurround
nmap  dz     <Plug>Dsurround
nmap  cz     <Plug>Csurround
if !has('nvim')
    xmap  <S-s>  <Plug>Sneak_S
    omap  s      <Plug>Sneak_s
    omap  S      <Plug>Sneak_S
endif
if has('nvim')
    " does not overwrite visual mode mapping of 'x' from 'edit.vim'
    lua require('leap').add_default_mappings()
endif

" Fix '&' command    {{{1
" - unlike '&', '&&' preserves flags
" - create visual mode equivelent
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" Set grep command to use ugrep    {{{1
if executable('ugrep')
    set grepprg=ugrep\ -RInk\ -j\ -u\ --tabs=1\ --ignore-files
    set grepformat=%f:%l:%c:%m,%f+%l+%c+%m,%-G%f\\\|%l\\\|%c\\\|%m
endif
" }}}1

" vim:foldmethod=marker:
