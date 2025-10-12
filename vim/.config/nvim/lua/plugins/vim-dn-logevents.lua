--[[ dnebauer/vim-dn-logevents : log autocmd events ]]

-- vim plugin
-- not part of default LazyVim

return {
  {
    "dnebauer/vim-dn-logevents",
    cmd = { "LogEvents", "EventLoggingStatus", "EventLogFile", "AnnotateEventLog", "DeleteEventLog" },
  },
}
