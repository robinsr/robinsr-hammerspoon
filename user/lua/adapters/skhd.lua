local shell = require 'user.lua.interface.shell'

-- Get plist with: launchctl print gui/501/com.koekeishiya.yabai

local skhd = {
  restart = shell.wrap("skhd --restart-service"),
}

return skhd