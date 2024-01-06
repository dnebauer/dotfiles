-- DOCUMENTATION

-- TODO: Check whether functions every return nil return value
-- TODO: What is return value of functions with no explicit return value
-- TODO: Implement these functions:
--
--       * dn-latex:
--         * pad_internal()
--         * match_count()
--         * insert_string()
--         * get_rtp_dir()

---@brief [[https://www.reddit.com/r/neovim/comments/w4r2de/comment/ih46dhl/
---*dn-utils-nvim.txt*   For Neovim version 0.9   Last change: 2024 January 06
---@brief ]]

---@toc dn_utils.contents

---@mod dn_utils.intro Introduction
---@brief [[
---A plugin to provide useful generic functions. It is intended to be available
---to all files being edited. These functions were developed over time by the
---author and later combined into a library. Some |commands| and |mappings| are
---provided.
---@brief ]]

---@mod dn_utils.requirements External requirements
---@brief [[
---The menu selection function |dn_utils.menu_select| uses an embedded
---|python3| script whose only external dependency is the tkinter package
---(https://docs.python.org/3/library/tkinter.html).
---@brief ]]

local dn_utils = {}

-- PRIVATE VARIABLES

-- only load module once
if vim.g.dn_utils_loaded then
  return
end
vim.g.dn_utils_loaded = true

-- record plugin state
--[[
local ok, _ = pcall(vim.api.nvim_get_var, "dn_utils")
if not ok then
  vim.g.dn_utils = {}
end
--]]

local sf = string.format

-- PUBLIC VARIABLES

---@mod dn_utils.variables Variables

---@tag dn_utils.options
---@brief [[
---While it is not anticipated that users will need to inspect the plugin
---options, they are exposed as a table in the "options" field. The preferred
---method to set or alter these options is through the |dn_utils.setup| method.
---Change them in any other way at your own risk!
---@brief ]]
dn_utils.options = {
  version = "2023-11-19",
}

-- PRIVATE FUNCTIONS

-- forward declarations
local _change_caps
local _display_variables
local _enclose_string
local _extract_single_element_dict_contents
local _menu_normalise
local _menu_simple_type
local _menu_ui_select
local _menu_ui_select_inputlist
local _menu_ui_select_pythontk
local _t
local _tbl_to_str
local _wrap_fmt
local _wrap_manual

-- _change_caps(string, case_type)
---@private
---Change capitalisation of provided string. The type of capitalisation can
---be "upper", "lower", "sentence", "start" or "title":
---
---upper:
---• convert the string to all uppercase characters
---
---lower:
---• convert the string to all lowercase characters
---
---sentence:
---• convert the first character to uppercase and all other characters to
---    lowercase
---
---start:
---• convert the first letter of each word to uppercase and all other letters
---  to lower case
---
---title:
---• capitalises first and last words, and all other words except articles,
---  prepositions and conjunctions of fewer than five letters
---
---Newlines are preserved. The converted string is returned.
---@param str string String to be converted
---@param cap_type string Capitalisation type (upper,lower,sentence,start,title)
---@return string _ Converted string
function _change_caps(str, cap_type)
  -- parameters
  assert(str ~= nil, "No string provided")
  if str == "" then
    return ""
  end
  local valid_types = { "upper", "lower", "sentence", "start", "title" }
  local type = cap_type:lower()
  if not dn_utils.is_table_value(valid_types, type) then
    error("Invalid capitalisation type: " .. type)
  end
  -- variables
  -- • articles of speech are not capitalised in title case
  local articles = { "a", "an", "the" }
  -- • prepositions are not capitalised in title case
  local prepositions = {
    "amid",
    "as",
    "at",
    "atop",
    "but",
    "by",
    "for",
    "from",
    "in",
    "into",
    "mid",
    "near",
    "next",
    "of",
    "off",
    "on",
    "onto",
    "out",
    "over",
    "per",
    "quo",
    "sans",
    "than",
    "till",
    "to",
    "up",
    "upon",
    "v",
    "vs",
    "via",
    "with",
  }
  -- • conjunctions are not capitalised in title case
  local conjunctions = {
    "and",
    "as",
    "both",
    "but",
    "for",
    "how",
    "if",
    "lest",
    "nor",
    "once",
    "or",
    "so",
    "than",
    "that",
    "till",
    "when",
    "yet",
  }
  local temp = {}
  vim.list_extend(temp, articles)
  vim.list_extend(temp, prepositions)
  vim.list_extend(temp, conjunctions)
  -- • merge all words not capitalised in title case
  -- • weed out duplicates for aesthetic reasons
  local title_lowercase = {}
  for _, item in ipairs(temp) do
    if not vim.list_contains(title_lowercase, item) then
      table.insert(title_lowercase, item)
    end
  end
  -- • splitting of header on word boundaries produces some pseudo-words that
  --   are not actual words, and these should not be capitalised in 'start'
  --   or 'title' case
  local pseudowords = { "s" }
  -- break up string into word fragments
  local words = vim.fn.split(str, "\\<\\|\\>")
  -- process words individually
  local index = 1
  local last_index = #words
  local first_word = true
  local last_word = false
  for _, word in ipairs(words) do
    word = word:lower() -- first make all lowercase
    last_word = (index == last_index) -- check for last word
    if type == "upper" then
      word = word:upper()
    elseif type == "lower" then
      -- already made lowercase so nothing to do here
    elseif type == "start" then
      -- some pseudo-words must not be capitalised
      if not dn_utils.is_table_value(pseudowords, word) then
        word = vim.fn.substitute(word, "\\w\\+", "\\u\\0", "g")
      end
    -- behaviour of remaining types 'sentence' and 'title' depends on
    -- position  of word in heading, and for single word headings first
    -- position takes precedence over last position
    elseif first_word then
      word = vim.fn.substitute(word, "\\w\\+", "\\u\\0", "g")
    elseif last_word then
      -- if 'sentence' type then leave lowercase
      -- if 'title' beware some psuedo-words must not be capitalised
      if type == "title" and not dn_utils.is_table_value(pseudowords, word) then
        word = vim.fn.substitute(word, "\\w\\+", "\\u\\0", "g")
      end
    else -- type is 'sentence' or 'title' and word is not first or last
      -- if 'sentence' type then leave lowercase
      if type == "title" then
        -- capitalise if not in list of words to be kept lowercase
        -- and is not a psuedo-word
        if not dn_utils.is_table_value(title_lowercase, word) and not dn_utils.is_table_value(pseudowords, word) then
          word = vim.fn.substitute(word, "\\w\\+", "\\u\\0", "g")
        end
      end
    end
    -- negate first word flag after first word is encountered
    if first_word and word:find("^%a") then
      first_word = false
    end
    -- write changed word
    words[index] = word
    -- move to next list item
    index = index + 1
  end
  -- return altered header
  return table.concat(words)
end

-- _display_variables(tbl)
---@private
---Displays variables one per line in the form "var_name: var_value"
---with the variable value generated by |vim.inspect()|.
---@param args table Each key,value is a variable name,content
---@return nil _ No return value
---@usage [[
---_display_variables({ selection = selection, ["var name"] = var_name })
---@usage ]]
function _display_variables(args)
  local lines = {}
  for name, content in pairs(args) do
    table.insert(lines, name .. ": " .. vim.inspect(content))
  end
  local display = table.concat(lines, "\n")
  vim.api.nvim_echo({ { display } }, true, {})
end

-- _enclose_string(str, leftboth, right)
---@private
---Format a value as a string and enclose it.
---@param val any Value to stringify and enclose
---@param leftboth string|nil String to use on lhs (default='["'),
---and rhs (default='"]')if "right" not specified
---@param right string|nil String to use on rhs (default='"]')
---@return string _ Enclosed string
function _enclose_string(val, leftboth, right)
  local left = leftboth or '["'
  right = right or leftboth or '"]'
  return left .. tostring(val) .. right
end

-- _extract_single_element_dict_contents(tbl)
---@private
---Takes a dictionary (table with single key-value pair), extracts the key and
---value, and returns them as a single list.
---
---Fatal errors occur if the provided variable is not a single element
---dictionary.
---@param tbl table Table to extract contents from
---@return string,any _ Sequence containing dictionary key and value
function _extract_single_element_dict_contents(tbl)
  -- param check
  assert(type(tbl) == "table", "Expected a table, got a " .. type(tbl))
  local tbl_size = dn_utils.table_size(tbl)
  assert(tbl_size == 1, "Expected table with 1 element, got " .. tbl_size .. " elements")
  -- extract contents
  local key, value
  for k, v in pairs(tbl) do
    key = k
    value = v
  end
  -- return contents
  return key, value
end

-- _menu_normalise(menu)
---@private
---This is a helper function for |dn_utils.menu_select|. That function receives
---a multi-level sequence or dictionary menu variable.
---
---In the following discussion a "simple" menu is one without any submenus, and
---"simple" variables are string, number, boolean, and nil. A "simple" sequence
---has elements which are all either simple variables or single key-value
---dictionaries whose values are also simple variables. A "simple" dictionary
---has values which are all simple variables.
---
---Dictionary menus can contain submenus. In a dictionary a submenu is a new
---key-value pair in the parent menu where the key is a submenu header and the
---value is a sequence or dictionary defining the new submenu options.
---
---A single menu can contain a mixture of sequence and dictionary elements.
---
---This function normalises the menu structure so that the menu variable is a
---sequence and each menu, i.e., sequence, element is a single key-pair
---dictionary. In this schema all submenus are a dictionary value (with the
---corresponding dictionary key being the submenu header). The submenu itself
---is a sequence, each of whose elements contains a single key-pair dictionary,
---and so on.
---
---Dictionary (sub)menus have an undefined order. This function uses vim's
---standard |sort()| function to order them by the dictionary keys. Sequence
---menus retain their order.
---
---Errors occur if a menu item is not a valid data type, the menu is neither a
---sequence nor a dictionary, the menu has no items,
---@param menu table Menu to normalise
---@return table _ Normalised menu
function _menu_normalise(menu)
  assert(type(menu) == "table", "Expected a table menu, got a " .. type(menu))
  assert(next(menu) ~= nil, "Menu table is empty")
  local normalised = {}
  -- set initial state
  local state, items
  if vim.tbl_islist(menu) then
    state = "seq_expecting-option"
    items = vim.deepcopy(menu)
  else
    state = "dict_expecting-option"
    items = vim.fn.sort(vim.fn.keys(menu))
  end
  -- process items
  for _, item in ipairs(items) do
    -- what kind of item do we have?
    local item_type
    if _menu_simple_type(item) then
      item_type = "simple"
    elseif type(item) == "table" then
      item_type = "submenu"
    else
      error("Invalid menu item data type: " .. type(item) .. " (" .. dn_utils.stringify(item) .. ")")
    end
    -- sequence menu item might be:
    -- • simple data item
    -- • sequence (must be an expected submenu)
    -- • dict (might be an expected submenu)
    -- • dict (might be an option:return-value pair)
    -- • dict (might be an header:submenu pair)
    local option, retval
    local key, value
    local item_size
    if state == "seq_expecting-option" then
      -- can be a simple data type or single-pair dict
      if item_type == "simple" then -- simple data type
        option = dn_utils.stringify(item)
        table.insert(normalised, { [option] = item })
      elseif type(item) == "table" then -- single-pair dict
        -- can only have one key-value pair
        item_size = dn_utils.table_size(item)
        assert(item_size == 1, "Expect 1 dict menu entry, got " .. item_size)
        -- get key (option or header) and value (retval or submenu)
        key, value = _extract_single_element_dict_contents(item)
        option = dn_utils.stringify(key)
        -- process submenu if necessary
        if type(value) == "table" then
          retval = _menu_normalise(value)
        elseif _menu_simple_type(value) then
          retval = value
        else
          error("Menu dict value is wrong type (" .. type(value) .. "): " .. dn_utils.stringify(value))
        end
        -- add option and return value
        table.insert(normalised, { [option] = retval })
      else -- invalid data type
        error("Invalid sequence menu option: " .. dn_utils.stringify(item))
      end
    elseif state == "dict_expecting-option" then
      -- dictionary menu item can only be simple (it comes from a dictionary
      -- key and vim won't permit otherwise) but the return value, i.e.,
      -- dictionary value, can be anything, so check return value is valid
      value = menu[item]
      option = item
      -- process submenu if necessary
      if type(value) == "table" then
        retval = _menu_normalise(value)
      elseif _menu_simple_type(value) then
        retval = value
      else
        error("Invalid menu dict value: " .. dn_utils.stringify(value))
      end
      -- add option and return value
      table.insert(normalised, { [option] = retval })
    else
      -- unexpected state reached (programmer error!)
      error("Menu reached unexpected state: " .. state)
    end
  end

  return normalised
end

-- _menu_simple_type(item)
---@private
---Check whether item is a "simple" menu item: string, number, or boolean. Used
---in menu generation by the |dn_utils.menu_select| function.
---
---@param item string Menu item to analyse
---@return boolean _ Whether supplied variable is a string, number or boolean
function _menu_simple_type(item)
  local simple_types = { "string", "number", "boolean" }
  local item_type = type(item)
  return dn_utils.is_table_value(simple_types, item_type)
end

-- _menu_ui_select(prompt, options)
---@private
---This is a helper function for the |dn_utils.menu_select| function. That
---function receives a user {prompt}. It also receives a multi-level sequence or
---dictionary menu variable, normalises the menu (using the |_menu_normalise|
---function, builds parallel lists of {options} and {return_values}, and then
---calls on a subsidiary function to get the user to select a value.
---
---WARNING: The calling function is responsible for checking that the
---         parameters passed to this function are valid
---
---This function calls either |_menu_ui_select_inputlist()| or
---|_menu_ui_select_pythontk()| depending on menu size and window height. The
---latter function uses an embedded |python3| script is used that has a sole
---external dependency on the tkinter package
---(https://docs.python.org/3/library/tkinter.html).
---@param prompt string Menu prompt
---@param options table Sequence containing menu options
---@return number|nil _ Option number
function _menu_ui_select(prompt, options)
  -- do not use inputlist if:
  -- • number of options > 20 : dressing.vim limits inputlist height to 20 in
  --   a 30 line window, and inputlist does not scroll
  -- • number of options > (window height - 3) : inputlist does not scroll
  local window_height = vim.api.nvim_list_uis()[1].height
  local number_of_options = #options
  if number_of_options > 20 or number_of_options > (window_height - 3) then
    return _menu_ui_select_pythontk(prompt, options)
  else
    return _menu_ui_select_inputlist(prompt, options)
  end
end

-- _menu_ui_select_inputlist(prompt, options)
---@private
---This is a helper function for the |dn_utils.menu_select| function. That
---function receives a user {prompt}. It also receives a multi-level sequence
---or dictionary menu variable, normalises the menu (using the
---|_menu_normalise| function, builds parallel lists of {options} and
---{return_values}, and then calls on a subsidiary function to get the user to
---select a value.
---
---WARNING: The calling function is responsible for checking that the
---         parameters passed to this function are valid
---
---This function uses vim's inbuilt |inputlist()| to invoke a menu.
---@param prompt string Menu prompt
---@param options table Sequence containing menu options
---@return number|nil _ Option number
function _menu_ui_select_inputlist(prompt, options)
  local choices = { prompt }
  for i, option in ipairs(options) do
    table.insert(choices, sf("%d: %s", i, option))
  end
  local choice = vim.fn.inputlist(choices)
  if choice < 1 or choice > dn_utils.table_size(options) then
    return nil
  end
  return choice
end

-- _menu_ui_select_pythontk(prompt, options)
---@private
---This is a helper function for the |dn_utils.menu_select| function. That
---function receives a user {prompt}. It also receives a multi-level sequence
---or dictionary menu variable, normalises the menu (using the
---|_menu_normalise| function, builds parallel lists of {options} and
---{return_values}, and then calls on subsidiary functions to get the user to
---select a value.
---
---WARNING: The calling function is responsible for checking that the
---         parameters passed to this function are valid
---
---This function uses python script and the python tkinter package to invoke a
---gui menu.
---@param prompt string Menu prompt
---@param options table Sequence containing menu options
---@return number|nil _ Option number
function _menu_ui_select_pythontk(prompt, options)
  -- python script to invoke gui menu
  local python_code = [[
    # import statements
    import tkinter as tk
    from tkinter import ttk

    # variables
    selections = []
    title = "Menu"
    prompt = "{{prompt}}"
    items = {{items}}


    # event handlers


    def on_item_selection(event):  # pylint: disable=unused-argument
        register_item_selections()


    def on_tree_double_click(event):  # pylint: disable=unused-argument
        accept_selections()


    def on_return_keypress(event):  # pylint: disable=unused-argument
        # if Cancel button has focus then cancel, otherwise accept picks
        if "focus" in (cancel_button.state()):
            abort_selection()
        else:
            accept_selections()


    def on_escape_keypress(event):  # pylint: disable=unused-argument
        abort_selection()


    def register_item_selections():
        global selections
        selections = []
        for selected_id in tree.selection():
            selections.append(menu_items[selected_id])


    def abort_selection():
        global selections
        selections = []
        root.destroy()


    def accept_selections():
        register_item_selections()
        root.destroy()


    # create main window
    root = tk.Tk()
    root.title(title)

    # set style theme
    # - should be available on all systems: {clam,alt,default,classic}
    style = ttk.Style(root)
    try:
        style.theme_use("clam")
    except tk.TclError:
        pass

    # create frame within main window
    # - main window is 'old' tk; frame is 'modern' ttk
    mainframe = ttk.Frame(root, padding="3 3 12 12")
    mainframe.grid(column=0, row=0, sticky=(tk.N, tk.W, tk.E, tk.S))
    # - next two lines ensure frame resizes with main window (to fill it)
    root.columnconfigure(0, weight=1)
    root.rowconfigure(0, weight=1)

    # add prompt
    prompt_label = ttk.Label(mainframe, text=prompt)
    prompt_label.grid(column=1, row=1, sticky=(tk.W))

    # add menu
    select_mode = "browse"
    tree = ttk.Treeview(mainframe, selectmode=select_mode, show=["tree"])
    tree.grid(column=1, row=2, sticky=(tk.W))
    menu_items = {}
    first_id = None
    for item in items:
        item_id = tree.insert("", "end", text=item)
        menu_items[item_id] = item
        if not first_id:
            first_id = item_id

    # add OK and Cancel buttons
    okay_button = ttk.Button(mainframe, text="OK")
    okay_button.grid(column=1, row=3, sticky=(tk.E))
    cancel_button = ttk.Button(mainframe, text="Cancel")
    cancel_button.grid(column=1, row=4, sticky=(tk.E))

    # add padding to all widgets
    for child in mainframe.winfo_children():
        child.grid_configure(padx=5, pady=5)

    # determine initial focus in window
    tree.focus_set()
    tree.focus(first_id)
    tree.selection_set(first_id)

    # event handling
    okay_button.config(command=accept_selections)
    cancel_button.config(command=abort_selection)
    tree.bind("<<TreeviewSelect>>", on_item_selection)
    tree.bind("<Double-Button-1>", on_tree_double_click)
    root.bind("<Return>", on_return_keypress)
    root.bind("<Escape>", on_escape_keypress)

    # display mainwindow
    root.mainloop()

    # return selection
    vim.command("unlet! g:dn_utils_menu")
    vim.command("let g:dn_utils_menu = {}")
    if selections:
        # hardcoded menu mode allows selection of only one item
        return_value = selections[0]
        vim.command("let g:dn_utils_menu.selected = v:true")
        vim.command("let g:dn_utils_menu.selection = '{val}'".format(val=return_value))
    else:
        vim.command("let g:dn_utils_menu.selected = v:false")
  ]]
  local python_code_sequence = dn_utils.split(python_code, "\n")
  -- remove end items consisting only of spaces
  python_code_sequence = dn_utils.table_remove_empty_end_items(python_code_sequence)
  -- remove indent based on indent in first line
  local _, spaces = python_code_sequence[1]:find("^%s*")
  for idx, item in ipairs(python_code_sequence) do
    python_code_sequence[idx] = item:sub(spaces + 1, -1)
  end
  python_code = table.concat(python_code_sequence, "\n")
  -- insert menu prompt and items into python code
  python_code = python_code:gsub("{{prompt}}", prompt, 1)
  local items = '["' .. table.concat(options, '", "') .. '"]'
  python_code = python_code:gsub("{{items}}", items, 1)
  vim.cmd.python("import vim")
  vim.cmd.python(python_code)
  -- get return value
  local ok, pick = pcall(vim.api.nvim_get_var, "dn_utils_menu")
  if not ok then
    return nil
  end
  if not pick.selected then
    return nil
  end
  local flipped_options = {}
  for idx, option in ipairs(options) do
    flipped_options[option] = idx
  end
  return flipped_options[pick.selection]
end

-- _t(code)
---@private
---Escape terminal codes and keycodes.
---A convenience wrapper of |nvim_replace_termcodes()|.
---@param code string Terminal code or keycode to be escaped
---@return string _ Escaped code
---@usage [[
--- --function _G.smart_tab()
--- --  return vim.fn.pumvisible() == 1 and [[\<C-N>]] or [[\<Tab>]]
--- --end
---function _G.smart_tab()
---  return vim.fn.pumvisible() == 1 and t'<C-N>' or t'<Tab>'
---end
---@usage ]]
function _t(code)
  return vim.api.nvim_replace_termcodes(code, true, true, true)
end

-- _tbl_to_str(tbl, count, indent, pad)
---@private
---Engine function converting table contents to a prettified string.
---@param tbl table Table to convert to a string
---@param count number|nil Number of pads between string tokens (default=0)
---@param indent number|nil Number of pads to indent each table level (default=0)
---@param pad string|nil String to use for indenting and padding (default=<Tab>)
---@return string _ Stringified table
function _tbl_to_str(tbl, count, indent, pad)
  count = count or 0
  assert(type(count) == "number", "Expected number, got " .. type(count))
  indent = indent or 0
  assert(type(indent) == "number", "Expected number, got " .. type(indent))
  pad = pad or "\t"
  assert(type(pad) == "string", "Expected string, got " .. type(indent))

  local curpad = pad:rep(indent + count)
  local out = ""

  for k, v in pairs(tbl) do
    out = out .. curpad
    if type(v) == "table" then
      out = out .. _enclose_string(k) .. " = {" .. "\n"
      out = out .. _tbl_to_str(v, count, indent + (count * 2), pad) .. curpad .. "},\n"
    elseif type(v) == "string" then
      out = out .. _enclose_string(k) .. pad .. "=" .. pad .. _enclose_string(v, '"') .. ",\n"
    else
      out = out .. _enclose_string(k) .. pad .. "=" .. pad .. _enclose_string(v, "") .. ",\n"
    end
  end
  return out
end

-- wrap_fmt(message[, width])
---@private
---Processes a message string through "fmt". This is a utility which is found
---on all *nix systems as a core utility, and there are versions available for
---other operating systems. The "fmt" utility is primarily intended for
---formatting C/C++ and has been extended to other languages. It does a good
---job of wrapping plain text, hence its use in this function. The standard
---"fmt" utilty on *nix systems strives for a goal width of 93% of the maximum
---width provided.
---@param message string String to be formatted, may contain newlines
---@param opts table|nil Optional configuration options
---• {width} (number) Column to wrap at. Must be
---  a positive integer. If it is set to zero the
---  message string is returned without
---  alteration. If it is less than 10, and not
---  zero, it is set to 10.
function _wrap_fmt(message, opts)
  -- process parameters
  -- • message
  assert(type(message) == "string", "Expected string, got " .. type(message))
  if message:len() == 0 then
    return message
  end
  -- • opts
  opts = opts or {}
  assert(type(opts) == "table", "Expected table, got " .. type(opts))
  local valid_opts = { "width", "hang" }
  for opt, _ in pairs(opts) do
    assert(dn_utils.is_table_value(valid_opts, opt), "Invalid option: " .. opt)
  end
  -- • width
  local width = opts.width or 79
  assert(
    dn_utils.valid_non_negative_int(width),
    "Expected non-negative integer, got " .. type(width) .. " " .. tostring(width)
  )
  if width == 0 then
    return message
  end
  if width < 10 then
    width = 10
  end
  -- write message to temporary file
  local message_file = os.tmpname()
  local message_fh = assert(io.open(message_file, "w"))
  message_fh:write(message)
  message_fh:close()
  -- process file with 'fmt' utility
  local ret = dn_utils.execute_shell_command("fmt", "--width=" .. width, message_file)
  os.remove(message_file)
  -- handle error
  if ret.exit_status ~= 0 then
    local errmsg = 'command: "' .. ret.command .. '" failed, '
    local stderr = ret.stderr
    if stderr:len() > 0 then
      stderr = stderr:gsub("\n$", "")
      errmsg = errmsg .. 'with error output: "' .. stderr .. '"'
    else
      errmsg = errmsg .. "with no error output"
    end
    error(errmsg)
  end
  -- return wrapped text
  return ret.stdout
end

-- _wrap_manual(message[, opts])
---@private
---Wraps a message string sensibly at a specific column. The message must be a
---string and can contain newlines. It can be zero length.
---@param message string The message to wrap
---@param opts table|nil Optional configuration options
---• {width} (number) Column to wrap at. Must be
---  a positive integer. If it is set to zero the
---  message string is returned without
---  alteration. If it is less than 10, and not
---  zero, it is set to 10.
---• {hang} (number) Size of the hanging indent
---  in spaces. Must be a positive integer. If it
---  is set to zero there is no hanging indent.
---  The wrap width must be greater than than the
---  hanging indent by at least 10.
---@return string _ Wrapped message string
function _wrap_manual(message, opts)
  -- process parameters
  -- • message
  assert(type(message) == "string", "Expected string, got " .. type(message))
  if message:len() == 0 then
    return message
  end
  -- • opts
  opts = opts or {}
  assert(type(opts) == "table", "Expected table, got " .. type(opts))
  local valid_opts = { "width", "hang" }
  for opt, _ in pairs(opts) do
    assert(dn_utils.is_table_value(valid_opts, opt), "Invalid option: " .. opt)
  end
  -- • width
  local width = opts.width or 79
  assert(
    dn_utils.valid_non_negative_int(width),
    "Expected non-negative integer, got " .. type(width) .. " " .. tostring(width)
  )
  if width == 0 then
    return message
  end
  if width < 10 then
    width = 10
  end
  -- • hang
  local hang = opts.hang or 0
  assert(
    dn_utils.valid_non_negative_int(hang),
    "Expected non-negative integer, got " .. type(hang) .. " " .. tostring(hang)
  )
  assert((width - hang) >= 10, "Width (" .. width .. ") must be at least 10 larger than indent (" .. hang .. ")")
  local hanging_indent = string.rep(" ", hang)
  -- respect multiple newlines, but not single newlines
  -- • remove spaces before newlines
  -- •• because later converting newlines to spaces
  --    and want to avoid multiple consecutive spaces
  -- •• must use spaces instead of %s because %s consumes newlines
  message = message:gsub(" +\n", "\n")
  -- • convert newlines to U00F1 (Information Separator One) placeholders
  message = message:gsub("\n", "")
  -- • convert single newlines to spaces
  message = message:gsub("([^])([^])", "%1 %2")
  -- • convert remaining (multiple consecutive) placeholders to newlines
  message = message:gsub("", "\n")
  -- wrap string manually
  local wrapped = {}
  local lines = dn_utils.split(message, "\n")
  for _, line in ipairs(lines) do
    -- cater for empty lines
    if line:match("^%s*$") then
      table.insert(wrapped, "")
    else
      -- process line
      while line:len() > 0 do
        -- exit on last output line
        if line:len() <= width then
          table.insert(wrapped, line)
          break
        end
        -- find wrap point
        local wrap = -1
        local count = 1
        local finished = false
        while not finished do
          local index, _ = line:find("[%p%s]", count)
          if index == nil then
            finished = true
          elseif index < width then
            wrap = index
          end
          count = count + 1
        end
        -- if no wrap point then have ugly situation where no breakpoint
        -- exists so just output whole thing (ick!)
        if wrap == -1 then
          table.insert(wrapped, line)
          break
        end
        -- let's wrap!
        local output = line:sub(1, wrap)
        table.insert(wrapped, output)
        line = line:sub(wrap + 1)
        -- if broke line on punctuation mark may now have leading space
        line = vim.fn.trim(line, " ", 1)
        -- add hanging indent to all subsequent lines
        line = hanging_indent .. line
      end
    end
  end
  return table.concat(wrapped, "\n")
end

-- PUBLIC FUNCTIONS

---@mod dn_utils.funclist Function List
---@brief [[
---This is a list of functions grouped by what they are used for. An alphabetical
---list of function descriptions is located at |functions|. Use CTRL-] on the
---function name to jump to detailed help on it.
---
---Files and directories
---• |dn#util#fileExists|        whether file exists (uses |glob()|)
---• |dn#util#getFilePath|       get filepath of file being edited
---• |dn_utils.get_file_dir|     get directory of file being edited
---• |dn#util#getFileName|       get name of file being edited
---• |dn#util#getRtpDir|         finds directory from runtimepath
---• |dn_utils.get_rtp_file|     finds file(s) in directories under 'rtp'
---
---User interaction
---• |dn_utils.clear_prompt|     clear command line
---• |dn_utils.error|            display error message
---• |dn_utils.info|             display message to user
---• |dn_utils.warn|             display warning message
---• |dn#util#prompt|            display prompt message
---• |dn_utils.menu_select|      select item from menu
---• |dn#util#help|              user can select from help topics
---• |dn#util#getSelection|      returns currently selected text
---
---Lists
---• |dn#util#listExchangeItems| exchange two elements in the same list
---• |dn#util#listSubtract|      subtract one list from another
---• |dn#util#listToScreen|      formats list for screen display
---• |dn#util#listToScreenColumns|
---                            formats list for columnar screen display
---• |dn#util#listToText|        convert list to text fragment
---
---Programming
---• |dn#util#unusedFunctions|   checks for uncalled functions
---• |dn#util#insertMode|        switch to insert mode
---• |dn_utils.execute_shell_command|
---                            execute shell command
---• |dn#util#exceptionError|    extract error message from exception
---• |dn_utils.scriptnames|      display scripts in location list
---• |dn#util#filetypes|         get list of available filetypes
---• |dn_utils.sleep|            pause script execution for defined time
---• |dn_utils.setup|            initialise/set up plugin
---• |dn_utils.shell_escape|     escape shell command
---• |dn#util#showFiletypes|     display list of available filetypes
---• |dn_utils.runtimepaths|     get list of runtime paths
---• |dn_utils.showRuntimepaths| display runtime paths
---• |dn#util#isMappedTo|        find mode mappings for given |{rhs}|
---• |dn#util#updateUserHelpTags|
---                            rebuild help tags in rtp "doc" subdirs
---• |dn#util#os|                determine operating system family
---• |dn#utilis#isWindows|       determine whether using windows OS
---• |dn#utilis#isUnix|          determine whether using unix-like OS
---
---Version control
---• |dn#util#localGitRepoFetch| perform a fetch on a local git repository
---• |dn#util#localGitRepoUpdatedRecently|
---                            check that local repo is updated
---
---String manipulation
---• |dn#util#stripLastChar|     removes last character from string
---• |dn#util#insertString|      insert string at current cursor location
---• |dn#util#trimChar|          removes leading and trailing chars
---• |dn#util#entitise|          replace special html chars with entities
---• |dn#util#deentitise|        replace html entities with characters
---• |dn_utils.dumbify_quotes|   replace smart quotes with straight quotes
---• |dn_utils.stringify|        convert variable to string
---• |dn#util#matchCount|        finds number of occurrences of string
---• |dn#util#padInternal|       pad string at internal location
---• |dn#util#padLeft|           left pad string
---• |dn#util#padRight|          right pad string
---• |dn#util#substitute|        perform global substitution in file
---• |dn_utils.change_caps|      changes capitalisation of line/selection
---• |dn_utils.split|            split string on separator
---• |dn_utils.wrap|             wrap string sensibly
---
---Tables
---• |dn_utils.is_table_value|   check whether var is a value in table
---• |dn_utils.pairs_by_keys|    iterate through table key-value pairs
---• |dn_utils.table_remove_empty_end_items|
---                            remove empty lines from end of sequence
---• |dn_utils.table_print|      print prettified table
---• |dn_utils.table_size|       get item or key-value pair count
---• |dn_utils.table_stringify|  prettify table
---
---Numbers
---• |dn_utils.valid_pos_int|    check whether input is valid positive int
---
---Miscellaneous
---• |dn#util#selectWord|        select |<cword>| under cursor
---• |dn#util#varType|           get variable type
---• |dn_utils.test|             utility function used for testing only
---@brief ]]

---@mod dn_utils.functions Functions

-- change_caps()
---Changes capitalisation of line or visual selection. The {mode} is "n"
---(|Normal-mode|) "i" (|Insert-mode|) or "v" (|Visual-mode|). The line or
---selection is replaced with the altered line or selection. Newlines in a
---selection are preserved.
---
---The user chooses the type of capitalisation from a menu:
---     upper case: convert to all uppercase characters
---     lower case: convert to all lowercase characters
---  sentence case: convert the first character to uppercase and all other
---                 characters to lowercase
---     start case: convert the first letter of each word to uppercase and
---                 all other letters to lower case
---     title case: capitalises first and last words, and all other words
---                 except articles, prepositions and conjunctions of fewer
---                 than five letters
---@return nil _ No return value
function dn_utils.change_caps()
  -- can represent "" as _t("<C-v>") where _t() is a local function
  local C_v = _t("<C-v>")
  -- get mode: n=normal, i=insert, v=charwise-visual,
  --           V=linewise-visual, =blockwise-visual
  local mode = vim.api.nvim_get_mode().mode
  local expected_modes = { "n", "i", "v", "V", C_v }
  assert(dn_utils.is_table_value(expected_modes, mode), "Invalid mode character: " .. mode)
  -- variables
  local is_line_replace_mode = dn_utils.is_table_value({ "n", "i" }, mode)
  local is_visual_replace_mode = dn_utils.is_table_value({ "v", "V", C_v }, mode)
  -- get case type
  local options = {
    ["Upper case"] = "upper",
    ["Lower case"] = "lower",
    ["Capitalise every word"] = "start",
    ["Sentence case"] = "sentence",
    ["Title case"] = "title",
  }
  local case_type = dn_utils.menu_select(options, "Select case:")
  if case_type == nil then
    vim.api.nvim_echo({ { "Case change aborted", "WarningMsg" } }, true, {})
    return false
  end
  -- operate on current line (normal or insert mode)
  if is_line_replace_mode then
    local line = vim.api.nvim_get_current_line()
    line = _change_caps(line, case_type)
    vim.api.nvim_set_current_line(line)
  -- operate on visual selection
  elseif is_visual_replace_mode then
    -- get selection
    local _, ls, cs = unpack(vim.fn.getpos("v"))
    local _, le, ce = unpack(vim.fn.getpos("."))
    -- transpose position coordinates if region defined in backward direction
    if ls > le or (ls == le and cs > ce) then
      local temp = { ls, cs }
      ls = le
      le = temp[1]
      cs = ce
      ce = temp[2]
    end
    -- getpos() is partially broken because it uses the start and end positions of the *cursor*, not the selection:
    -- • this does not matter for "v" (charwise-visual) mode
    -- • this does not matter for "" (blockwise-visual) mode
    -- • this causes wrong results in "V" (linewise-visual) mode
    if mode == "V" then
      cs, ce = 1, -1
    end
    -- can't use |nvim_buf_get_text()| to retrieve selected text because it
    -- acts as though the mode is "v" (charwise-visual), which makes it
    -- unusable as a general solution for all visual modes -- use
    -- |vim.region()| instead
    -- vim.region() requires reg_type param (4th param) of "b" instead of ""
    -- in blockwise-visual mode, even though the |setreg()| help (referenced by
    -- vim.region() help) states they are equivalent, so switch all visual mode
    -- codes to the preferred vim.region() reg_type codes
    local reg_types = { v = "c", V = "l", [C_v] = "b" }
    local reg_type = reg_types[mode]
    -- subtract 1 from coords because vim.region() uses zero-based coordinates
    local region = vim.region(0, { ls - 1, cs - 1 }, { le - 1, ce - 1 }, reg_type, false)
    -- vim.region is partially broken:
    -- • correct output in "v" (charwise-visual) mode
    -- • correct output in "V" (linewise-visual) mode, except
    --   that it indicates end of line with -1 for all lines except the last,
    --   in which end of line is indicated with -2
    -- • incorrect output in "" (blockwise-visual) mode, where the
    --   first and last rows are correct but the intervening rows give whole-
    --   line start and end columns instead of using the columns from the
    --   start and end coordinates
    -- build single string containing selecter lines (joined by newlines)
    local selected_lines = {}
    for line_no, cols in dn_utils.pairs_by_keys(region) do
      -- rebuild region table as we go to capture line data
      region[line_no] = {}
      region[line_no].cols = cols
      -- in blockwise-visual mode ensure
      -- all lines have correct start and end cols
      if mode == C_v then
        local cv_cols = { cs - 1, ce - 1 }
        region[line_no].cols = cv_cols
        cols = cv_cols
      end
      local line = vim.fn.getline(line_no + 1)
      region[line_no].line = line
      local line_length = line:len() - 1
      region[line_no].line_length = line_length
      -- vim.region() returns -1 or -2
      -- for end of line
      if cols[2] < 0 then
        region[line_no].cols[2] = line_length
        cols[2] = line_length
      end
      -- get selected text in line and add to table
      table.insert(selected_lines, line:sub(cols[1] + 1, cols[2] + 1))
    end
    local selection = table.concat(selected_lines, "\n")
    -- change case
    local changed = _change_caps(selection, case_type)
    local changed_lines = dn_utils.split(changed, "\n")
    -- replace selection with changed text
    for line_no, line_data in dn_utils.pairs_by_keys(region) do
      -- need to adjust line_num and cols by +1 because vim.region() is 0-based
      -- while functions used here are 1-based
      local line_num = line_no + 1
      local startcol, endcol = line_data.cols[1] + 1, line_data.cols[2] + 1
      local line = line_data.line
      local line_length = line_data.line_length
      local replace = ""
      -- get line part before selected text
      replace = replace .. line:sub(0, startcol - 1)
      -- get selected text
      -- • the elements of 'changed_lines' correspond to line_no-line_data
      --   pairs in 'region' when 'region' ordered by line_no
      -- • consume 'changed_lines' elements 1 per loop
      replace = replace .. table.remove(changed_lines, 1)
      -- get line part after selected text
      replace = replace .. line:sub(endcol + 1, line_length + 1)
      -- replace line with changed text
      vim.fn.setline(line_num, replace)
    end
  else
    error("Mode param is '" .. mode .. "'; must be [n|i|v]")
  end
end

-- clear_prompt()
---Clear command line.
---@return nil _ No return value
function dn_utils.clear_prompt()
  vim.api.nvim_command("normal! :")
end

-- dumbify_quotes()
---Convert "smart" quotes and apostrophes in the current buffer to their
---corresponding "dumb" equivalents.
---
---The "smart" characters are:
---• “ - left double quotation mark (U+201C)
---• ” - right double quotation mark (U+201D)
---• ‘ - left single quotation mark (U+2018)
---• ’ - right single quotation mark, apostrophe (U+2019)
---
---The "dumb" equivalents these characters are converted to are:
---• " - quotation mark (U+0022)
---• ' - apostrophe, single quotation mark (U+0027)
---@return nil _ No return value
function dn_utils.dumbify_quotes()
  dn_utils.info("Dumbifying smart double quotes...")
  dn_utils.substitute("[“”]", '"')
  dn_utils.info("Dumbifying smart single quotes...")
  dn_utils.substitute("[‘’]", "'")
end

-- error(messages)
---Display error messages(s).
---While string values are expected, any non-string values are stringified by
---|dn_utils.stringify|.
---@param ... string|any Error messages to display.
---@return nil _ No return value
function dn_utils.error(...)
  local messages = {}
  for _, message in ipairs({ ... }) do
    if type({ message }) == "string" then
      table.insert(messages, message)
    else
      table.insert(messages, dn_utils.stringify(message))
    end
  end
  vim.api.nvim_err_writeln(table.concat(messages, "\n"))
end

-- execute_shell_command(...)
---Execute shell command. Note that the shell command is escaped prior to
---execution.
---@param ... string Elements of shell command to execute,
---e.g., "ls", "-lA"
---@return table _ Dictionary containing information about execution, with keys:
---• command: (string) Command executed by the shell
---• exit_code: (number) Shell command exit code
---• stdout: (string) Shell command standard output
---• stderr: (string) Shell command standard error
---@usage [[
---local ret = dn_utils.execute_shell_command("ls", "-lA")
---if ret.exit_status ~= 0 then
---  error(ret.stderr)
---end
---@usage ]]
function dn_utils.execute_shell_command(...)
  -- credit: https://stackoverflow.com/a/42644964
  local stdout_file = os.tmpname()
  local stderr_file = os.tmpname()

  -- ignore spurious param-type-mismatch errors for following line
  local command = dn_utils.shell_escape({ ... })

  local exit_status = os.execute(command .. " > " .. stdout_file .. " 2> " .. stderr_file)

  local stdout_fh = assert(io.open(stdout_file, "r"))
  local stdout = stdout_fh:read("*all")

  local stderr_fh = assert(io.open(stderr_file, "r"))
  local stderr = stderr_fh:read("*all")

  stdout_fh:close()
  stderr_fh:close()

  os.remove(stdout_file)
  os.remove(stderr_file)

  -- ignore spurious return-type-mismatch errors for 'exit_status'
  -- in following line
  local retval = { command = command, exit_status = exit_status, stdout = stdout, stderr = stderr }
  return retval
end

-- get_file_dir()

---Get directory of file being edited.
---Returns empty string if the buffer is not associated with a file.
---@return string _ Directory path
function dn_utils.get_file_dir()
  -- get file path
  local path = vim.api.nvim_buf_get_name(0)
  if path:len() == 0 then
    return ""
  end
  -- extract directory component
  -- • based on https://stackoverflow.com/a/12191225
  local dir = path:match("(.-)[^\\/]-%.?[^%.\\/]*$")
  return dir
end

-- get_rtp_file(filename)

---Finds a file if it is located anywhere under the directories in
---runtimepath. Both regular files and symlinks will match.
---Returns a table sequence with all matching filepaths.
---The table is empty if no matching files were found.
---An empty table is returned if the filename is a zero-length string.
---@param filename string Name of file to search for
---@return table _ Sequence of matching filepaths (may be empty)
function dn_utils.get_rtp_file(filename)
  assert(type(filename) == "string", "Expected string, got " .. type(filename))
  if filename:len() == 0 then
    return {}
  end

  local matches = {}

  local _scandir
  _scandir = function(_dir)
    local handle = vim.loop.fs_scandir(_dir)
    assert(handle ~= nil, "got nil handle on dir: " .. _dir)
    while true do
      local item, item_type = vim.loop.fs_scandir_next(handle)
      if not item then
        break
      end
      local item_path = string.format("%s/%s", _dir, item)
      if item_type == "directory" then
        _scandir(item_path)
      elseif item_type == "file" or item_type == "link" then
        if item == filename then
          table.insert(matches, item_path)
        end
      else
        error("unknown scandir item type: " .. item_type)
      end
    end
  end

  local paths = dn_utils.runtimepaths()
  for _, path in ipairs(paths) do
    _scandir(path)
  end

  return matches
end

-- info(messages)
---Display messages(s).
---While string values are expected, any non-string values are stringified by
---|dn_utils.stringify|.
---@param ... string|any Messages to display.
---@return nil _ No return value
function dn_utils.info(...)
  local messages = {}
  for _, message in ipairs({ ... }) do
    if type({ message }) == "string" then
      table.insert(messages, message)
    else
      table.insert(messages, dn_utils.stringify(message))
    end
  end
  local output = table.concat(messages, "\n")
  vim.api.nvim_echo({ { output } }, true, {})
end

-- is_table_value(tbl, str)
-- credit: https://stackoverflow.com/a/64718495
---Test whether a table contains a specific string.
---Will recurse through nested tables.
---The string must match the entire table value.
---@param tbl table Table to search
---@param str any Value to search for (is converted to string)
---@return boolean _ Whether the table contains the provided string as a value
function dn_utils.is_table_value(tbl, str)
  -- check params
  assert(type(tbl) == "table", "Expected a table, got a " .. type(tbl))
  str = tostring(str)

  -- recurse through table
  local found = false
  for _, value in pairs(tbl) do
    if type(value) == "table" then
      found = dn_utils.is_table_value(value, str)
      if found then
        break
      end
    elseif tostring(value) == str then
      return true
    end
  end

  return found
end

-- menu_select(menu[, prompt[, recursive]])
-- the last parameter is 'hidden', i.e., it is not part of the
-- public interface
---Select an option from a multi-level sequence or table menu.
---
---An optional [prompt] string can be provided to this function; the default
---value is "Select an option:". Empty strings are ignored. An empty menu
---causes an error.
---
---The selected menu option (or its associated value) is returned, with a
---|luaref-nil| -indicating no item was selected.
---
---In the following discussion a "simple" menu is one without any submenus,
---and "simple" variables are string, number, boolean, and nil. A "simple"
---sequence has elements which are all either simple variables or single
---key-value dictionaries whose values are also simple variables. A "simple"
---table has values which are all simple variables.
---
---If a simple sequence menu is provided, its simple elements are displayed
---in the menu and returned if selected. If a sequence item is a dictionary
---containing one key-value pair, the key is displayed in the menu and, if
---selected, its value is returned. (It is a fatal error if a sequence item
---is a dictionary containing multiple key-value pairs.)
---
---If a simple dictionary menu is provided, its keys form the menu items and
---when an item is selected its corresponding value is returned. Because the
---order of key-value pairs in a dictionary is undefined, the order of menu
---items arising from a dictionary menu cannot be predicted.
---
---Submenus can be added to both sequence and dictionary menus. In such a
---case the header for the submenu, or child menu, is indicated in the parent
---menu by appending an arrow ( ->) to the header option in the parent menu.
---Adding a submenu Dict is easy - the new submenu is added as a new
---key-value pair to the parent menu. The new key is the submenu header in
---the parent menu while the new value is a sequence or dictionary defining
---the new submenu options.
---
---A single menu can contain a mixture of sequence and dictionary elements,
---and multi-level menus can become complex.
---
---Errors are thrown if a menu item is not a valid data type, if the menu is
---neither a sequence nor a dictionary, and if a menu has no items.
---
---The inbuilt vim |inputlist()| is used for small and medium sized lists of
---menu options (up to around 20 options). For menus with more options an
---embedded |python3| script is used that has a sole external dependency on
---the tkinter package (https://docs.python.org/3/library/tkinter.html).
---@param menu table Menu items
---@param prompt string Prompt (optional, default: 'Select an option:')
---@return string _ Selected menu option
function dn_utils.menu_select(menu, prompt, recursive)
  -- process parameters
  -- • recursive
  --   - this is a hidden parameter used only by the function when calling
  --     itself recursively, and should never be used by an external caller
  recursive = recursive or 0
  assert(type(recursive) == "number", "Expected number, got " .. type(recursive))
  -- • prompt
  if not (prompt ~= nil and prompt ~= "") then
    prompt = "Select an option:"
  end
  -- • menu
  assert(type(menu) == "table", "Expected a table menu, got a " .. type(menu))
  assert(next(menu) ~= nil, "Menu table is empty")
  local items
  if recursive == 0 then
    -- first call
    -- normalise menu to 'sequence of dictionaries'
    -- this includes checking menu validity
    items = _menu_normalise(menu)
  else
    items = vim.deepcopy(menu)
  end
  recursive = recursive + 1

  -- process items to build parallel sequences of options and return values
  local options = {}
  local return_values = {}
  local item_size
  for _, item in ipairs(items) do
    -- sequence menu items are single-pair dictionaries whose values are either:
    -- • simple data types (for plain menu options)
    -- • sequences (for submenus)
    -- ignore empty dictionaries
    if next(item) ~= nil then
      -- cannot have multiple entries
      item_size = dn_utils.table_size(item)
      if item_size > 1 then
        error("Multiple entries in dictionary menu option:\n\n" .. dn_utils.stringify(item))
      end
      -- get key (option) and value (retval or submenu)
      local key, value = _extract_single_element_dict_contents(item)
      local option = dn_utils.stringify(key)
      -- process depending on whether submenu or simple option
      local retval
      if type(value) == "table" then -- sequence (submenu)
        option = option .. " ->"
        retval = vim.deepcopy(value)
      else -- simple data type (plain option)
        retval = value
      end
      table.insert(options, option)
      table.insert(return_values, retval)
    end
  end

  -- select from menu
  while true do
    local pick = _menu_ui_select(prompt, options)
    local selection = return_values[pick]
    -- recurse if selected a submenu, otherwise return selection
    if type(selection) == "table" then
      -- if submenu selection returned nil, do not return it in turn,
      -- but repeat current menu selection
      local recursive_selection = dn_utils.menu_select(selection, prompt, recursive)
      if not recursive or (recursive and recursive_selection ~= nil) then
        return recursive_selection
      end
    else
      return selection
    end
  end
end

-- pairs_by_key(tbl, [sort_fn])
---Iterator returning key-value pairs in order of sorted keys. If no sort
---function is provided the default sort method for the lua table.sort
---function is used.
---@param tbl table Dictionary table to process
---@param sort_fn function|nil Sort function (default = default sort
---method for lua function "table.sort")
---@return function _ Iterator that presents table key-value pairs in key sort
---order
---@usage [[
---for name, line in pairs_by_keys(lines) do
---  print(name, line)
---end
---@usage ]]
function dn_utils.pairs_by_keys(tbl, sort_fn)
  -- credit: https://www.lua.org/pil/19.3.html
  -- process args
  assert(type(tbl) == "table", "Expected table, got " .. type(tbl))
  local arg_type = type(sort_fn)
  assert(arg_type == "function" or arg_type == "nil", "Expected function, got " .. arg_type)

  -- get sorted list of keys
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end
  if sort_fn then
    table.sort(keys, sort_fn)
  else
    table.sort(keys)
  end
  -- create iterator function
  local idx = 0 -- iterator variable
  local iter = function() -- iterator function
    idx = idx + 1
    if keys[idx] == nil then
      return nil
    else
      return keys[idx], tbl[keys[idx]]
    end
  end
  return iter
end

-- runtimepaths()
---Get a list of vim's runtimepath directories.
---@return table _ List of runtimepath directories
function dn_utils.runtimepaths()
  -- rtp is a global option
  local val = vim.api.nvim_get_option_value("runtimepath", { scope = "global" })
  local paths = dn_utils.split(val, ",")
  return paths
end

-- scriptnames()
---Display the output of `:scriptnames` in a location list for the current
---window.
---@return nil _ No return value
function dn_utils.scriptnames()
  -- get output from ":scriptnames" command
  local output_str = vim.api.nvim_cmd({ cmd = "scriptnames" }, { output = true })
  local output_lines = dn_utils.split(output_str, "\n")
  -- build list of items for location list
  local list = {}
  for _, script in ipairs(output_lines) do
    local elements = dn_utils.split(script, ":")
    local text = vim.fn.trim(elements[1])
    local filename = vim.fn.trim(elements[2])
    local item = { text = text, filename = filename }
    table.insert(list, item)
  end
  -- display location list
  vim.fn.setloclist(0, list)
  vim.cmd.lopen()
end

-- setup(opts)
---Called explicitly by users to configure this plugin.
---@param opts table Plugin options
---@return nil _ No return value
function dn_utils.setup(opts)
  -- process options
  opts = opts or {}
  dn_utils.options = vim.tbl_deep_extend("keep", opts, dn_utils.options)

  -- do here any startup your plugin needs, like creating commands and
  -- mappings that depend on values passed in options
  --vim.api.nvim_create_user_command("MyUtilsGreeting", dn_utils.greet, {})
end

-- shell_escape(...)
---Escape shell command elements.
---@param ... string Shell command elements
---@return string _ Assembled escaped shell command
---@usage [[
---local cmd_str = dn_utils.shell_escape("ls", "-lA")
---@usage ]]
function dn_utils.shell_escape(...)
  local args = vim.fn.flattennew({ ... })
  local escaped = {}
  for _, arg in ipairs(args) do
    local str = tostring(arg)
    if str:match("[^A-Za-z0-9_/:=-]") then
      str = "'" .. str:gsub("'", "'\\''") .. "'"
    end
    table.insert(escaped, str)
  end
  return table.concat(escaped, " ")
end

-- show_runtimepaths()
---Display runtime paths, one per line. Attempts to wrap the output sensibly.
---@return nil _ No return value
function dn_utils.show_runtimepaths()
  local winwidth = vim.api.nvim_win_get_width(0) - 1
  local paths = dn_utils.runtimepaths()
  for _, path in ipairs(paths) do
    dn_utils.info(dn_utils.wrap(path, { width = winwidth }))
  end
end

-- sleep(sec)
---Pause script for a specified number of seconds.
---@param sec number Number of seconds to pause script execution
---@return nil _ No return value
function dn_utils.sleep(sec)
  -- credit: http://lua-users.org/wiki/SleepFunction
  assert(type(sec) == "number", "Expected number, got " .. type(sec))
  assert(dn_utils.valid_pos_int(sec), "Expected positive integer, got " .. dn_utils.stringify(sec))
  local ntime = os.time() + sec
  repeat
  until os.time() > ntime
end

-- split(str, [sep])
---Split a string on a separator character.
---@param inputstr string String to split
---@param sep string|nil Separator which can be any valid
---|luaref-patterns|, defaults to lua character
---class "%s"
---@return table _ Array of split items
function dn_utils.split(inputstr, sep)
  -- process args
  assert(type(inputstr) == "string", "Expected string, got " .. type(inputstr))
  sep = sep or "%s"
  assert(type(sep) == "string", "Expected string, got " .. type(sep))

  -- perform split
  local t = {}
  for field, s in inputstr:gmatch("([^" .. sep .. "]*)(" .. sep .. "?)") do
    table.insert(t, field)
    if s == "" then
      return t
    end
  end

  -- this return is redundant because function exits in 'for' loop above
  -- this return is needed to avoid linter complaint about missing 'return'
  return t
end

-- stringify(var)
---Convert variable to string and return the converted string.
---"big-arrow" (" => ") notation is used between keys and values. Consider
---using |lua_tostring()| instead of this function.
---@param var any|nil Variable to be stringified
---@return string _ Stringified variable
function dn_utils.stringify(var)
  local var_type = type(var)
  -- simple variables that can be converted with tostring()
  local simple = { "string", "number", "boolean", "nil" }
  if dn_utils.is_table_value(simple, var_type) then
    return tostring(var)
  end
  -- complex variables requiring vim.inspect()
  local complex = { "userdata", "function", "table" }
  if dn_utils.is_table_value(complex, var_type) then
    return vim.inspect(var)
  end
  -- should never reach here
  error("Unknown variable type: " .. var_type)
end

-- substitute(pattern, replace, opts)
---Performs a configuration-agnostic substitution in the current buffer.
---For the duration of the substitution 'gdefault' is set to off.
---If the default flags are used, then for the duration of the substitution
---'gdefault' is on, case is ignored (the 'ignorecase' and 'smartcase'
---options are ignored), and errors are not shown.
---The cursor does not move.
---The range is the whole file by default.
---@param pattern string The |pattern| to replace
---@param replace string The replacement string (can
---be |sub-replace-special|)
---@param opts table|nil Optional configuration options
---• {flags} (string) Search flags, see |:s_flags|
---  (default= "egi")
---• {firstline} (number) First line of
---  replacement range (default=0)
---• {lastline} (number) Last line of replacement
---  range (default=line("$"))
---• {delim} (string) Search delimiter character,
---  must be accepted by `:s` (default=/)
function dn_utils.substitute(pattern, replace, opts)
  -- check params
  assert(type(pattern) == "string", "Expected string, got " .. type(pattern))
  assert(pattern ~= "", "Empty pattern")
  assert(type(replace) == "string", "Expected string, got " .. type(replace))
  assert(replace ~= "", "Empty replace string")
  opts = opts or {}
  assert(type(opts) == "table", "Expected table, got " .. type(opts))
  -- process options
  local flags = "egi"
  if opts.flags then
    assert(type(opts.flags) == "string", "Expected string, got " .. type(opts.flags))
    flags = opts.flags
  end
  local firstline = 0
  if opts.firstline then
    assert(type(opts.firstline) == "number", "Expected number, got " .. type(opts.firstline))
    firstline = opts.firstline
  end
  local lastline = vim.fn.line("$")
  if opts.lastline then
    assert(type(opts.lastline) == "number", "Expected number, got " .. type(opts.lastline))
    lastline = opts.lastline
  end
  local delim = "/"
  if opts.delim then
    assert(type(opts.delim) == "string", "Expected character, got " .. type(opts.delim))
    local delim_length = opts.delim:len()
    assert(delim_length > 0, "Expected character, got empty string")
    assert(delim_length == 1, "Expected character, got '" .. opts.delim .. "'")
    delim = opts.delim
  end
  -- save cursor
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  -- preserve gdefault option
  local opt_gdefault = vim.api.nvim_get_option_value("gdefault", {})
  vim.opt.gdefault = false
  -- perform substitution
  local cmd = firstline .. "," .. lastline .. "s" .. delim .. pattern .. delim .. replace .. delim .. flags
  local output = vim.api.nvim_exec2(cmd, { output = true })
  -- restore gdefault option
  vim.api.nvim_set_option_value("gdefault", opt_gdefault, {})
  -- restore cursor
  local endline = vim.fn.line("$")
  if line > endline then
    line = endline
  end
  vim.api.nvim_win_set_cursor(0, { line, col })
  -- display feedback
  dn_utils.info(output.output)
end

-- table_print(tbl, count, pad)
---Print prettified table to console.
---@param tbl table Table to convert to a string
---@param count number|nil Number of pads between string tokens
---(default=1)
---@param pad string|nil String to use for indenting and padding
---(default=<Tab>)
function dn_utils.table_print(tbl, count, pad)
  -- credit: https://gist.github.com/jackbritchford/5f0d5f6dbf694b44ef0cd7af952070c9
  print(_tbl_to_str(tbl, count, 0, pad))
end

-- table_remove_empty_end_items(seq)
---Remove empty (no characters or only spaces) items from the end of a table
---sequence.
---@param source table Table sequence to trim
---@return table _ Sequence with empty terminal items removed
function dn_utils.table_remove_empty_end_items(source)
  -- credit:
  -- https://www.alanwsmith.com/pages/lua-remove-empty-elements-from-a-list--2xget6vp/

  -- process param
  assert(type(source) == "table", "Expected table, got " .. type(source))
  assert(vim.tbl_islist(source), "Table is not a sequence")
  -- copy items except for empty end items
  -- but this reverses order of sequence
  local reversed = {}
  local load_counter = #source
  local hit_content = false
  local match_start
  while load_counter > 0 do
    -- search for nothing but optional spaces
    match_start, _ = source[load_counter]:find("^%s*$")
    -- if no match then not empty, i.e., contains non-space content
    if match_start == nil then
      hit_content = true
      table.insert(reversed, source[load_counter])
    elseif hit_content == true then
      table.insert(reversed, source[load_counter])
    end
    load_counter = load_counter - 1
  end
  -- reverse order again to get original order
  local trimmed = {}
  local reverse_counter = #reversed
  while reverse_counter > 0 do
    table.insert(trimmed, reversed[reverse_counter])
    reverse_counter = reverse_counter - 1
  end
  -- return resulting sequence
  return trimmed
end

-- table_size(tbl)
---Determine the number of elements in a table (sequence or dictionary).
---Includes nil values. Compare with |vim.tbl_count()| which excludes nil
---values from its count.
---
---A fatal error is raised if the parameter is not a table.
---@param tbl table Table to analyse
---@return number _ Integer size of table
function dn_utils.table_size(tbl)
  assert(type(tbl) == "table", "Expected a table, got a " .. type(tbl))
  local size = 0
  for _, _ in pairs(tbl) do
    size = size + 1
  end
  return size
end

-- table_stringify(tbl, count, pad)
---Convert table to a prettified string.
---@param tbl table Table to convert to a string
---@param count number|nil Number of pads between string tokens
---(default=1)
---@param pad string|nil String to use for indenting and padding
---(default=<Tab>)
---@return string _ Pretty printed table
function dn_utils.table_stringify(tbl, count, pad)
  -- credit: https://gist.github.com/jackbritchford/5f0d5f6dbf694b44ef0cd7af952070c9
  count = count or 1
  return _tbl_to_str(tbl, count, 0, pad)
end

-- test()
---Function used for testing. Its interface is not stable.
---@return nil _ No return value
function dn_utils.test()
  -- stub
end

-- trim_char(str [, char])
---Remove leading and trailing character from a string.
---Note that |vim.trim()| can be used to remove leading and trailing
---whitespace from a string.
---@param str string String to trim
---@param char string|nil Characters to trim from each end of string
---(default=<Space>)
---@return string _ Trimmed string
function dn_utils.trim_char(str, char)
  -- process params
  assert(type(str) == "string", "Expected string, got " .. type(str))
  if char then
    assert(type(char) == "string", "Expected string, got " .. type(char))
    assert(char:len() > 0, "Expected character, got empty string")
    assert(char:len() == 1, "Expected character, got string: '" .. char .. "'")
  else
    -- default char
    char = "%s"
  end
  if not char:find("%w") then
    -- escape all non-alphanumeric chars to be safe
    char = "%" .. char
  end
  -- trim string
  local pattern = "^" .. char .. "*(.-)" .. char .. "*$"
  local trimmed, _ = str:gsub(pattern, "%1")
  return trimmed
end

-- valid_non_negative_int(var)
---Check whether variable is a non-negative integer. The integer can be zero or
---greater.
---@param var any Variable to check
---@return boolean _ Whether variable is a non-negative integer
function dn_utils.valid_non_negative_int(var)
  -- must be number
  if type(var) ~= "number" then
    return false
  end
  -- must be non-negative
  if var < 0 then
    return false
  end
  -- must be integer
  return (var % 1) == 0
end

-- valid_pos_int(var)
---Check whether variable is a positive (non-zero) integer.
---@param var any Variable to check
---@return boolean _ Whether variable is a positive integer
function dn_utils.valid_pos_int(var)
  -- must be number
  if type(var) ~= "number" then
    return false
  end
  -- must be greater than zero
  if var <= 0 then
    return false
  end
  -- must be integer
  return (var % 1) == 0
end

-- warning(messages)
---Display warning messages(s).
---While string values are expected, any non-string values are stringified by
---|dn_utils.stringify|.
---@param ... string|any Warning messages to display.
---@return nil _ No return value
function dn_utils.warning(...)
  local messages = {}
  for _, message in ipairs({ ... }) do
    if type({ message }) == "string" then
      table.insert(messages, message)
    else
      table.insert(messages, dn_utils.stringify(message))
    end
  end
  local output = table.concat(messages, "\n")
  vim.api.nvim_echo({ { output, "WarningMsg" } }, true, {})
end

-- wrap(message[, opts])    {{{1
---Wraps a message string sensibly at a specified column. The message must be
---a string and can contain newlines. It can be zero length. Both the wrap
---width and a hanging indent can be specified.
---
---If no hanging indent is specified, this function first attempts to wrap
---the message string using the system utility "fmt". (This is a utility
---which is found on all *nix systems as a core utility, and there are
---versions available for other operating systems. Although primarily
---intended for formatting C/C++, it does a good job of wrapping plain text.)
---If "fmt" is unavailable or unable to wrap the message string, this
---function performs the wrapping itself.
---@param message string Message to wrap
---@param opts table|nil Optional configuration options:
---• {width} (number) Column to wrap at. Must be
---  a positive integer. If it is set to zero the
---  message string is returned without
---  alteration. If it is less than 10, and not
---  zero, it is set to 10.
---• {hang} (number) Size of the hanging indent
---  in spaces. Must be a positive integer. If it
---  is set to zero there is no hanging indent.
---  The wrap width must be greater than than the
---  hanging indent by at least 10.
---@return string _ Wrapped message string
---@usage [[
---local winwidth = vim.api.nvim_win_get_width(0) - 1
---local wrapped = dn_utils.wrap(message, {width = winwidth})
---@usage ]]
function dn_utils.wrap(message, opts)
  -- process parameters
  -- • message
  assert(type(message) == "string", "Expected string, got " .. type(message))
  if message:len() == 0 then
    return message
  end
  -- • opts
  opts = opts or {}
  assert(type(opts) == "table", "Expected table, got " .. type(opts))
  local valid_opts = { "width", "hang" }
  for opt, _ in pairs(opts) do
    assert(dn_utils.is_table_value(valid_opts, opt), "Invalid option: " .. opt)
  end
  -- • width
  local width = opts.width or 79
  assert(
    dn_utils.valid_non_negative_int(width),
    "Expected non-negative integer, got " .. type(width) .. " " .. tostring(width)
  )
  if width == 0 then
    return message
  end
  if width < 10 then
    width = 10
  end
  -- • hang
  local hang = opts.hang or 0
  assert(
    dn_utils.valid_non_negative_int(hang),
    "Expected non-negative integer, got " .. type(hang) .. " " .. tostring(hang)
  )
  assert((width - hang) >= 10, "Width (" .. width .. ") must be at least 10 larger than indent (" .. hang .. ")")
  -- try to wrap using "fmt" if no hanging indent
  if hang == 0 then
    local ok, output = pcall(_wrap_fmt, { width = width })
    if ok then
      return output
    end
  end
  -- fall back to manual wrapping
  local wrapped = _wrap_manual(message, { width = width, hang = hang })
  return wrapped
end

---@mod dn_utils.mappings Mappings

-- \xa [n]
---@tag dn_utils.<Leader>xa
---@brief [[
---This mapping calls the function |dn_utils.test| in mode "n".
---@brief ]]
vim.keymap.set("n", "<Leader>xa", dn_utils.test, { desc = "Generic test function" })

-- \xc [n,v,i]
---@tag dn_utils.<Leader>xc
---@brief [[
---This mapping calls the function |dn_utils.change_caps| in modes "n", "v" and
---"i".
---@brief ]]
vim.keymap.set(
  { "n", "v", "i" },
  "<Leader>xc",
  dn_utils.change_caps,
  { desc = "Change capitalisation of line or selection" }
)

---@mod dn_utils.commands Commands

-- XDumbifyQuotes
---@tag dn_utils.DumbifyQuotes
---@brief [[
---Replaces smart quotes with plain ascii "straight" single quotes (apostrophes)
---and double quotes. Calls function |dn_utils.dumbify_quotes|.
---@brief ]]
vim.api.nvim_create_user_command("XDumbifyQuotes", function()
  dn_utils.dumbify_quotes()
end, { desc = "Replace smart quotes in buffer with plain ascii 'straight' quotes" })

-- XScriptnames
---@tag dn_utils.scriptnames
---@brief [[
---Displays output of `scriptnames` command in a location list. Calls function
---|dn_utils.scriptnames|.
vim.api.nvim_create_user_command("XScriptnames", function()
  dn_utils.scriptnames()
end, { desc = "Display output of scriptnames command in a loclist" })

return dn_utils
