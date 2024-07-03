local desk    = require 'user.lua.interface.desktop'
local collect = require 'user.lua.lib.collection'
local lists   = require 'user.lua.lib.list'
local fs      = require 'user.lua.lib.fs'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local Command = require 'user.lua.model.command'
local logr    = require 'user.lua.util.logger'
local delay   = require 'user.lua.util'.delay


local log = logr.new('commands', 'info')

local EVT_FILTER = '!*.(evt|event|events).*'


---@type Command[]
local command_list = {
  {
    id = 'ks.evt.onLoad',
    exec = function()
      log.i('Running KittySupreme onLoad...')
      KittySupreme.services.sketchybar:setFrontApp('Hammerspoon Loaded!')
    end,
  },
  {
    id = 'ks.commands.showHSConsole',
    title = "Show console",
    icon = "code",
    key = "I",
    mods = "btms",
    exec = function()
      hs.openConsole(true)
    end,
  },
  {
    id = 'ks.commands.toggle_darkmode',
    title = "Toggle dark mode",
    icon = "code",
    exec = function()
      console.setDarkMode(desk.darkMode())
    end,
  },
  {
    id = 'ks.commands.reloadConfig',
    title = "Reload Config",
    icon = "reload",
    key = "W",
    mods = "btms",
    exec = function(cmd)
      delay(0.75, hs.reload)
      return cmd:hotkeyLabel()
    end,
  },
  {
    id = 'ks.commands.restartHS',
    title = "Relaunch Hammerspoon",
    icon = "reload",
    key = "X",
    mods = "btms",
    exec = function(cmd)
      delay(0.75, hs.relaunch)
      return cmd:hotkeyLabel()
    end,
  }
}


local function scanForCmds()
  -- Stepping back 3 steps on the call stack to get calling module's filepath
  -- local modInfo = debug.getinfo(3, 'S')
  -- local rootdir = string.match(modInfo.source, '^@(.*)/')
  local rootdir = hs.fs.currentDir() or '/asdf/asdf/asdf'
  local mods = fs.loaddir(rootdir, 'user.lua')

  local commands = {}
  for module, exports in pairs(mods) do
    if (types.isTable(exports) and tables.has(exports, 'cmds')) then
      for i, cmd in ipairs(exports.cmds) do
        table.insert(commands, tables.merge({}, cmd, { module = module }))
      end
    end
  end

  return commands
end

local Cmds = {}

function Cmds.getCommands()
  return lists(command_list)
    :concat(scanForCmds())
    :map(function(cmd) return Command:new(cmd) end)
end

return Cmds