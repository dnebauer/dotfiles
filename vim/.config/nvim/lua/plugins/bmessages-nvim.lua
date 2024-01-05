--[[ ariel-frischer/bmessages.nvim : better neowim messages ]]

return {
  {
    "ariel-frischer/bmessages.nvim",
    event = "CmdlineEnter",
    keys = {
      {
        "<Leader>bm",
        "<Cmd>Bmessages<CR>",
        { silent = true, desc = "Display autoupdating message buffer" },
      },
    },
    opts = {
      -- timer_interval
      -- • time (milliseconds) between each update of the messages buffer
      -- • default = 1000
      --timer_interval = 1000,

      -- split_type
      -- • default split type for the messages buffers
      -- • can be 'vsplit' or 'split'
      -- • default = 'vsplit'
      split_type = "split",

      -- split_size_vsplit
      -- • size of the vertical split when opening the messages buffer
      -- • default = nil
      --split_size_vsplit = nil,

      -- split_size_split
      -- • size of the horizontal split when opening the messages buffer
      -- • default = nil
      --split_size_split = nil,

      -- autoscroll
      -- • automatically scroll to the latest message in the buffer
      -- • default = true
      --autoscroll = true,

      -- use_timer
      -- • use a timer to auto-update the messages buffer
      -- • when this is disabled, the buffer will not update,
      --   but the buffer becomes modifiable
      -- • default = true
      --use_timer = true,

      -- buffer_name
      -- • name of the messages buffer
      -- • default = 'bmessages_buffer'
      --buffer_name = "bmessages_buffer",

      -- disable_create_user_commands
      -- • don't add user commands `Bmessages[{vs,sp}]`
      -- • default = false
      --disable_create_user_commands = false,
    },
  },
}
