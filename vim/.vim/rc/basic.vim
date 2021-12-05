" Vim configuration: basic settings

" Encoding: utf-8    {{{1
" - cannot set in neovim after initialisation
try
    set encoding=utf-8
catch /^Vim:E905:/
endtry
scriptencoding utf-8
setglobal fileencoding=utf-8

" Language: Australian English    {{{1
" - fallback to UK English, then US English, then generic English
" - E197 error means could not set language
try | lang en_AU | catch /^Vim\((\a\+)\)\=:E197:/
    try | lang en_GB | catch /^Vim\((\a\+)\)\=:E197:/
        try | lang en_US | catch /^Vim\((\a\+)\)\=:E197:/
            try | lang en | catch /^Vim\((\a\+)\)\=:E197:/
            endtry
        endtry
    endtry
endtry

" Use ; for : and vice versa    {{{1
" - see search.vim for semicolon interaction with sneak plugin
vnoremap : ;
vnoremap ; :

" Files to ignore when file matching    {{{1
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,
            \.ind,.idx,.ilg,.inx,.out,.toc    " }}}1

" vim:foldmethod=marker:
