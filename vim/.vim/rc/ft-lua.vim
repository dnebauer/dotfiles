" Vim configuration: lua file support

function! s:LuaSupport()
    " linting    {{{1
    let b:ale_linters = ['luac', 'luacheck']
    let g:ale_lua_luacheck_options = '--no-unused-args'     " }}}1
endfunction

augroup vrc_lua_files
    autocmd!
    autocmd FileType lua call s:LuaSupport()
augroup END

" vim:foldmethod=marker:
