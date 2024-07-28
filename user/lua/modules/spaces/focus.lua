local send_message = require('user.lua.modules.spaces.util').send_message


local YabaiCmds = {}

---@type ks.command.config[]
YabaiCmds.cmds = {

  {
    id = 'spaces.focus.north',
    title = 'Focus window above',
    mods = 'lil',
    key = 'up',
    flags = { 'no-alert' },
    exec = send_message('window --focus north'),
  },
  {
    id = 'spaces.focus.south',
    title = 'Focus window below',
    mods = 'lil',
    key = 'down',
    flags = { 'no-alert' },
    exec = send_message('window --focus south'),
  },
  {
    id = 'spaces.focus.east',
    title = 'Focus window right',
    mods = 'lil',
    key = 'right',
    flags = { 'no-alert' },
    exec = send_message('window --focus east'),
  },
  {
    id = 'spaces.focus.west',
    title = 'Focus window left',
    mods = 'lil',
    key = 'left',
    flags = { 'no-alert' },
    exec = send_message('window --focus west'),
  },
  {
    id = 'spaces.focus.next_space',
    title = 'Go to next space (right)',
    mods = 'ctrl',
    key = 'right',
    flags = { 'no-alert' },
    exec = send_message('space mouse --focus next'),
  },
  {
    id = 'spaces.focus.prev_space',
    title = 'Go to previous space (left)',
    mods = 'ctrl',
    key = 'left',
    flags = { 'no-alert' },
    exec = send_message('space mouse --focus prev'),
  },
  {
    id = 'spaces.focus.next_display',
    title = 'Go to next display (right)',
    mods = 'ctrl',
    key = '[',
    flags = { 'no-alert' },
    exec = send_message('display --focus west'),
  },
  {
    id = 'spaces.focus.prev_display',
    title = 'Go to previous display (left)',
    mods = 'ctrl',
    key = ']',
    flags = { 'no-alert' },
    exec = send_message('display --focus east'),
  },
  
}

return YabaiCmds