" Vimrc library
" Last change: 2021 Jan 01
" Maintainer: David Nebauer
" License: GPL3

" Control statements    {{{1
set encoding=utf-8
scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim
" }}}1

" Script variables

" s:temp_path   - temporary file path    {{{1

""
" The file path of a temporary file. The function @function(dn#rc#temp)
" returns part or all of this variable.
if !(exists('s:temp_path') && s:temp_path !=? '')
    let s:temp_path = tempname()
endif

" s:engine      - linter engine    {{{1

""
" Name of linter engine to use.
if !exists('s:lint_engine') | let s:lint_engine = v:null | endif

" s:perl_syntax - content of vim syntax file    {{{1

""
" Content of vim syntax file providing support for modern perl features:
" * 'Readonly' and 'const' keywords, from Readonly[X] and Const::Fast modules,
"   respectively.
if !exists('s:perl_syntax')
    let s:perl_syntax = [
                \ '" Vim syntax file',
                \ '" Language: perl',
                \ '" Last change: 2018 Aug 12',
                \ '" Maintainer: David Nebauer',
                \ '" License: GPL3',
                \ '',
                \ '" const keyword (Const::Fast module)',
                \ 'syn match perlStatementConstFast '
                \ . "'\\<\\%(const\\s\\+my\\)\\>'",
                \ 'command! -nargs=+ HiLinkCF hi def link <args>',
                \ 'HiLinkCF perlStatementConstFast perlStatement',
                \ '',
                \ '" Readonly keyword (Readonly and ReadonlyX modules)',
                \ 'syn match perlStatementReadonly '
                \ . "'\\<\\%(Readonly\\s\\+my\\)\\>'",
                \ 'command! -nargs=+ HiLinkRO hi def link <args>',
                \ 'HiLinkRO perlStatementReadonly perlStatement',
                \ ]
endif

" s:plugin_cmds - execute after plugins initialised    {{{1

""
" Commands to be executed after all plugins initialised by plugin manager.
" These commands should be idempotent as there is no way to prevent them being
" called multiple times.

let s:plugin_cmds = []

" }}}1

" Public functions

" dn#rc#addThesaurus(file)    {{{1

""
" @public
" Add a 'thesaurus' {file}. Displays an error message if the thesaurus {file}
" cannot be located.
function! dn#rc#addThesaurus(file) abort
    " make sure thesaurus file exists and is readable
    if type(a:file) != type('') || a:file ==? ''
        echoerr 'Invalid thesaurus file value'
    endif
    let l:file = resolve(expand(a:file))
    if !filereadable(l:file)
        echoerr "Cannot find thesaurus file '" . a:file . "'"
    endif
    " add to thesaurus file variable (string, comma-delimited)
    if &thesaurus !=? '' | let &thesaurus .= ',' | endif
    let &thesaurus .= l:file
endfunction

" dn#rc#buildJedi()    {{{1

""
" @public
" Install jedi python package. Jedi is an autocompletion/static analysis
" library for Python
function! dn#rc#buildJedi() abort
    call dn#rc#pipInstall('jedi')
endfunction

" dn#rc#buildPandoc()    {{{1

""
" @public
" Install panzer and pandocinject python packages to support pandoc.
function! dn#rc#buildPandoc() abort
    call dn#rc#pipInstall('git+https://github.com/msprev/panzer',
                \         'panzer')
    call dn#rc#pipInstall('git+https://github.com/msprev/pandocinject',
                \         'pandocinject')
endfunction

" dn#rc#cdToLocalDir()    {{{1

""
" @public
" Change to local (document) directory.
function! dn#rc#cdToLocalDir() abort
    let b:vrc_initial_cwd = getcwd()
    if expand('%:p') !~? '://'
        lcd %:p:h
    endif
endfunction

" dn#rc#configureAle()    {{{1

""
" @public
" Configure the ALE linter plugin. This function is intended to be called
" before the plugin is loaded.
function! dn#rc#configureAle() abort
    " leave completion for CoC    {{{2
    let g:ale_disable_lsp = 1  " required before loading ALE
    " global fixers    {{{2
    let g:ale_fix_on_save = 1
    let g:ale_fixers = {
                \ '*': ['remove_trailing_lines', 'trim_whitespace'],
                \ }    " }}}2
endfunction

" dn#rc#configureCoc()    {{{1

""
" @public
" Configure the CoC (Conqueror of Completion) plugin. This function is
" intended to be called before the plugin is loaded.
function! dn#rc#configureCoc() abort
    " extensions to install    {{{2
    " - on initialisation CoC will try to install any
    "   listed extension not already installed
    " - extension names indicate associated file type except for:
    "   eslint = javascript, jedi = python, texlab = latex
    let g:coc_global_extensions = [
                \ 'coc-css',
                \ 'coc-eslint',
                \ 'coc-git',
                \ 'coc-go',
                \ 'coc-html',
                \ 'coc-html-css-support',
                \ 'coc-java',
                \ 'coc-jedi',
                \ 'coc-json',
                \ 'coc-perl',
                \ 'coc-rls',
                \ 'coc-sh',
                \ 'coc-sumneko-lua',
                \ 'coc-texlab',
                \ 'coc-toml',
                \ 'coc-vimlsp',
                \ 'coc-xml',
                \ 'coc-yaml',
                \ ]
    " global fixers    {{{2
    let g:ale_fix_on_save = 1
    let g:ale_fixers = {
                \ '*': ['remove_trailing_lines', 'trim_whitespace'],
                \ }    " }}}2
endfunction

" dn#rc#configureDenite()    {{{1

""
" @public
" Configure the following sources in the denite plugin with
" |denite#custom#source()|:
" * grep sources to use a fuzzy matcher
" * buffer and (recursive) files sources to sort by rank
function! dn#rc#configureDenite() abort
    if exists('*denite#custom#source')
        call denite#custom#source('grep', 'matchers',
                    \             ['matcher_fuzzy'])
        call denite#custom#source('buffer,file,file_rec', 'sorters',
                    \             ['sorter_rank'])
    endif
endfunction

" dn#rc#configureWinPython()    {{{1

""
" @public
" Ensure python is correctly configured in nvim for Windows. This function
" attempts to set the |g:python_host_prog| and |g:python3_host_prog|
" variables.
" Recommended usage:
" >
"   if dn#rc#isNvim && dn#rc#os ==# 'windows'
"       call dn#rc#configureWinPython()
"   endif
" <
function! dn#rc#configureWinPython()
    let l:path = expand('$APPDATA') . '\Local\Programs\Python'
    " python2
    let l:exe = l:path . '\Python27\python.exe'
    if filereadable(l:exe) | let g:python_host_prog = l:exe | endif
    " python3
    let l:exes = [l:path . '\Python35-32\python.exe',
                \ l:path . '\Python35-64\python.exe']
    for l:exe in l:exes
        if filereadable(l:exe)
            let g:python3_host_prog = l:exe
            break
        endif
    endfor
endfunction

" dn#rc#createDir(path)    {{{1

""
" @public
" Attempt to create a directory {path} using perl. Return bool indicating
" whether the operation is successful.
" Will accept a relative or absolute directory {path} but relative paths are
" inherently more risky.
" If an invalid {path} is provided, i.e., non |String| variable or an
" empty string, will generate the error message:
" 'Invalid directory path provided'.
" If perl is not available will write the following |hl-WarningMsg| and exit
" as unsuccessful:
" 'Perl not available - unable to create directory path: DIR_PATH'.
" If the perl module File:Path is not available will write the following
" |hl-WarningMsg| and exit as unsuccessful:
" 'Perl module File::Path not available - unable to create directory path:
" DIR_PATH'.
" If the directory {path} already exists, exit indicating success.
" In the event of creation failure will write the following |hl-WarningMsg| to
" |message-history| and exit as unsuccessful:
" 'Unable to create directory path: DIR_PATH'.
" Any shell feedback is also written.
function dn#rc#createDir(path) abort
    " check the path argument    {{{2
    if type(a:path) != type('') || a:path ==? ''
        echoerr 'Invalid directory path provided'
    endif
    " if dir path already exists then done    {{{2
    if isdirectory(a:path) | return v:true | endif
    " need perl    {{{2
    let l:cmd = 'perl -v'
    let l:feedback = systemlist(l:cmd)
    if v:shell_error
        let l:err = [ 'Perl not available - unable to create directory path:',
                    \ '  ' . a:path]
        call dn#rc#warn(l:err)
        return v:false
    endif
    " need perl module File::Path    {{{2
    let l:cmd = 'perl -MFile::Path -e 1'
    let l:feedback = systemlist(l:cmd)
    if v:shell_error
        let l:err = [ 'Perl module File::Path not available',
                    \ 'Unable to create directory path:',
                    \ '  ' . a:path]
        call dn#rc#warn(l:err)
        return v:false
    endif
    " create directory path    {{{2
    let l:cmd =   'perl -MFile::Path -e ''use File::Path qw(make_path); '
                \ . 'make_path("' . a:path . '")'''
    let l:feedback = systemlist(l:cmd)
    if !isdirectory(a:path)
        let l:err = [ 'Unable to create directory path:',
                    \ '  ' . a:path]
        if !empty(l:feedback)
            call map(l:feedback, '"  " . v:val')
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return v:false
    else
        return v:true  " success
    endif    " }}}2
endfunction

" dn#rc#cygwin()    {{{1

""
" @public
" Detemine whether vim is currently running under Cygwin, a Unix-like
" environment and command-line interface for Microsoft Windows. Returns a
" bool.
function! dn#rc#cygwin() abort
    if executable('uname') != 1 | return v:false | endif
    return system('uname -o') =~# '^Cygwin'
endfunction

" dn#rc#error(messages)    {{{1

""
" @public
" Display error {messages} using |hl-ErrorMsg| highlighting. The messages are
" expected to be a string or a |List| of |Strings|. Any other types of value
" are stringified with |string()|.
" Note that if there is more than one message vim will pause after displaying
" them until the user presses Enter. 
" Uses |:echomsg| to ensure messages are saved to the |message-history|. There
" is no return value.
function! dn#rc#error(messages) abort
    " convert to list of strings
    " - cannot pass string to string() because it encloses in single quotes
    let l:messages = []
    let l:type = type(a:messages)
    if l:type == v:t_list
        for l:item in a:messages
            if type(l:item) == v:t_string
                call add(l:messages, l:item)
            else
                call add(l:messages, string(l:item))
            endif
        endfor
    elseif l:type == v:t_string
        call add(l:messages, l:item)
    else
        call add(l:messages, string(l:item))
    endif
    " display messages
    echohl ErrorMsg
    for l:message in l:messages | echomsg l:message | endfor
    echohl None
    return
endfunction

" dn#rc#exceptionError(exception)    {{{1

""
" @public
" Extracts the error message from a vim {exception}, i.e., a vim
" |exception-variable|.
function! dn#rc#exceptionError(exception) abort
    let l:matches = matchlist(a:exception,
                \             '^Vim\%((\a\+)\)\=:\(E\d\+\p\+$\)')
    return (!empty(l:matches) && !empty(l:matches[1])) ? l:matches[1]
                \                                      : a:exception
endfunction

" dn#rc#gemInstall(package, [name])    {{{1

""
" @public
" Install a ruby {package} with gem. User can optionally provide a [short]
" name for the package (no default). The installer is run using 'sudo' so this
" must be configured appropriately in the operating system. It also means this
" may fail on non-unix systems. Returns bool indicating whether package was
" successfully installed.
function! dn#rc#gemInstall(package, ...) abort
    let l:name = (a:0 && a:1 !=? '') ? a:1 : a:package
    " check gem installer is available
    if !executable('gem')
        let l:err = [ "Installer 'gem' is not available",
                    \ "Cannot install ruby package '" . l:name . "'"]
        call dn#rc#warn(l:err)
        return v:false
    endif
    " check gem installer can be run as sudo
    let l:feedback = systemlist('sudo gem -v')
    if v:shell_error
        let l:err = ["Unable to run 'gem' using 'sudo'"]
        if !empty(l:feedback)
            call map(l:feedback, '"  " . v:val')
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return v:false
    endif
    " do we install or update, i.e., is it already installed
    let l:installed = systemlist(
                \ 'sudo gem list --local --installed --exact --quiet '
                \ . a:package)
    let l:operation = (len(l:installed) == 1 && l:installed[0] ==# 'true')
                \ ? 'install'
                \ : 'update'
    " install/update
    let l:feedback = systemlist('sudo gem ' . l:operation . ' ' . a:package)
    if v:shell_error
        let l:err = ['Unable to ' . l:operation . ' ' . l:name . ' with gem']
        if !empty(l:feedback)
            call map(l:feedback, '"  " . v:val')
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return v:false
    else
        return v:true  " succeeded
    endif
endfunction

" dn#rc#hasPluginManagerRequirements()    {{{1

""
" @public
" Checks for tools required by the plugin manager: curl and git. Displays an
" error message if any are missing. Return a bool indicating whether all
" required tool are available.
function! dn#rc#hasPluginManagerRequirements() abort
    let l:err = []  " use as flag and error message
    " check for required tools: curl, git
    let l:tools = ['curl', 'git']
    let l:missing = filter(copy(l:tools), '!executable(v:val)')
    if !empty(l:missing)
        call extend(l:err, [
                    \ 'Plugin handler requires: ' . join(l:tools, ', '),
                    \ 'Cannot locate: ' . join(l:missing, ', ')])
    endif
    " check for required version: vim >= 7.0
    if dn#rc#isVim()
        let l:version = v:version
        if l:version < 700
            call extend(l:err, [
                        \ 'This instance of vim is version' . l:version,
                        \ 'Plugin handler requires vim 7.0 or higher'])
        endif
    endif
    " return result and report any errors if detected
    if empty(l:err)  " all checks succeeded
        return v:true
    else  " errors detected
        call extend(l:err, ['Aborting vim configuration file execution'])
        call dn#rc#warn(l:err)
        return v:false
    endif
endfunction

" dn#rc#installMissingPlugins()    {{{1

""
" @public
" Install missing plugins. Assumes the plugin manager is vim-plug.
function! dn#rc#installMissingPlugins() abort
    if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
        execute 'PlugInstall --sync'
        source $MYVIMRC
    endif
endfunction

" dn#rc#installPluginManager()    {{{1

""
" @public
" Install vim-plug plugin manager. Prints feedback and returns a boolean
" indicating whether installation was successful.
function! dn#rc#installPluginManager() abort
    let l:url = 'https://raw.githubusercontent.com/junegunn'
                \ . '/vim-plug/master/plug.vim'
    let l:dir = dn#rc#pluginRoot('vim-plug')
    let l:cmd = 'curl -fLo ' . l:dir . ' --create-dirs ' . l:url
    let l:feedback = systemlist(l:cmd)
    if !v:shell_error  " succeeded
        return v:true
    else  " failed
        let l:err = 'Unable to install vim-plug plugin manager using curl'
        if !empty(l:feedback)
            call map(l:feedback, '"  " . v:val')
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#error(l:err)
        return v:false
    endif
endfunction

" dn#rc#isNvim()    {{{1

""
" @public
" Returns a boolean indicating whether neovim is running (rather than vim).
" Relies on "has('nvim')" being true in nvim but not vim. A previous test
" relied on the |:terminal| command being available in nvim and not vim (which
" had the |:shell| command). Now, however, both vim and nvim have both
" commands.
function! dn#rc#isNvim() abort
    return has('nvim')
endfunction

" dn#rc#isVim()    {{{1

""
" @public
" Returns a boolean indicating whether neovim is running (rather than vim).
" Relies on "has('nvim')" being true in nvim but not vim. A previous test
" relied on the |:terminal| command being available in nvim and not vim (which
" had the |:shell| command). Now, however, both vim and nvim have both
" commands.
function! dn#rc#isVim() abort
    return !has('nvim')
endfunction

" dn#rc#lintEngine()    {{{1

""
" @public
" Return the linter engine to use. Calls function
" @function(dn#rc#setLintEngine) if the linter engine has not been set.
function! dn#rc#lintEngine() abort
    if s:lint_engine is v:null | call dn#rc#setLintEngine() | endif
    return s:lint_engine
endfunction

" dn#rc#message(message, [clear])    {{{1

""
" @public
" Display a |String| {message} in the command line. If [clear] is present and
" true, the message is cleared after a brief delay.
function! dn#rc#message(message, ...) abort
	let l:insert = (mode() ==# 'i')
	if mode() ==# 'i' | execute "normal \<Esc>" | endif
	echohl ModeMsg | echo a:message | echohl Normal
    if a:0 > 0 && a:1 | sleep 1 | execute "normal :\<BS>" | endif
    if l:insert | execute 'normal! l' | startinsert | endif
endfunction

" dn#rc#npmInstall(package, [short])    {{{1

""
" @public
"
" Install a node {package} with npm. User can optionally provide a [short]
" name for the package (no default). Packages are installed in global mode.
"
" npm requires node.js which is no longer supported on Cygwin, so if vim is
" running under Cygwin display error and abort install attempt.
" 
" Returns bool indicating whether package was successfully installed.
function! dn#rc#npmInstall(package, ...) abort
    let l:retval = 0
    let l:name = (a:0 && a:1 !=? '') ? a:1 : a:package
    if dn#rc#cygwin()  " cannot install under Cygwin
        let l:err = [ 'Vim appears to be running under Cygwin',
                    \ "Installer 'npm' requires 'node.js', which is not "
                    \ . ' supported on Cygwin',
                    \ "Unable to install package'" . l:name . "'"]
        call dn#rc#warn(l:err)
        return v:false
    endif
    if !executable('npm')  " must have npm
        let l:err = [ "Installer 'npm' is not available",
                    \ "Cannot install node package '" . l:name . "'"]
        call dn#rc#warn(l:err)
        return v:false
    endif
    let l:feedback = systemlist('npm --global install ' . a:package)
    if v:shell_error
        let l:err = ['Unable to install ' . l:name . ' with npm']
        if !empty(l:feedback)
            call map(l:feedback, '"  " . v:val')
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return v:false
    endif
    let l:feedback = systemlist('npm --global update ' . a:package)
    if v:shell_error
        let l:err = ['Unable to update ' . l:name . ' with npm']
        if !empty(l:feedback)
            call map(l:feedback, '"  " . v:val')
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return v:false
    else
        return v:true  " succeeded
    endif
endfunction
" dn#rc#os()    {{{1

""
" @public
" Determine operating system. Returns |String| value "windows", "unix" or
" "other".
function! dn#rc#os() abort
    if has('win32') || has ('win64') || has('win95') || has('win32unix')
        return 'windows'
    elseif has('unix') | return 'unix'
    else               | return 'other'
    endif
endfunction

" dn#rc#pandocOpen(file)    {{{1

""
" @public
" A function used by pandoc to open a created output file. See
" |g:pandoc#command#custom_open| for further details.
function! dn#rc#pandocOpen(file) abort
    return 'xdg-open ' . shellescape(expand(a:file,':p'))
endfunction

" dn#rc#panderPath()    {{{1

""
" @public
" Provide path to pander support directory.
function! dn#rc#panderPath() abort
    let l:os = dn#rc#os()
    let l:home = escape($HOME, ' ')
    if     l:os ==# 'windows' | return resolve(
                \                      expand('~/AppData/Local/pander'))
    elseif l:os ==# 'unix'    | return l:home . '/.config/pander'
    else                      | return l:home . '/.config/pander'
    endif
endfunction

" dn#rc#perlContrib()    {{{1

""
" @public
" Copy the following files from the vim-perl plugin's contrib directory into
" the directory $VIMHOME/after/syntax/perl/:
" * carp.vim
" * function-parameters.vim
" * highlight-all-pragmas.vim
" * moose.vim
" * try-tiny.vim
"
" Also writes the following file to the same directory to provide syntax
" support for the Readonly keyword:
" * readonly.vim
function dn#rc#perlContrib() abort
    " variables    {{{2
    let l:contrib = dn#rc#pluginRoot('vim-perl') . '/contrib'
    let l:after = dn#rc#vimPath('home') . '/after/syntax/perl'
    if !isdirectory(l:contrib)
        let l:err = [ "Cannot find perl-vim plugin's 'contrib' directory at:",
                    \ '  ' . l:contrib]
        call dn#rc#warn(l:err)
        return v:false
    endif
    if !isdirectory(l:after) && !dn#rc#createDir(l:after)
        let l:err = 'Unable to move perl contrib syntax files to ' . l:after
        call dn#rc#warn(l:err)
        return v:false
    endif
    let l:files = ['highlight-all-pragmas.vim', 'function-parameters.vim',
                \  'carp.vim', 'moose.vim', 'try-tiny.vim']
    let l:custom = l:after . '/dn-custom.vim'
    let l:errors = v:false  " flag indicting whether errors occur    }}}2
    " copy contrib syntax files    {{{2
    let l:copy_err = []
    for l:file in l:files
        " set source and target filepaths    {{{3
        let l:source = l:contrib . '/' . l:file
        let l:target = l:after . '/' . l:file
        if empty(glob(l:source))
            call extend(l:copy_err, ['Cannot find contrib file:',
                        \            '  ' . l:source])
            continue
        endif
        " read source file    {{{3
        try   | let l:content = readfile(l:source, 'b')
        catch | call extend(l:copy_err,
                    \       ['Error reading ' . l:source,
                    \        '  ' . dn#rc#exceptionError(v:exception)])
        endtry
        if empty(l:content)
            call extend(l:copy_err, ['Unable to read contrib file:',
                        \            '  ' . l:source])
            continue
        endif
        " write target file    {{{3
        if exists('l:retval') | unlet l:retval | endif
        try   | let l:retval = writefile(l:content, l:target, 'bs')
        catch | call extend(l:copy_err,
                    \       ['Error writing ' . l:target,
                    \        '  ' . dn#rc#exceptionError(v:exception)])
        endtry
        if !exists('l:retval') || l:retval == -1  " success: 0, failure: -1
            call extend(l:copy_err, ['Unable to write syntax file:',
                        \            '  ' . l:target])
            continue
        endif    " }}}3
    endfor
    let l:errors = !empty(l:copy_err)
    " write custom syntax file    {{{2
    let l:custom_err = []
    if exists('l:retval') | unlet l:retval | endif
    try   | let l:retval = writefile(s:perl_syntax, l:custom, 's')
    catch | call extend(l:custom_err,
                \       ['Error writing ' . l:custom,
                \        '  ' . dn#rc#exceptionError(v:exception)])
    endtry
    if !exists('l:retval') || l:retval == -1  " success: 0, failure: -1
        call extend(l:custom_err, ['Unable to write custom syntax file:',
                    \              '  ' . l:custom])
    endif
    if !l:errors && !empty(l:custom_err) | let l:errors = v:true | endif
    " display error messages if any    {{{2
    if l:errors  " failures occurred
        if !empty(l:copy_err)
            let l:copy_err = [
                        \ 'Failures occurred copying syntax files '
                        \ . 'from perl-vim contrib directory',
                        \ '  ' . l:contrib,
                        \ '  to local after directory ' . l:after
                        \ ]
                        \ + l:copy_err
        endif
        if !empty(l:custom_err)
            let l:custom_err = [
                        \ 'Failure writing custom syntax file to',
                        \ '  ' . l:custom
                        \ ]
                        \ + l:custom_err
        endif
        call dn#rc#warn(l:copy_err + l:custom_err)
        return v:false
    else  " success
        return v:true
    endif    " }}}2
endfunction

" dn#rc#perlModuleInstalled(module)    {{{1

""
" @public
" Determine whether a perl {module} is installed on the current system.
" @throws BadArg if argument is non-string or empty string
" @throws NoPerl if unable to find perl executable
function! dn#rc#perlModuleInstalled(module) abort
    " check arg
    let l:arg_type = dn#util#varType(a:module)
    let l:err = 'ERROR(BadArg): Expected string arg, got '. l:arg_type
    if l:arg_type !=# 'string' | throw l:err | endif
    if empty(a:module) | throw 'ERROR(BadArg): Empty argument' | endif
    " need perl
    let l:err = 'ERROR(NoPerl): Cannot find perl executable'
    if !executable('perl') | throw l:err | endif
    " check for module
    let l:cmd = 'perl' . '-M'.a:module . '-e 1 2>/dev/null'
    call system(l:cmd)
    " report result
    return !v:shell_error
endfunction

" dn#rc#perlModuleInstallUpdate(module)    {{{1

""
" @public
" Install/update a perl {module} on the current system. The command used is:
" >
"   cpanm Module::Name &> /dev/null
" <
" Any cpanm configuration must be done via the PERL_CPANM_HOME and
" PERL_CPANM_OPT environment variables. See the cpanm manpage for further
" information.
" @throws BadArg if argument is non-string or empty string
" @throws NoCpanm if unable to find cpanm executable
function! dn#rc#perlModuleInstallUpdate(module) abort
    " check arg
    let l:arg_type = dn#util#varType(a:module)
    let l:err = 'ERROR(BadArg): Expected string arg, got '. l:arg_type
    if l:arg_type !=# 'string' | throw l:err | endif
    if empty(a:module) | throw 'ERROR(BadArg): Empty argument' | endif
    " need cpanm
    let l:err = 'ERROR(NoCpanm): Cannot find cpanm executable'
    if !executable('cpanm') | throw l:err | endif
    " install/update module
    let l:cmd = ['cpanm', a:module, '&>', '/dev/null']
    call system(l:cmd)
    " report result
    return !v:shell_error
endfunction

" dn#rc#pipInstall(package, [short])    {{{1

""
" @public
" Install a python {package} with pip. User can optionally provide a [short]
" name for the package (no default). Returns bool indicating whether package
" was successfully installed.
function! dn#rc#pipInstall(package, ...) abort
    let l:name = (a:0 && a:1 !=? '') ? a:1 : a:package
    let l:installers = ['pip3', 'pip']
    let l:installer_available = v:false
    for l:installer in l:installers
        if executable(l:installer)
            let l:installer_available = v:true
        endif
    endfor
    if !l:installer_available
        let l:err = [ 'No python installers (' . join(l:installers, ', ')
                    \ . ') available',
                    \ 'Cannot install python package ' . l:name]
        call dn#rc#warn(l:err)
        return v:false
    endif
    for l:installer in l:installers
        if !executable(l:installer) | continue | endif
        let l:install_cmd = l:installer . ' install --upgrade ' . a:package
        let l:feedback = systemlist(l:install_cmd)
        if v:shell_error
            let l:err = [ "Unable to install package '" . l:name
                        \ . "' with " . l:installer]
            if !empty(l:feedback)
                call map(l:feedback, '"  " . v:val')
                call extend(l:err, ['Error message:'] + l:feedback)
            endif
            call dn#rc#warn(l:err)
            return v:false
        else
            return v:true  " succeeded
        endif
    endfor
endfunction

" dn#rc#pluginCmdsAdd(cmd)    {{{1

""
" @public
" Adds {cmd} to the |List| of commands to be executed once the plugin system
" is initialised, i.e., all initial plugin loading is complete.
" Note: these commands may be executed before a conditional plugin is loaded,
" so they should only be defined for plugins which load unconditionally.
" Note: these commands may be executed multiple times so they should be
" idempotent.
function! dn#rc#pluginCmdsAdd(cmd) abort
    call add(s:plugin_cmds, a:cmd)
endfunction

" dn#rc#pluginCmdsClear()    {{{1

""
" @public
" Deletes all existing commands defined for execution following initialisation
" of the plugin system.
function! dn#rc#pluginCmdsClear() abort
    let s:plugin_cmds = []
endfunction

" dn#rc#pluginCmdsExecute()    {{{1

""
" @public
" Executes all commands defined for execution following initialisation of the
" plugin system.
" Note: these commands may be executed before a conditional plugin is loaded,
" so they should only be defined for plugins which load unconditionally.
" Note: these commands may be executed multiple times so they should be
" idempotent.
function! dn#rc#pluginCmdsExecute() abort
    for l:cmd in s:plugin_cmds
        execute l:cmd
    endfor
endfunction

" dn#rc#pluginRoot(plugin)    {{{1

""
" @public
" Provide root directory of named {plugin}. The {plugin} names currently
" supported are:
" * "vim-plug"
" * "dn-perl" or "vim-dn-perl"
" * "vim-perl"
function! dn#rc#pluginRoot(plugin) abort
    if type(a:plugin) != type('')
        echoerr 'Plugin name is not a string'
    endif
    if     count(['vim-plug'], a:plugin)
        return resolve(expand('~/.vim/autoload/plug.vim'))
    elseif count(['dn-perl', 'vim-dn-perl'], a:plugin)
        return dn#rc#pluginsDir() . '/vim-dn-perl'
    elseif count(['vim-perl'], a:plugin)
        return dn#rc#pluginsDir() . '/vim-perl'
    else
        echoerr "Invalid plugin name '" . a:plugin . "'"
    endif
endfunction

" dn#rc#pluginsDir()    {{{1

""
" @public
" Provide plugins directory.
function! dn#rc#pluginsDir() abort
    return dn#rc#vimPath('plug')
endfunction

" dn#rc#removeAugroupEunuch()    {{{1

""
" @public
" Remove the augroup "eunuch" if it exists.
function! dn#rc#removeAugroupEunuch() abort
    if exists('#eunuch')
        augroup! eunuch
    endif
endfunction

" dn#rc#saveOnFocusLost()    {{{1

""
" @public
" This function is designed to be called by an |:autocmd| when the |FocusLost|
" event occurs. For example:
" >
"   autocmd FocusLost * call dn#rc#saveOnFocusLost()
" <
" Attempting to write a buffer that is not associated with a file causes vim
" error |E141|. This function catches and ignores that error.
function! dn#rc#saveOnFocusLost() abort
    " E141 = no file name for buffer
    try
        :wall
    catch /^Vim\((\a\+)\)\=:E141:/ |
    endtry
endfunction

" dn#rc#setColorScheme(gui, terminal)    {{{1

""
" @public
" Set colour scheme. A colour scheme is nominated for {gui} versions of vim,
" e.g., gvim, and {terminal} versions of vim. In the following list the
" argument value is followed by the colorscheme name in brackets, then
" argument(s) the value can be used for, plus the 'background' setting used,
" if any.
"
" For example, "papercolor (PaperColor) - gui (dark), terminal (dark)" means
" that "papercolor" is a valid argument for both {gui} and {terminal}
" arguments, the colorscheme that is set is "PaperColor", and the 'background'
" is set to "dark" in both gui and terminal versions of vim.
" values for these arguments includes in brackets the associddated colorscheme
"
" * atelierforest (base16-atelierforest) . gui
" * atelierheath (base16-atelierheath) ... gui
" * desert (desert) ...................... gui ...... | terminal
" * hybrid (hybrid) ...................... gui ...... | terminal
" * lucius (lucius) ...................... gui ...... | terminal
" * neosolarized (neosolarized) .......... gui (dark) | terminal
" * papercolor (PaperColor) .............. gui (dark) | terminal (dark)
" * peaksea (peaksea) .................... gui (dark) | terminal
" * railscasts (railscasts) .............. gui ...... | terminal
" * solarized (solarized) ................ gui (dark) | terminal
" * zenburn (zenburn) .................... gui ...... | terminal
function! dn#rc#setColorScheme(gui, terminal) abort
    if has('gui_running')    " gui
        if     a:gui ==# 'atelierforest' | colorscheme base16-atelierforest
        elseif a:gui ==# 'atelierheath'  | colorscheme base16-atelierheath
        elseif a:gui ==# 'desert'        | colorscheme desert
        elseif a:gui ==# 'gruvbox'       | colorscheme gruvbox
            set background=dark
        elseif a:gui ==# 'hybrid'
            let g:hybrid_use_Xresources = 1
            colorscheme hybrid
        elseif a:gui ==# 'lucius'        | colorscheme lucius
            "LuciusDark|LuciusDarkHighContrast|LuciusDarkLowContrast|
            "LuciusBlack|LuciusBlackHighContrast|LuciusBlackLowContrast|
            "LuciusLight|LuciusLightLowContrast|
            "LuciusWhite|LuciusWhiteLowContrast|
            "LuciusDarkLowContrast
        elseif a:gui ==# 'neosolarized'  | colorscheme neosolarized
            set background=dark
        elseif a:gui ==# 'papercolor'
            set background=dark
            set t_Co=256
            colorscheme PaperColor
        elseif a:gui ==# 'peaksea'       | colorscheme peaksea
            set background=dark
        elseif a:gui ==# 'railscasts'    | colorscheme railscasts
        elseif a:gui ==# 'solarized'     | colorscheme solarized
            set background=dark
        elseif a:gui ==# 'zenburn'       | colorscheme zenburn
        else
            echoerr "Invalid gui colorscheme '" . a:gui . "'"
        endif
    else    " no gui, presumably terminal/console
        set t_Co=256    " improves all themes in terminals
        if     a:terminal ==# 'desert'       | colorscheme desert
        elseif a:terminal ==# 'gruvbox'      | colorscheme gruvbox
            set background=dark
        elseif a:terminal ==# 'hybrid'
            let g:hybrid_use_Xresources = 1
            colorscheme hybrid
            let g:colors_name = 'hybrid'
        elseif a:terminal ==# 'lucius'       | colorscheme lucius
            "LuciusDark|LuciusDarkHighContrast|LuciusDarkLowContrast
            "LuciusBlack|LuciusBlackHighContrast|LuciusBlackLowContrast
            "LuciusLight|LuciusLightLowContrast
            "LuciusWhite|LuciusWhiteLowContrast
            "LuciusLightLowContrast
        elseif a:terminal ==# 'neosolarized' | colorscheme neosolarized
        elseif a:terminal ==# 'papercolor'   | colorscheme PaperColor
            set background=dark
        elseif a:terminal ==# 'peaksea'      | colorscheme peaksea
        elseif a:terminal ==# 'railscasts'   | colorscheme railscasts
        elseif a:terminal ==# 'solarized'    | colorscheme solarized
        elseif a:terminal ==# 'zenburn'      | colorscheme zenburn
        else
            echoerr "Invalid terminal colorscheme '" . a:terminal . "'"
        endif
    endif
endfunction

" dn#rc#setLintEngine()    {{{1

""
" @public
" Sets linter engine to use. This previously used a much more complex
" algorithm. Now it simply sets the linter engine to 'ale'.
function! dn#rc#setLintEngine() abort
    let s:lint_engine = 'ale'
endfunction

" dn#rc#source(directory, self)    {{{1

""
" @public
" Recursively source vim files in {directory}. {self} is the resolved filepath
" of the calling script. This is an example:
" >
"   let s:dir = dn#rc#vimPath('home').'/rc'
"   call dn#rc#source(s:dir, resolve(expand('<sfile>:p')))
" <
" Prints error message and returns if {directory} path is invalid. Only
" sources vim files, more specifically, if running vim source *.vim files and
" if running nvim source *.vim and *.nvim files.
function! dn#rc#source(dir, self) abort
    " dir must exist
    let l:dir = resolve(expand(a:dir))
    if !isdirectory(l:dir)
        echoerr "Invalid source directory '" . l:dir . "'"
    endif
    " recursively process directory contents
    for l:path in glob(l:dir . '/**', 1, 1)
        " ignore if not file
        let l:type = getftype(l:path)
        if l:type !~# 'file\|link' | continue | endif
        " resolve links
        let l:path = (l:type ==# 'link') ? resolve(l:path) : l:path
        " avoid infinite recursion - do not source self!
        if l:path ==# a:self | continue | endif
        " must be vim file
        " - for vim source *.vim; for nvim source *.vim and *.nvim
        let l:match = dn#rc#isVim() ? '^\p\+\.vim$' : '^\p\+\.n\?vim$'
        if fnamemodify(l:path, ':t') =~? l:match
            execute 'source' l:path
        endif
    endfor
    return
endfunction

" dn#rc#spellStatus()    {{{1

""
" @public
" Display spell check status.
function! dn#rc#spellStatus() abort
    let l:msg = 'spell checking is '
    if &spell | let l:msg .= 'ON (lang=' . &spelllang . ')'
    else      | let l:msg .= 'OFF'
    endif
    call dn#rc#message(l:msg, 1)
endfunction

" dn#rc#spellToggle()    {{{1

""
" @public
" Toggle spell checking and display new status.
function! dn#rc#spellToggle() abort
    setlocal spell!
    redraw
    call dn#rc#spellStatus()
endfunction

" dn#rc#symlinkWarning()    {{{1

""
" @setting b:vrc_initial_cfp
" This variable is used by @function(dn#rc#symlinkWarning) if it is set by the
" user in their startup configuration. The variable is intended to contain the
" filepath provided by the user when opening a file. It is surprisingly
" difficult to capture as |resolve()|, and |expand()| and |fnamemodify()| with
" ':p', all resolve symlinks in filepaths. One way to do it is to expand '%'
" (|:_%|) at buffer read time. For example:
" >
"   autocmd BufNewFile,BufReadPost *
"                  \ let b:vrc_initial_cfp = simplify(expand('%'))
" <
" The 'cfp' in the variable name is derived from 'current file path'. This
" mnemonic may or may not be helpful in remembering the variable name.

""
" @setting b:vrc_initial_cwd
" This variable is used by @function(dn#rc#symlinkWarning), if present, when
" the current directory has been changed by |:lcd| or |:tcd|. It is intended
" to capture the original current directory before it was changed. For
" example, execute the following command before either |:lcd| or |:tcd|:
" >
"   let b:vrc_initial_cwd = getcwd()
" <
" The 'cwd' in the variable name is derived from 'current working directory'.
" This mnemonic may or may not be helpful in remembering the variable name.

""
" @public
" Display warning if opening a file whose path contains a symlink.
"
" This function relies on one (or two) values being captured in buffer
" variables by other parts of the startup configuration:
"
" First is the file path specified by the user on the command line, which is
" captured in 'b:vrc_initial_cfp'. This path is surprisingly difficult to
" capture as |resolve()|, and |expand()| and |fnamemodify()| with ':p', all
" resolve symlinks in filepaths. One way to do it is to expand '%' (|:_%|) at
" buffer read time. For example:
" >
"   autocmd BufNewFile,BufReadPost *
"                  \ let b:vrc_initial_cfp = simplify(expand('%'))
" <
" Second, if the current directory has been changed by |:lcd| or |:tcd| then
" the original current directory needs to be captured in 'b:vrc_initial_cwd'.
" For example:
" >
"   let b:vrc_initial_cwd = getcwd()
" <
" If either variable is missing when it is required, the function exits and
" the symlink check is aborted silently.
"
" This test is performed only once per file per buffer, even if an associated
" event is triggered multiple times.
function! dn#rc#symlinkWarning() abort
    " only do this once
    if exists('b:checked_symlink') && b:checked_symlink | return | endif
    let b:checked_symlink = v:true
    " only check certain buffers:
    " - buffer must be associated with a file
    if empty(bufname('%')) | return | endif
    " - must be a normal buffer (buftype == "")
    if !empty(getbufvar('%', '&buftype')) | return | endif
    " first do simple check for whether file is a symlink
    let l:file_path = fnameescape(expand('<afile>:p'))
    let l:file_name = fnamemodify(l:file_path, ':t')
    if getftype(l:file_path) ==# 'link'
        let l:real_path = resolve(l:file_path)
        let l:msg = []
        call add(l:msg, 'Buffer file is a symlink')
        call add(l:msg, '- file path: ' . l:file_path)
        call add(l:msg, '- real path: ' . l:real_path)
        call add(l:msg, ' ')  " so file name does not obscure last line
        call dn#rc#warn(l:msg)
        return
    endif
    " if file is not symlink, check for symlink in full file path
    " - requires b:vrc_initial_cfp
    if !exists('b:vrc_initial_cfp') | return | endif
    " - requires b:vrc_initial_cwd if current directory has been changed
    let l:file_path = ''
    if haslocaldir()
        " then initial cwd was changed with :lcd or :tcd
        " - need b:vrc_initial_cwd
        if !exists('b:vrc_initial_cwd') | return | endif
        let l:file_path = b:vrc_initial_cwd . '/' . l:file_name
    else
        " initial cwd has not been altered
        let l:file_path = getcwd() . '/' . l:file_name
    endif
    let l:real_path = resolve(l:file_path)
    if l:file_path !=# l:real_path
        let l:msg = []
        call add(l:msg, 'Buffer file path includes at least one symlink')
        call add(l:msg, '- file path: ' . l:file_path)
        call add(l:msg, '- real path: ' . l:real_path)
        call add(l:msg, ' ')  " so file name does not obscure last line
        call dn#rc#warn(l:msg)
    endif
endfunction

" dn#rc#tagPlugin(directory)    {{{1

""
" @public
" Returns the tag plugin to load: either "gen_tags" or "easytags" (or |v:null|
" if neither is usable). Plugin "gen_tags" requires executables "global" and
" "gtags", while plugin "easytags" requires executable "ctags". Plugin
" "gen_tags" is preferred over "easytags" if both are usable. This preference
" order is reversed, i.e., plugin "easytags" is preferred over "gen_tags", if
" the file "vimrc_prefer_easytags" is present in {directory}.
" An example of calling this function is:
" > 
"   if dn#rc#tagPlugin('<sfile>:p:h') ==# 'easytags' | ...
" <
function! dn#rc#tagPlugin(directory) abort
    let l:prefer_easytags_file = a:directory . '/.vimrc_prefer_easytags'
    let l:prefer_easytags = !empty(glob(l:prefer_easytags_file))
    let l:usable = {'gen_tags': executable('global') && executable('gtags'),
                \   'easytags': executable('ctags')}
    " satisfy easytags preference if possible...
    if l:prefer_easytags && l:usable.easytags | return 'easytags' | endif
    " ...otherwise use standard preference
    if     l:usable.gen_tags | return 'gen_tags'
    elseif l:usable.easytags | return 'easytags'
    else                     | return v:null
    endif
endfunction

" dn#rc#temp(part)    {{{1

""
" @public
" Sets a temporary file variable "s:temp_path" if not already set. Returns a
" {part} of the file path stored in the variable. {part} can be:
" * "path" - directory path + file name
" * "dir"  - directory path only
" * "file" - file name only
function! dn#rc#temp(part) abort
    if     a:part ==# 'path' | return s:temp_path
    elseif a:part ==# 'dir'  | return fnamemodify(s:temp_path, ':p:h')
    elseif a:part ==# 'file' | return fnamemodify(s:temp_path, ':p:t')
    else
        echoerr "Invalid dn#rc#temp param '" . a:part . "'"
    endif
endfunction

" dn#rc#updateLinters()    {{{1

""
" @public
" Update ale linters:
" * autopep8    - for python
" * flake8      - for python
" * htmlhint    - for html
" * mdl         - for markdown
" * luac        - for lua
" * luacheck    - for lua
" * perlcritic  - for perl5
" * proselint   - for English prose
" * remark-lint - for markdown
" * rubocop     - for ruby
" * stylelint   - for [s]css
" * tidy        - for html
" * vim-vint    - for vimscript
" * write-good  - for English prose
" * yamllint    - for yaml
function! dn#rc#updateLinters() abort
    call dn#rc#updateLinterAutopep8()
    call dn#rc#updateLinterFlake8()
    call dn#rc#updateLinterHtmlhint()
    call dn#rc#updateLinterMdl()
    call dn#rc#updateLinterLuac()
    call dn#rc#updateLinterLuacheck()
    call dn#rc#updateLinterPerlcritic()
    call dn#rc#updateLinterProselint()
    "call dn#rc#updateLinterRemarkLint()
    call dn#rc#updateLinterRubocop()
    call dn#rc#updateLinterStylelint()
    call dn#rc#updateLinterTextlint()
    call dn#rc#updateLinterTidy()
    call dn#rc#updateLinterVimVint()
    call dn#rc#updateLinterWriteGood()
    call dn#rc#updateLinterYamllint()
endfunction

" dn#rc#updateLinterAutopep8()    {{{1

""
" @public
" Update linter autopep8 for python.
function! dn#rc#updateLinterAutopep8() abort
    call dn#rc#pipInstall('autopep8')
endfunction

" dn#rc#updateLinterFlake8()    {{{1

""
" @public
" Update linter flake8 for python. It consists of a python package.
function! dn#rc#updateLinterFlake8() abort
    call dn#rc#pipInstall('flake8')
endfunction

" dn#rc#updateLinterHtmlhint()    {{{1

""
" @public
" Update linter htmlhint for html. It consists of a javascript package (node
" module).
function! dn#rc#updateLinterHtmlhint() abort
    call dn#rc#npmInstall('htmlhint')
endfunction

" dn#rc#updateLinterMdl()    {{{1

""
" @public
" Update linter mdl for markdown. It consists of a ruby package.
function! dn#rc#updateLinterMdl() abort
    call dn#rc#gemInstall('mdl')
endfunction

" dn#rc#updateLinterLuac()    {{{1

""
" @public
" Update linter luac for lua. It is the lua compiler. On debian systems the
" compiler executable is part of a deb package.
function! dn#rc#updateLinterLuac() abort
    if !executable('luac')
        let l:msg = ["Cannot locate executable 'luac'",
                    \ '- ALE will be unable to use it as a lua linter']
        call dn#rc#error([l:msg])
    endif
endfunction

" dn#rc#updateLinterLuacheck()    {{{1

""
" @public
" Update linter luacheck for lua. It consists of an executable. On debian
" systems the executable is part of a deb package.
function! dn#rc#updateLinterLuacheck() abort
    if !executable('luacheck')
        let l:msg = ["Cannot locate executable 'luacheck'",
                    \ '- ALE will be unable to use it as a lua linter']
        call dn#rc#error([l:msg])
    endif
endfunction

" dn#rc#updateLinterPerlcritic()    {{{1

""
" @public
" Update linter perlcritic for perl5. It consists of an executable. On debian
" systems the executable is part of a deb package.
function! dn#rc#updateLinterPerlcritic() abort
    if !executable('perlcritic')
        let l:msg = ["Cannot locate executable 'perlcritic'",
                    \ '- ALE will be unable to use it as a perl linter']
        call dn#rc#error([l:msg])
    endif
endfunction

" dn#rc#updateLinterProselint()    {{{1

""
" @public
" Update linter proselint for English prose. It consists of a python package.
function! dn#rc#updateLinterProselint() abort
    call dn#rc#pipInstall('proselint')
endfunction

" dn#rc#updateLinterRemarkLint()    {{{1

""
" @public
" Update linter remark-lint for markdown. It consists of a javascript package
" (node module). The remark-cli package installs remark-lint and a
" command-line interface.
function! dn#rc#updateLinterRemarkLint() abort
    " the linter
    call dn#rc#npmInstall('remark-cli')
    " rules packages as per:
    " https://tartansandal.github.io/vim/markdown/remark/2021/10/05/vim-remark.html
    " see also configuration file: ~/.remarkrc.yml
    call dn#rc#npmInstall('remark-gfm')
    call dn#rc#npmInstall('remark-preset-lint-recommended')
    call dn#rc#npmInstall('remark-preset-lint-markdown-style-guide')
    call dn#rc#npmInstall('remark-lint-list-item-indent')
    call dn#rc#npmInstall('remark-lint-ordered-list-marker-value')
    call dn#rc#npmInstall('remark-lint-strikethrough-marker')
    call dn#rc#npmInstall('remark-lint-checkbox-content-indent')
    call dn#rc#npmInstall('remark-lint-checkbox-character-style')
    call dn#rc#npmInstall('remark-lint-linebreak-style')
    call dn#rc#npmInstall('remark-lint-unordered-list-marker-style')
    call dn#rc#npmInstall('remark-lint-no-missing-blank-lines')
    call dn#rc#npmInstall('remark-lint-link-title-style')
    call dn#rc#npmInstall('remark-lint-first-heading-level')
    call dn#rc#npmInstall('remark-lint-no-heading-indent')
    call dn#rc#npmInstall('remark-lint-no-heading-like-paragraph')
    call dn#rc#npmInstall('remark-lint-no-duplicate-headings-in-section')
    call dn#rc#npmInstall('remark-lint-no-paragraph-content-indent')
endfunction

" dn#rc#updateLinterRubocop()    {{{1

""
" @public
" Update linter rubocop for ruby. It consists of a ruby package.
function! dn#rc#updateLinterRubocop() abort
    call dn#rc#gemInstall('rubocop')
endfunction

" dn#rc#updateLinterStylelint()    {{{1

""
" @public
" Update linter stylelint for css and scss. It consists of a javascript
" package (node module).
function! dn#rc#updateLinterStylelint() abort
    " the linter
    call dn#rc#npmInstall('stylelint')
    " standard config (see github repo stylelint/stylelint-config-standard)
    call dn#rc#npmInstall('stylelint-config-standard')
endfunction

" dn#rc#updateLinterTextlint()    {{{1

""
" @public
" Update linter textlint for markdown. It consists of a javascript package
" (node module).
function! dn#rc#updateLinterTextlint() abort
    " the linter
    call dn#rc#npmInstall('textlint')
    " configuration
    call dn#rc#npmInstall('@textlint-rule/textlint-rule-preset-google')
endfunction

" dn#rc#updateLinterTidy()    {{{1

""
" @public
" Update linter tidy for html. It consists of an executable. On debian systems
" the executable is part of a deb package.
function! dn#rc#updateLinterTidy() abort
    if !executable('tidy')
        let l:msg = ["Cannot locate executable 'tidy'",
                    \ '- ALE will be unable to use it as a html linter']
        call dn#rc#error([l:msg])
    endif
endfunction

" dn#rc#updateLinterVimVint()    {{{1

""
" @public
" Update linter vim-vint for vimscript. It consists of a pip python module.
function! dn#rc#updateLinterVimVint() abort
    call dn#rc#pipInstall('vim-vint')
endfunction

" dn#rc#updateLinterWriteGood()    {{{1

""
" @public
" Update linter write-good for English prose. It consists of a javascript
" package (node module).
function! dn#rc#updateLinterWriteGood() abort
    call dn#rc#npmInstall('write-good')
endfunction

" dn#rc#updateLinterYamllint()    {{{1

""
" @public
" Update linter yamllint for yaml. It consists of an executable. On debian
" systems the executable is part of a deb package.
function! dn#rc#updateLinterYamllint() abort
    if !executable('yamllint')
        let l:msg = ["Cannot locate executable 'yamllint'",
                    \ '- ALE will be unable to use it as a yaml linter']
        call dn#rc#error([l:msg])
    endif
endfunction

" dn#rc#updateLspClients()    {{{1

""
" @public
" Update CoC language server protocol client extensions. See
" |dn#rc#configureCoc()| for a list of installed extensions.
function! dn#rc#updateLspClients() abort
    " client-specific updates
    call dn#rc#updateLspClientJava()
    call dn#rc#updateLspClientJedi()
    call dn#rc#updateLspClientPerl()
    call dn#rc#updateLspClientXml()
    " update all coc extensions
    call coc#util#update_extensions(1)
    " npm rebuild for coc extensions
    call coc#util#rebuild()
endfunction

" dn#rc#updateLspClientJava()    {{{1

""
" @public
" Update CoC language server protocol client extension coc-perl. This
" extension requires a Java Development Kit (JDK) >= version 11. The JDK is
" checked by:
" * checking that the java compiler executable ('javac') is present
" * checking the version of javac.
function! dn#rc#updateLspClientJava() abort
    " check JDK is present
    if !executable('javac')
        let l:msg = ["Cannot locate executable 'javac'",
                    \ '- CoC requires it for java completion']
        call dn#rc#error([l:msg])
    endif
    " check version of JDK
    let l:min_ver = 11
    let l:cmd = 'javac --version'
    " - result is 'javac XX.YY.ZZ'
    let l:feedback = systemlist(l:cmd)[0]
    if empty(l:feedback)
        call dn#rc#error('Unable to extract javac version string')
        return
    endif
    let l:version = split(l:feedback)[1]
    let l:major = split(l:version, '\.')[0]
    if l:major < l:min_ver
        let l:msg = ['Detected JDK version ' . l:major,
                    \ '- CoC java extension requires JDK >= ' . l:min_ver]
        call dn#rc#error(l:msg)
    endif
endfunction

" dn#rc#updateLspClientJedi()    {{{1

""
" @public
" Update CoC language server protocol client extension coc-jedi for python.
" This extension relies on the Jedi Language Server, which consists of a pip
" python module. (Note: it is also available as a debian package but that
" package is a pure library and does not provide an executable; the coc
" extension requires a jedi executable to function.)
function! dn#rc#updateLspClientJedi() abort
    call dn#rc#pipInstall('jedi-language-server')
endfunction

" dn#rc#updateLspClientPerl()    {{{1

""
" @public
" Update CoC language server protocol client extension coc-perl. This
" extension relies on perl module Perl::LanguageServer.
function! dn#rc#updateLspClientPerl() abort
    call dn#rc#perlModuleInstallUpdate('Perl::LanguageServer')
endfunction

" dn#rc#updateLspClientXml()    {{{1

""
" @public
" Update CoC language server protocol client extension coc-xml. This
" extension requires a Java Development Kit (JDK) >= version 8. The JDK is
" checked by:
" * checking that the java compiler executable ('javac') is present
" * checking the version of javac.
function! dn#rc#updateLspClientXml() abort
    " check JDK is present
    if !executable('javac')
        let l:msg = ["Cannot locate executable 'javac'",
                    \ '- CoC requires it for xml completion']
        call dn#rc#error([l:msg])
    endif
    " check version of JDK
    let l:min_ver = 8
    let l:cmd = 'javac --version'
    " - result is 'javac XX.YY.ZZ'
    let l:feedback = systemlist(l:cmd)[0]
    if empty(l:feedback)
        call dn#rc#error('Unable to extract javac version string')
        return
    endif
    let l:version = split(l:feedback)[1]
    let l:major = split(l:version, '\.')[0]
    if l:major < l:min_ver
        let l:msg = ['Detected JDK version ' . l:major,
                    \ '- CoC xml extension requires JDK >= ' . l:min_ver]
        call dn#rc#error(l:msg)
    endif
endfunction

" dn#rc#vimPath(type)    {{{1

""
" @public
" Provides vim-related paths. The |String| path {type} to be returned can be
" "home", "plug" or "panzer".
function! dn#rc#vimPath(type) abort
    " vim home directory
    let l:os = dn#rc#os()
    if     a:type ==# 'home'
        let l:home = escape($HOME, ' ')
        if     l:os ==# 'windows'
            if dn#rc#isNvim()  " nvim
                return resolve(expand('~/AppData/Local/nvim'))
            else  " vim
                return l:home . '/vimfiles'
            endif
        elseif l:os ==# 'unix'
            return l:home . '/.vim'
        else
            return l:home . '/.vim'
        endif
    " plugin directory root
    elseif a:type ==# 'plug'
        if dn#rc#isVim()    " vim
            return resolve(expand('~/.cache/vim/plugins'))
        else    " nvim
            " on linux: ~/.cache/nvim/plugins
            return stdpath('cache') . '/plugins'
        endif
    " panzer support directory
    elseif a:type ==# 'panzer'
        let l:home = escape($HOME, ' ')
        if     l:os ==# 'windows'
            return resolve(expand('~/AppData/Local/panzer'))
        elseif l:os ==# 'unix'
            return l:home . '/.config/panzer'
        else
            return l:home . '/.config/panzer'
        endif
    " error
    else
        echoerr "Invalid path type '" . a:type . "'"
    endif
endfunction

" dn#rc#vimprocBuild()    {{{1

""
" @public
" Provide the build command for the shougo/vimproc plugin. Returns a |String|
" build command.
" The build command is 'make', except for MinGW on windows where there are
" three potential build commands depending on the system architecture.
function! dn#rc#vimprocBuild() abort
    let l:cmd = 'make'
    if executable('mingw32-make')
                \ && ( has('win64') || has('win32') || has('win32unix') )
        let s:cmd = 'mingw32-make -f ' . (
                    \ has('win64')     ? 'make_mingw64.mak'                :
                    \ has('win32')     ? 'make_mingw32.mak'                :
                    \ has('win32unix') ? 'make_mingw32.mak CC=mingw32-gcc' :
                    \ '' )
    endif
    return l:cmd
endfunction

" dn#rc#warn(messages)    {{{1

""
" @public
" Display warning {messages} using |hl-WarningMsg| highlighting. The messages
" are expected to be a string or a |List| of |Strings|. Any other types of
" value are stringified with |string()|.
" Note that if there is more than one message vim will pause after displaying
" them until the user presses Enter. 
" Uses |:echomsg| to ensure messages are saved to the |message-history|. There
" is no return value.
function! dn#rc#warn(messages) abort
    " convert to list of strings
    " - cannot pass string to string() because it encloses in single quotes
    let l:messages = []
    let l:type = type(a:messages)
    if l:type == v:t_list
        for l:item in a:messages
            if type(l:item) == v:t_string
                call add(l:messages, l:item)
            else
                call add(l:messages, string(l:item))
            endif
        endfor
    elseif l:type == v:t_string
        call add(l:messages, l:item)
    else
        call add(l:messages, string(l:item))
    endif
    " display messages
    echohl WarningMsg
    for l:message in a:messages | echomsg l:message | endfor
    echohl None
    return
endfunction

" }}}1

" Control statements    {{{1
let &cpoptions = s:save_cpo
unlet s:save_cpo
" }}}1

" vim: foldmethod=marker :
