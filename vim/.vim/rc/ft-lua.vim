" Vim configuration: lua file support

function! s:LuaSupport()
    " nvim completion using deoplete    {{{1
    if dn#rc#isNvim()
        if !exists('g:deoplete#omni#functions')
            let g:deoplete#omni#functions = {}
        endif
        let g:deoplete#omni#functions.lua = 'xolox#lua#omnifunc'
    endif
    " linting    {{{1
    " ale    {{{2
    if dn#rc#lintEngine() ==# 'ale'
        let g:ale_lua_luacheck_options = '--no-unused-args'
    endif    " }}}2
    " }}}1
endfunction

augroup vrc_lua_files
    autocmd!
    autocmd FileType lua call s:LuaSupport()
augroup END

" vim:foldmethod=marker:
