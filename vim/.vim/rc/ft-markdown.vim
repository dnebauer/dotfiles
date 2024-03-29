" Vim configuration: markdown file support

function! s:MarkdownSupport()
    " only give feedback on first run    {{{1
    " - this function is run three times when opening vim with md file
    if exists('s:ran_previously') && s:ran_previously
        let l:first_run = 0
    else
        let l:first_run = 1
        let s:ran_previously = 1
    endif
    " tagbar support    {{{1
    " - from https://github.com/majutsushi/tagbar/wiki
    let l:bin = dn#rc#pluginsDir() . '/markdown2ctags/markdown2ctags.py'
    if filereadable(l:bin)
        let g:tagbar_type_markdown = {
                    \ 'ctagstype'  : 'markdown',
                    \ 'ctagsbin'   : l:bin,
                    \ 'ctagsargs'  : '-f - --sort=yes',
                    \ 'kinds'      : ['s:sections', 'i:images'],
                    \ 'sro'        : '|',
                    \ 'kind2scope' : {'s' : 'section'},
                    \ 'sort'       : 0,
                    \ }
    endif
    " require pandoc for output generation    {{{1
    if l:first_run && !executable('pandoc')
        let l:msg = [ 'Cannot locate pandoc',
                    \ '- pandoc is needed to generate output',
                    \ '', ]
        call dn#rc#error(l:msg)
    endif
    " require pandoc-xnos filter suite for output generation    {{{1
    if l:first_run
        let l:filters = ['pandoc-eqnos', 'pandoc-fignos', 'pandoc-secnos',
                    \    'pandoc-tablenos', 'pandoc-xnos']
        let l:missing = []
        for l:filter in l:filters
            if !executable(l:filter)
                call add(l:missing, l:filter)
            endif
        endfor
        if !empty(l:missing)
            let l:msg = [ 'Cannot find entire pandoc-xnos filter suite',
                        \ '- missing: ' . join(l:missing, ', '),
                        \ '- this filter suite is used for cross-referencing',
                        \ '', ]
            call dn#rc#error(l:msg)
        endif
    endif
    " configure plugins vim-pandoc[-{syntax,after}]    {{{1
    let g:pandoc#filetypes#handled         = ['pandoc', 'markdown']
    let g:pandoc#filetypes#pandoc_markdown = 0
    let g:pandoc#after#modules#enabled     = ['neosnippet']
    let g:pandoc#modules#enabled           = [
                \ 'formatting', 'folding', 'command',
                \ 'keyboard',   'yaml',    'completion',
                \ 'toc',        'hypertext']
    let g:pandoc#formatting#mode                            = 'h'
    let g:pandoc#formatting#smart_autoformat_on_cursormoved = 1
    let g:pandoc#command#latex_engine                       = 'xelatex'
    let g:pandoc#command#custom_open    = 'dn#rc#pandocOpen'
    let g:pandoc#command#prefer_pdf     = 1
    let g:pandoc#command#templates_file = dn#rc#vimPath('home')
                \ . '/vim-pandoc-templates'
    let g:pandoc#compiler#command = 'pander'
    " - hashes at end as well as start of headings
    let g:pandoc#keyboard#sections#header_style = 2
    " improve sentence text object    {{{1
    call textobj#sentence#init()
    " add system dictionary to word completions    {{{1
    setlocal complete+=k
    " vim omnicompletion    {{{1
    if dn#rc#isVim()
        setlocal omnifunc=htmlcomplete#CompleteTags
    endif
    " customise surround.vim plugin    {{{1
    " - strong emphasis (b)    {{{2
    let b:surround_98 = "__\r__"
    " - emphasis (i)    {{{2
    let b:surround_105 = "_\r_"
    " - inline code (`)    {{{2
    let b:surround_96 = "`\r`"
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
    " change filetype to trigger vim-pandoc plugin    {{{1
    set filetype=pandoc
    sleep
    set filetype=markdown.pandoc
    " specify linters for ALE    {{{1
    " - not using 'remark'
    "   . because it cannot find dependent node modules
    "     despite them being installed:
    "   . example error: 'Error: Could not find module `remark-gfm`'
    "   . seems likely problem is that remark cannot find globally installed
    "     modules (possible because of the prefix defined in ~/.npmrc)
    let b:ale_linters = ['mdl', 'proselint', 'textlint', 'write-good']
    " configure coc-vimlsp extension    {{{1
    let g:markdown_fenced_languages = ['vim', 'help']
    " }}}1
endfunction

augroup vrc_markdown_files
    autocmd!
    autocmd FileType markdown call s:MarkdownSupport()
augroup END

" vim:foldmethod=marker:
