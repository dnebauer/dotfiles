-- DOCUMENTATION

---@brief [[
---*dn-md-utils-nvim.txt*  For Neovim version 0.9  Last change: 2024 January 08
---@brief ]]

---@toc dn_md_utils.contents

---@mod dn_md_utils.intro Introduction
---@brief [[
---An auxiliary filetype plugin for the markdown language.
---
---The plugin author uses the |vim-pandoc| plugin and pander
---(https://github.com/dnebauer/pander) for markdown support. This ftplugin
---is intended to address any gaps in markdown support provided by those
---tools.
---@brief ]]

---@mod dn_md_utils.depend Dependencies
---@brief [[
---Pandoc is used to generate output. It is not provided by this ftplugin,
---which depends on the |vim-pandoc| plugin and assumes pander
---(https://github.com/dnebauer/pander) is installed.
---
---This ftplugin also depends on the dn-utils plugin
---(https://github.com/dnebauer/dn-utils.nvim).
---@brief ]]

---@mod dn_md_utils.features Features
---@brief [[
---The major features of this ftplugin are support for yaml metadata blocks,
---adding figures, cleaning up output file and directories, and altering the
---pandoc command line arguments.
---
---Metadata ~
---
---Pandoc-flavoured markdown uses a yaml-style metadata block at the top of
---the file to specify values used by pandoc for document processing. With
---pander (https://github.com/dnebauer/pander) installed the metadata block
---can also specify pander style keywords which, in turn, specify metadata
---values and command-line options used by pandoc for document processing.
---
---This ftplugin assumes the following default yaml-metadata block is used
---at the top of documents:
--->
---    ---
---    title:  "[][source]"
---    author: "[][author]"
---    date:   ""
---    style:  [Standard, Latex14pt]
---            # Latex8-12|14|17|20pt; SectNewpage; PageBreak; Include
---    ---
---<
---The reference-style links are defined at the end of the document. The
---default boilerplate for this is:
--->
---    [comment]: # (URLs)
---
---       [author]:
---
---       [source]:
---<
---The default metadata block and reference link definitions are added to a
---document by the function |dn_md_utils.add_boilerplate|, which can be
---called using the command |dn_md_utils.MUAddBoilerplate| and mappings
---|dn_md_utils.<Leader>ab|.
---
---Previously created markdown files have yaml metadata blocks that do not
---use pander. Those metadata blocks can be "panderified" using the function
---|dn_md_utils.panderify_metadata|, which can be called using the command
---|dn_md_utils.MUPanderifyMetadata| and mapping |dn_md_utils.<Leader>pm|.
---
---Images ~
---
---A helper function, mapping and command are provided to assist with adding
---figures. They assume the images are defined using reference links with
---optional attributes, and that all reference links are added to the end of
---the document prefixed with three spaces. For example:
--->
---    See @fig:display and {@fig:packed}.
---
---    ![Tuck boxes displayed][display]
---
---    ![Tuck boxes packed away][packed]
---
---    [comment]: # (URLs)
---
---       [display]: resources/displayed.png "Tuck boxes displayed"
---       {#fig:display .class width="50%"}
---
---       [packed]: resources/packed.png "Tuck boxes packed away"
---       {#fig:packed .class width="50%"}
---<
---A figure is inserted on the following line using the
---|dn_md_utils.insert_figure| function, which can be called using the
---command |dn_md_utils.MUInsertFigure| and mapping |dn_md_utils.<Leader>fig|.
---
---Tables ~
---
---A helper function, mapping and command are provided to assist with adding
---tables. More specifically, they aid with adding the caption and id
---definition following the table. The syntax used is that expected by the
---pandoc-tablenos filter (https://github.com/tomduck/pandoc-tablenos). In
---this example:
--->
---    \*@tbl:simple is a simple table.
---
---    A B
---    - -
---    0 1
---
---    Table: A simple table. {#tbl:simple}
---<
---the definition is "Table: A simple table. {#tbl:simple}".
---
---The definition is inserted on the following line using the
---|dn_md_utils.insert_table| function, which can be called using the command
---|dn_md_utils.MUInsertTable| and mapping |dn_md_utils.<Leader>tbl|.
---
---Include Files ~
---
---A helper function, mapping and command are provided to assist with
---including external markdown files, or subdocuments, in the current
---document. More specifically, an "include" directive is inserted. The
---markdown files specified in the directive are included in the output file
---in the order listed.
---
---The include directive is processed by the "include-files" lua filter which
---is available from the pandoc/lua-filters github repository
---(https://github.com/pandoc/lua-filters).
---
---The include directive has the format:
--->
---    ```{.include}
---    file_1.md
---    file_2.md
---    ...
---    ```
---<
---or:
--->
---    ```{.include shift-heading-level-by=X}
---    file_1.md
---    file_2.md
---    ...
---    ```
---<
---depending on whether a heading shift value is specified.
---
---The default behaviour of the "include-files" lua filter is to include
---subdocuments unchanged. If a "shift-heading-level-by" value is specified,
---all headings in subdocuments are "shifted" to lesser heading levels by the
---number of steps specified. For example, a value of 2 would result in
---top-level headers in subdocuments becoming third-level headers, with other
---header levels shifted accordingly.
---
---If the "automatic shifting" feature of the plugin is enabled (by using the
---metadata flag "include-auto") the "shift-heading-level-by" option behaves
---differently. See
---https://github.com/pandoc/lua-filters/tree/master/include-files for more
---details.
---
---The "include" directive is inserted on the following line using the
---|dn_md_utils.insert_files| function, which can be called using the command
---|dn_md_utils.MUInsertFiles| and mapping |dn_md_utils.<Leader>fil|.
---
---Output ~
---
---This ftplugin leaves the bulk of output generation to
---|vim-pandoc|.
---
---This ftplugin provides a mapping, command and function for deleting
---output files and temporary output directories. The term "clean" is used,
---as in the makefile keyword that deletes all working and output files.
---
---Cleaning of output only occurs if the current buffer contains a file. The
---directory searched for items to delete is the directory in which the file
---in the current buffer is located.
---
---If the file being edited is FILE.ext, the files that will be deleted have
---names like "FILE.html" and "FILE.pdf" (see function
---|dn_md_utils.clean_buffer| for a complete list). The temporary output
---subdirectory ".tmp" will also be recursively force deleted. Warning: this
---ftplugin does not check that it is safe to delete files and directories
---identified for deletion. For example, it does not check whether any of
---them are symlinks to other locations. Also be aware that directories are
---forcibly and recursively deleted, as with the *nix shell command "rm -fr".
---
---When a markdown buffer is closed (actually when the |BufDelete| event
---occurs), this ftplugin checks for output files/directories and, if any
---are found, asks the user whether to delete them. If the user confirms
---deletion they are removed. When vim exits (actually, when the
---|VimLeavePre| event occurs) this ftplugin looks for any markdown buffers
---and looks in their respective directories for output files/directories
---and, if any are found, asks the user whether to delete them. See
---|dn_md_utils.autocmds| for further details.
---
---Output files and directories associated with the current buffer can be
---deleted at any time by using the function |dn_md_utils.clean_buffer|
---function, which can be called using the command
---|dn_md_utils.MUCleanOutput| and mapping |dn_md_utils.<Leader>co|.
---
---Altering pandoc compiler arguments ~
---
---The |vim-pandoc| plugin provides the string variable
---|g:pandoc#compiler#arguments| for users to configure. Any arguments it
---contains are automatically passed to pandoc when the `:Pandoc` command is
---invoked. This ftplugin enables the user to make changes to the arguments
---configured by this variable. The parser used by this ftplugin is very
---simple, so all arguments in the value for |g:pandoc#compiler#arguments|
---must be separated by one or more spaces and have one of the following
---forms:
---• --arg-with-no-value
---• --arg="value"
---
---The number of leading dashes can be from one to three.
---
---To add an argument and value such as "-Vlang:spanish", treat it as though
---it were an argument such as "--arg-with-no-value".
---
---This is only one method of specifying compiler arguments. For example,
---another method is using the document yaml metadata block. If highlight
---style is specified by multiple methods, the method that "wins" may depend
---on a number of factors. Trial and error may be necessary to determine how
---different methods of setting compiler arguments interact on a particular
---system.
---
---This ftplugin provides commands for adding and/or changing the pandoc
---command line argument "--highlight-style":
---• see @command(MUChangeHighlightStyle)
---• user selects from available highlight styles
---• advises user of current value if already set
---@brief ]]

local dn_md_utils = {}

-- PRIVATE VARIABLES

-- only load module once
if vim.g.dn_md_utils_loaded then
  return
end
vim.g.dn_md_utils_loaded = true

local sf = string.format
local util = require("dn-utils")

-- PUBLIC VARIABLES

---@mod dn_md_utils.variables Variables

---@tag dn_md_utils.options
---@brief [[
---While it is not anticipated that users will need to inspect the plugin
---options, they are exposed as a table in the "options" field. The preferred
---method to set or alter these options is through the |dn_md_utils.setup| method.
---Change them in any other way at your own risk!
---@brief ]]
dn_md_utils.options = {
  version = "2023-11-19",
}

-- PRIVATE FUNCTIONS

-- forward declarations
--local _change_caps

-- PUBLIC FUNCTIONS

-- insert_figure()

---Inserts a figure on a new line. A reference link definition is added to the
---end of the file in its own line.
function dn_md_utils.insert_figure()
  -- get_id/label
  local _if_get_id_label
  _if_get_id_label = function(user_input)
    util.info(util.stringify(user_input))
    --local default = s:make_into_id_value(l:caption)
    --" lowercase only
    --let l:value = tolower(a:value)
    --" remove illegal characters
    --let l:value = substitute(l:value, '[^a-z0-9_-]', '-', 'g')
    --" remove leading dashes
    --let l:value = substitute(l:value, '^-\+', '', '')
    --" remove trailing dashes
    --let l:value = substitute(l:value, '-\+$', '', '')
    --" collapse sequential dashes into single dash
    --let l:value = substitute(l:value, '-\{2,\}', '-', 'g')
    --let l:prompt  = 'Enter figure id (empty to abort): '
    --while 1
    --    let l:id = input(l:prompt, l:default)
    --    echo ' '  | " ensure move to a new line
    --    " empty value means aborting
    --    if empty(l:id) | return '' | endif
    --    " must be legal id
    --    if !s:is_valid_id_value(l:id)
    --        call dn#util#warn('Ids contain only a-z, 0-9, _ and -')
    --        continue
    --    endif
    --    " ok, if here must be legal
    --    break
    --endwhile
  end

  -- get image caption
  local _if_get_caption
  _if_get_caption = function(user_input)
    vim.ui.input({ "Enter image caption (empty to abort): " }, function(input)
      if input then
        user_input.caption = input
        _if_get_id_label(user_input)
      end
    end)
  end

  -- get image filepath
  vim.ui.input({ prompt = "Enter image filepath (empty to abort): ", completion = "file" }, function(input)
    if input then
      if not util.file_readable(input) then
        util.warning(sf("File '%s' is not readable", input))
      end
      local user_input = {}
      user_input.file = input
      _if_get_caption(user_input)
    end
  end)
end

-- MAPPINGS

---@mod dn_md_utils.mappings Mappings

-- COMMANDS

---@mod dn_md_utils.commands Commands

return dn_md_utils
