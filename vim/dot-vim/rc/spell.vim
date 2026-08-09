" Vim configuration: spelling

" Word lists    {{{1
set spell spelllang=en_au

" Dictionaries    {{{1
if dn#rc#os() ==# 'unix' && filereadable('/usr/share/dict/words')
    set dictionary-=/usr/share/dict/words
    set dictionary+=/usr/share/dict/words
endif

" Spell check - off at start up    {{{1
set spell!

" Spell check - toggle on and off [N,I] : \st    {{{1
nnoremap <Leader>st :call dn#rc#spellToggle()<CR>
inoremap <Leader>st <Esc>:call dn#rc#spellToggle()<CR>

" Spell check - show status [N,I] : \ss    {{{1
nnoremap <Leader>ss :call dn#rc#spellStatus()<CR>
inoremap <Leader>ss <Esc>:call dn#rc#spellStatus()<CR>

" Spell check - correct next/previous bad word [N] : ]=,[=    {{{1
noremap ]= ]sz=
noremap [= [sz=

" Add custom moby thesaurus (~/.vim/thes/moby.thes)    {{{1
call dn#rc#addThesaurus(dn#rc#vimPath('home') . '/thes/moby.thes')

" Add Project Gutenberg thesaurus (~/.vim/thes/mthesaur.txt)    {{{1
call dn#rc#addThesaurus(dn#rc#vimPath('home') . '/thes/mthesaur.txt')

" Configure thesaurus plugin   {{{1
" [plugin is Ron89/thesaurus_query.vim]
" - specify location of en_AU thesaurus files (.idx and .dat)
" - note that the plugin assumes these files are installed by openoffice even
"   though they are provided by a non-openoffice debian package
"   ('mythes-en-au'), and openoffice replacement libreoffice uses the files
"   provided by the debian 'mythese-LANG' packages 
let g:tq_openoffice_en_file = '/usr/share/mythes/th_en_AU_v2'
" - specify location of Project Gutenberg's thesaurus file
let g:tq_mthesaur_file = dn#rc#vimPath('home') . '/thes/mthesaur.txt'
" - specify backends
let g:tq_enabled_backends=['openoffice_en', 'mthesaur_txt']

" Cooperate with rhysd/vim-grammarous plugin    {{{1
let g:grammarous#use_vim_spelllang = 1    " }}}1

" vim:foldmethod=marker:
