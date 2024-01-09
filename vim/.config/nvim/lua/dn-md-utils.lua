-- DOCUMENTATION

-- TODO:add:
-- • insert_table_definition
-- • insert_file
-- • clean_buffer|all_buffers (include autocmds)
-- • add_boilerplate
-- • newline mapping

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
---|dn_md_utils.insert_table_definition| function, which can be called using
---the command |dn_md_utils.MUInsertTable| and mapping
---|dn_md_utils.<Leader>tbl|.
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

---@mod dn_md_utils.functions Functions
-- insert_figure()

---Inserts a figure link on a new line.
---A reference link definition is added to the end of the file in its own
---line.
---@return nil _ No return value
function dn_md_utils.insert_figure()
  -- WARNING: if editing this function note that it consists of a chain of
  --          local functions called in turn through callbacks in
  --          |vim.ui.input()| calls; this makes the function inherently
  --          fragile and easy to break

  -- pre-declare local functions
  local _fig_get_caption
  local _fig_get_id_label
  local _fig_get_width
  local _fig_insert

  -- variables used in multiple local functions
  local prompt, default

  -- get image filepath
  prompt = "Enter image filepath (empty to abort)"
  vim.ui.input({ prompt = prompt, completion = "file" }, function(input)
    if input and input:len() ~= 0 then
      if not util.file_readable(input) then
        util.warning(sf("File '%s' is not readable", input))
      end
      local user_input = {}
      user_input.path = input
      _fig_get_caption(user_input)
    end
  end)

  -- get image caption
  _fig_get_caption = function(user_input)
    prompt = "Enter image caption (empty to abort)"
    vim.ui.input({ prompt = prompt }, function(input)
      if input and input:len() ~= 0 then
        user_input.caption = input
        _fig_get_id_label(user_input)
      end
    end)
  end

  -- get_id/label
  _fig_get_id_label = function(user_input)
    -- derive default id from caption
    -- • make lowercase
    default = string.lower(user_input.caption)
    -- • remove illegal characters (%w = alphanumeric)
    default = default:gsub("[^%w_]", "-")
    -- • remove leading and trailing dashes
    default = util.trim_char(default, "-")
    -- • collapse multiple sequential dashes
    default = default:gsub("%-+", "%-")
    -- get id
    prompt = "Enter figure id (empty to abort "
    vim.ui.input({ prompt = prompt, default = default }, function(input)
      if input and input:len() ~= 0 then
        if not input:match("^[a-z_-]+$") then
          util.error("Figure ids can contain only a-z, 0-9, _ and -")
          return
        end
        user_input.id = input
        _fig_get_width(user_input)
      end
    end)
  end

  -- get width class (optional)
  _fig_get_width = function(user_input)
    prompt = "Enter image width (optional)"
    default = "80%"
    vim.ui.input({ prompt = prompt, default = default }, function(input)
      if input and input:len() ~= 0 then
        user_input.width = input
      end
      _fig_insert(user_input)
    end)
  end

  -- insert figure link and link definition
  _fig_insert = function(user_input)
    -- assemble link
    local link = sf("![%s][%s]", user_input.caption, user_input.id)
    -- assemble link definition
    local width = ""
    if user_input.width and user_input.width:len() ~= 0 then
      width = sf(" .class %s", user_input.width)
    end
    local id, path, caption = user_input.id, user_input.path, user_input.caption
    local definition = sf('   [%s]: %s "%s" {#fig:%s%s}', id, path, caption, id, width)
    -- insert link
    local link_lines = { link, "" }
    vim.api.nvim_put(link_lines, "l", true, true)
    -- insert definition
    local definition_lines = { "", definition }
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    local last_line = vim.fn.line("$")
    vim.api.nvim_win_set_cursor(0, { last_line, 1 })
    vim.api.nvim_put(definition_lines, "l", true, false)
    vim.api.nvim_win_set_cursor(0, { line, col })
  end
end

-- insert_table_definition()

---Inserts a table caption and id line as expected by pandoc-tablenos to
---follow a table.
---@return nil _ No return value
function dn_md_utils.insert_table_definition()
  -- WARNING: if editing this function note that it consists of a chain of
  --          local functions called in turn through callbacks in
  --          |vim.ui.input()| calls; this makes the function inherently
  --          fragile and easy to break

  -- pre-declare local functions
  local _tbl_get_id_label
  local _tbl_definition_insert

  -- variables used in multiple local functions
  local prompt, default

  -- get table caption
  prompt = "Enter table caption (empty to abort)"
  vim.ui.input({ prompt = prompt }, function(input)
    if input and input:len() ~= 0 then
      local user_input = {}
      user_input.caption = input
      -- remove trailing periods as terminal period added later
      user_input.caption = user_input.caption:gsub("%.+$", "")
      _tbl_get_id_label(user_input)
    end
  end)

  -- get_id/label
  _tbl_get_id_label = function(user_input)
    -- derive default id from caption
    -- • make lowercase
    default = string.lower(user_input.caption)
    -- • remove illegal characters (%w = alphanumeric)
    default = default:gsub("[^%w_]", "-")
    -- • remove leading and trailing dashes
    default = util.trim_char(default, "-")
    -- • collapse multiple sequential dashes
    default = default:gsub("%-+", "%-")
    -- get id
    prompt = "Enter table id (empty to abort "
    vim.ui.input({ prompt = prompt, default = default }, function(input)
      if input and input:len() ~= 0 then
        if not input:match("^[a-z_-]+$") then
          util.error("Table ids can contain only a-z, 0-9, _ and -")
          return
        end
        user_input.id = input
        _tbl_definition_insert(user_input)
      end
    end)
  end

  -- insert table definition
  _tbl_definition_insert = function(user_input)
    -- assemble table definition
    local caption, id = user_input.caption, user_input.id
    local definition = sf("Table: %s. {#tbl:%s}", caption, id)
    -- insert table definition
    local definition_lines = { definition }
    vim.api.nvim_put(definition_lines, "l", true, true)
  end
end

-- MAPPINGS

---@mod dn_md_utils.mappings Mappings

-- \xfi [n,i]
---@tag dn_md_utils.<Leader>xfi
---@brief [[
---This mapping calls the function |dn_md_utils.insert_figure| in modes "n"
---and "i".
---@brief ]]
vim.keymap.set({ "n", "i" }, "<Leader>xfi", dn_md_utils.insert_figure, { desc = "Insert figure link and definition" })

-- \xtb [n,i]
---@tag dn_md_utils.<Leader>xtb
---@brief [[
---This mapping calls the function |dn_md_utils.insert_table_definition| in
---modes "n" and "i".
---@brief ]]
vim.keymap.set({ "n", "i" }, "<Leader>xtb", dn_md_utils.insert_table_definition, { desc = "Insert table definition" })

-- COMMANDS

---@mod dn_md_utils.commands Commands

-- XMUInsertFigure
---@tag dn_utils.XMUInsertFigure
---@brief [[
---Calls function |dn_md_utils.insert_figure| to insert a figure link on the
---following line and a corresponding link definition is added to the bottom
---of the document.
---@brief ]]
vim.api.nvim_create_user_command("XMUInsertFigure", function()
  dn_md_utils.insert_figure()
end, { desc = "Insert figure link and definition" })

-- XMUInsertTable
---@tag dn_utils.XMUInsertTable
---@brief [[
---Calls function |dn_md_utils.insert_table_definition| to insert a table
---caption and id on the following line.
---@brief ]]
vim.api.nvim_create_user_command("XMUInsertTable", function()
  dn_md_utils.insert_table_definition()()
end, { desc = "Insert table definition" })

return dn_md_utils
