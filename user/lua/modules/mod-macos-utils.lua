local keys = require 'user.lua.model.keys'
local logr = require 'user.lua.util.logger'

local log = logr.new('mod-macos', 'info')


local refresh_finder_windows = {
  id    = 'user.finder.refresh',
  title = 'Refresh finder windows if files are not updating correctly',
  icon  = '@/resources/images/icons/macos-finder.tmpl.png',
  key   = keys.code.END,
  mods  = keys.preset.btms,
  exec  = function(cmd, ctx, params)
    local ok, result, err = hs.osascript.applescript([[
      tell application "Finder" to tell front window to update every item
    ]])

    if not ok then
      log.ef("AppleScript failed with error: %s", result)

      return { err = result }
    end

    return { ok = "Refreshed finder windows" }
  end,
}


return {
  module = "MacOS Utils",
  cmds = {
    refresh_finder_windows
  }
}