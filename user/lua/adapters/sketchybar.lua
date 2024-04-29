local shell = require 'user.lua.interface.shell'

local wrap = shell.wrap

local sketchybar = {
  update         = wrap("sketchybar --update"),
  reload         = wrap("sketchybar --reload"),
  trigger = {
    on_new_label = wrap("sketchybar --trigger ya_new_label YA_SPACE_ID=%d YA_LABEL='%s'"),
  },
}

return sketchybar