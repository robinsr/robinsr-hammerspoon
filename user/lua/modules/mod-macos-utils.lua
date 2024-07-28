

return {
  module = "MacOS Utils",
  cmds = {
    {
      id = 'system.finder.refresh',
      title = 'Refresh finder windows if files are not updating correctly',
      icon = 'info',
      key = 'end',
      mods = 'btms',
      exec = function(cmd, ctx, params)
        local ok, result, err = hs.osascript.applescript('tell application "Finder" to tell front window to update every item')

        if not ok then
          print(hs.inspect(err))
          error('Failed applescript run in '..cmd.id)
        end

        return "Refreshed finder windows"
      end,
    }
  }
}

