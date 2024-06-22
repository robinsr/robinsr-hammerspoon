local send_message = require('user.lua.modules.spaces.util').send_message


local YabaiCmds = {}

---@type CommandConfig[]
YabaiCmds.cmds = {

  {
    id = 'spaces.focus.north',
    title = 'Focus window above',
    mods = 'meh',
    key = 'up',
    exec = send_message('window --focus north'),
  },
  {
    id = 'spaces.focus.south',
    title = 'Focus window below',
    mods = 'meh',
    key = 'down',
    exec = send_message('window --focus south'),
  },
  {
    id = 'spaces.focus.east',
    title = 'Focus window right',
    mods = 'meh',
    key = 'right',
    exec = send_message('window --focus east'),
  },
  {
    id = 'spaces.focus.west',
    title = 'Focus window left',
    mods = 'meh',
    key = 'left',
    exec = send_message('window --focus west'),
  },
  {
    id = 'spaces.focus.next_space',
    title = 'Go to next space (right)',
    mods = 'ctrl',
    key = 'right',
    exec = send_message('space mouse --focus next'),
  },
  {
    id = 'spaces.focus.prev_space',
    title = 'Go to previous space (left)',
    mods = 'ctrl',
    key = 'left',
    exec = send_message('space mouse --focus prev'),
  },
  {
    id = 'spaces.focus.next_display',
    title = 'Go to next display (right)',
    mods = 'ctrl',
    key = '[',
    exec = send_message('display --focus west'),
  },
  {
    id = 'spaces.focus.prev_display',
    title = 'Go to previous display (left)',
    mods = 'ctrl',
    key = ']',
    exec = send_message('display --focus east'),
  },
  
}

return YabaiCmds