local collect    = require 'user.lua.lib.collection'
local scan       = require 'user.lua.lib.scan'
local tabl       = require 'user.lua.lib.table'
local cmd        = require 'user.lua.model.command'
local ui         = require 'user.lua.ui'
local U          = require 'user.lua.util'


local log = U.log('commands', 'debug')


---@type Command[]
local command_list = {
  {
    id = 'KS.OnLoad',
    fn = function(ctx, params)
      log.i('Running KittySupreme onLoad...')
      KittySupreme.services.sketchybar.onLoad('Hammerspoon loaded!')
    end,
  },
  { 
    id = 'KS.ShowHSConsole',
    title = "Show console",
    menubar = cmd.menubar{ "general", "i", ui.icons.code },
    hotkey = cmd.hotkey{ "bar", "I" },
    fn = function()
      hs.openConsole(true)
    end,
  },
  {
    id = 'KS.ReloadConfig',
    title = "Reload KittySupreme",
    menubar = cmd.menubar{ "general", "w", ui.icons.reload },
    hotkey = cmd.hotkey{ "bar", "W", "Reload KittySupreme" },
    fn = function(ctx)
      U.delay(0.75, hs.reload)
    end,
  },
  {
    id = 'KS.RestartHS',
    title = "Reload Hammerspoon",
    menubar = cmd.menubar{ "general", "X", ui.icons.reload },
    hotkey = cmd.hotkey{ "bar", "X", "Restart Hammerspoon" },
    fn = function(ctx)
      U.delay(0.75, hs.relaunch)
    end,
  },
}

local function scanForCmds()
  -- Stepping back 3 steps on the call stack to get calling module's filepath
  local modInfo = debug.getinfo(3, 'S')
  local rootdir = string.match(modInfo.source, '^@(.*)/')
  local mods = scan.loaddir(rootdir, 'user.lua')

  local commands = {}
  for file, mod in pairs(mods) do
    if (tabl.haspath(mod, 'cmds')) then
      for i, cmd in ipairs(mod.cmds) do
        table.insert(commands, cmd)
      end
    end
  end

  return commands
end

return {
  getCommands = function()
    U.insert(command_list, table.unpack(scanForCmds()))
    
    return collect:new(command_list)
    -- return Collection:new(command_list)
  end
} 

