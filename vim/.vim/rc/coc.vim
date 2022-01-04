" Vim configuration: CoC (Conqueror of Completion)
" - based on https://github.com/neoclide/coc.nvim#example-vim-configuration

" Set internal encoding    {{{1
" - required by vim, not neovim
" - because coc.nvim uses unicode in file autoload/float.vim
set encoding=utf-8
scriptencoding utf8

" More space for displaying messages    {{{1
set cmdheight=2

" Long updatetime (default=4000ms=4s) causes noticeable delays    {{{1
set updatetime=300

" Shorten messages as much as possible    {{{1
" - don't pass messages to |ins-completion-menu|
set shortmess=acF

" Always show signcolumn    {{{1
# - or will shift text each time diagnostics appear/become resolved
if has('nvim-0.5.0') || has('patch-8.1.1564') | set signcolumn=number
else                                          | set signcolumn=yes
endif

" Use <Tab> to trigger completion    {{{1
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <C-Space> to trigger completion    {{{1
if has('nvim') | inoremap <silent><expr> <C-Space> coc#refresh()
else           | inoremap <silent><expr> <C-@> coc#refresh()
endif

" <CR> auto-selects first completion item    {{{1
" - and notifies coc.nvim to format on enter
inoremap <silent><expr> <CR> pumvisible()
            \ ? coc#_select_confirm()
            \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use '[g' and ']g' to navigate diagnostics    {{{1
" - |:CocDiagnostics| gets all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation    {{{1
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window    {{{1
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . ' ' . expand('<cword>')
    endif
endfunction

" Close floating help window with <C-[>    {{{1
nmap <silent> <C-[> <Esc>:noh<CR><Plug>(coc-float-hide)

" Symbol renaming    {{{1
nmap <Leader>rn <Plug>(coc-rename)

" Formatting selected code    {{{1
xmap <Leader>f <Plug>(coc-format-selected)
nmap <Leader>f <Plug>(coc-format-selected)

" Event triggered changes    {{{1
augroup vrc_coc_settings
  autocmd!
  " Highlight symbol under cursor when cursor still    {{{2
  autocmd CursorHold *
              \ silent call CocActionAsync('highlight')
  " Setup formatexpr for specified filetypes    {{{2
  autocmd FileType typescript,json
              \ setlocal formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder    {{{2
  autocmd User CocJumpPlaceholder
              \ call CocActionAsync('showSignatureHelp')
  " }}}2
augroup end

" Apply codeAction to selected region    {{{1
" Example: '<Leader>aaap' for current paragraph
xmap <Leader>aa <Plug>(coc-codeaction-selected)
nmap <Leader>aa <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer    {{{1
nmap <Leader>ac  <Plug>(coc-codeaction)

" Apply AutoFix to problem on the current line    {{{1
nmap <Leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line    {{{1
nmap <Leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects    {{{1
" - requires 'textDocument.documentSymbol' support from language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups    {{{1
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f>
              \ coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b>
              \ coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f>
              \ coc#float#has_scroll()
              \ ? "\<c-r>=coc#float#scroll(1)\<CR>"
              \ : "\<Right>"
  inoremap <silent><nowait><expr> <C-b>
              \ coc#float#has_scroll()
              \ ? "\<c-r>=coc#float#scroll(0)\<CR>"
              \ : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f>
              \ coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b>
              \ coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-s for selections ranges    {{{1
" - requires 'textDocument/selectionRange' support from language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add ':Format' command to format current buffer    {{{1
command! -nargs=0 Format :call CocAction('format')

" Add ':Fold' command to fold current buffer    {{{1
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Add ':OR' command for organize imports of the current buffer.
command! -nargs=0 OR
            \ :call CocActionAsync(
            \     'runCommand', 'editor.action.organizeImport'
            \ )

" Integrate with vim-airline for statusline    {{{1
let airline#extensions#coc#error_symbol = 'Error:'
let airline#extensions#coc#warning_symbol = 'Warning:'
let airline#extensions#coc#stl_format_err = '%E{[%e(#%fe)]}'
let airline#extensions#coc#stl_format_warn = '%W{[%w(#%fw)]}'

" Mappings for CoCList    {{{1
" - show all diagnostics
nnoremap <silent><nowait> <Space>a :<C-u>CocList diagnostics<CR>
" - manage extensions
nnoremap <silent><nowait> <Space>e :<C-u>CocList extensions<CR>
" - show commands
nnoremap <silent><nowait> <Space>c :<C-u>CocList commands<CR>
" - find symbol of current document
nnoremap <silent><nowait> <Space>o :<C-u>CocList outline<CR>
" - search workspace symbols
nnoremap <silent><nowait> <Space>s :<C-u>CocList -I symbols<CR>
" - do default action for next item
nnoremap <silent><nowait> <Space>j :<C-u>CocNext<CR>
" - do default action for previous item
nnoremap <silent><nowait> <Space>k :<C-u>CocPrev<CR>
" - resume latest coc list
nnoremap <silent><nowait> <Space>p :<C-u>CocListResume<CR>
" }}}1

" vim:foldmethod=marker:
