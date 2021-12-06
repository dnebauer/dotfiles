" Vim configuration: lua file support

function! s:LuaSupport()
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
