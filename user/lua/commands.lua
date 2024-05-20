local collect    = require 'user.lua.lib.collection'
local scan       = require 'user.lua.lib.scan'
local tables     = require 'user.lua.lib.table'
local cmd        = require 'user.lua.model.command'
local ui         = require 'user.lua.ui'
local logr       = require 'user.lua.util.logger'
local delay      = require 'user.lua.util'.delay


local log = logr.new('commands', 'debug')


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
    hotkey = cmd.hotkey("bar", "I"),
    fn = function()
      hs.openConsole(true)
    end,
  },
  {
    id = 'KS.ReloadConfig',
    title = "Reload KittySupreme",
    menubar = cmd.menubar{ "general", "w", ui.icons.reload },
    hotkey = cmd.hotkey("bar", "W", "Reload KittySupreme"),
    fn = function(ctx)
      delay(0.75, hs.reload)
    end,
  },
  {
    id = 'KS.RestartHS',
    title = "Reload Hammerspoon",
    menubar = cmd.menubar{ "general", "X", ui.icons.reload },
    hotkey = cmd.hotkey("bar", "X", "Restart Hammerspoon"),
    fn = function(ctx)
      delay(0.75, hs.relaunch)
    end,
  },
  {
    id = 'KS.TestWebviewText',
    hotkey = cmd.hotkey("bar", "F", "Test Webview Alert"),
    fn = function(ctx, params)
      log.i('Testing HS Webview...')
      require('user.lua.ui.webview').test()
    end,
  },
}

local function scanForCmds()
  -- Stepping back 3 steps on the call stack to get calling module's filepath
  -- local modInfo = debug.getinfo(3, 'S')
  -- local rootdir = string.match(modInfo.source, '^@(.*)/')
  local rootdir = hs.fs.currentDir() or '/asdf/asdf/asdf'
  local mods = scan.loaddir(rootdir, 'user.lua')

  local commands = {}
  for file, mod in pairs(mods) do
    if (tables.haspath(mod, 'cmds')) then
      for i, cmd in ipairs(mod.cmds) do
        table.insert(commands, cmd)
      end
    end
  end

  return commands
end

return {
  getCommands = function()
    tables.insert(command_list, table.unpack(scanForCmds()))

    KittySupreme.commands = command_list
    
    return collect:new(command_list)
    -- return Collection:new(command_list)
  end
} 

