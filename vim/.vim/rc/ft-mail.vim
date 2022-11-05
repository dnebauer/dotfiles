" Vim configuration: mail file support

function s:SynMailIncludeMarkdown()
    " define syntax group list '@synMailIncludeMarkdown'    {{{1
    " * add 'contained' flag to all syntax items in 'syntax/markdown.vim'
    " * add top-level syntax items in 'syntax/markdown.vim' to
    "   '@synMailIncludeMarkdown' syntax group list
    unlet b:current_syntax
    syntax include @synMailIncludeMarkdown syntax/markdown.vim
    let b:current_syntax = 'mail'
    " apply markdown region    {{{1
    "       keepend: a match with an end pattern truncates any contained
    "                matches
    "         start: markdown region starts after first empty line
    "                * '\n' is newline [see ':h /\n']
    "                * '\_^$' is empty line [see ':h /\_^', ':h /$']
    "                * '\@1<=' means:
    "                  - must still match preceding ('\n') and following
    "                    ('\_^$') atoms in sequence
    "                  - the '1' means only search backwards 1 character for
    "                    the previous match
    "                  - although the following atom is required for a match,
    "                    the match is actually deemed to end before it begins
    "                    [see ':h /zero-width']
    "           end: markdown region ends at end of file
    "   containedin: markdown region can be included in any syntax group in
    "                'mail'
    "      contains: syntax group '@synMailIncludeMarkdown' is allowed to
    "                begin inside region
    syntax region synMailIncludeMarkdown
                \ keepend
                \ start='\n\@1<=\_^$'
                \ end='\%$'
                \ containedin=ALL
                \ contains=@synMailIncludeMarkdown
    " clear function call command from command line window    {{{1
    echo ' '
    " }}}1
endfunction

function! s:MailSupport()
    " re-flow text support    {{{1
    " set parameters to be consistent with re-flowing content
    " e.g., in neomutt setting text_flowed to true
    setlocal textwidth=72
    setlocal formatoptions+=q
    setlocal comments+=nb:>
    " rewrap paragraph using <M-q>, i.e., Alt-q    {{{1
    " - linux terminal key codes for <M-q> not recognised by vim
    " - get terminal key codes using 'cat' or 'sed -n l'
    " - konsole key codes for <M-q> are 'q'
    " - '' is an escape entered in vim with <C-v> then <Esc>
    " - '' is represented in 'set' command with '\<Esc>'
    if has('unix')
        try
            execute "set <M-q>=\<Esc>q"
        catch /^Vim\%((\a\+)\)\=:E518:/  " Unknown option: <M-q>=q
        endtry
    endif
    nnoremap <silent> <M-q> {gq}<Bar>:echo "Rewrapped paragraph"<CR>
    inoremap <silent> <M-q> <Esc>{gq}<CR>a
    " add mapping to include markdown region    {{{1
    if empty(maparg('<LocalLeader>md', 'i'))
        imap <buffer> <unique> <LocalLeader>md
                    \ <Esc>:call <SID>SynMailIncludeMarkdown()<CR>
    endif
    if empty(maparg('<LocalLeader>md', 'n'))
        nmap <buffer> <unique> <LocalLeader>md
                    \ :call <SID>SynMailIncludeMarkdown()<CR>
    endif
    " fold quoted text    {{{1
    " - taken from 'mutt-trim' github repo README file
    "   (https://github.com/Konfekt/mutt-trim)
    setlocal foldexpr=strlen(substitute(matchstr(getline(v:lnum)
    setlocal foldexpr+=,'\\v^\\s*%(\\>\\s*)+'),'\\s','','g'))
    setlocal foldmethod=expr foldlevel=1 foldminlines=2
    " }}}1
endfunction

augroup vrc_mail_files
    autocmd!
    autocmd FileType mail call s:MailSupport()
augroup END

" vim:foldmethod=marker:
