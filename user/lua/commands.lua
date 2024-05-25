local chooser    = require 'hs.chooser'
local collect    = require 'user.lua.lib.collection'
local lists      = require 'user.lua.lib.list'
local scan       = require 'user.lua.lib.scan'
local tables     = require 'user.lua.lib.table'
local types      = require 'user.lua.lib.typecheck'
local Command    = require 'user.lua.model.command'
local ui         = require 'user.lua.ui'
local logr       = require 'user.lua.util.logger'
local delay      = require 'user.lua.util'.delay


local log = logr.new('commands', 'debug')


---@type Command[]
local command_list = {
  {
    id = 'KS.OnLoad',
    exec = function()
      log.i('Running KittySupreme onLoad...')
      KittySupreme.services.sketchybar:setFrontApp('Hammerspoon Loaded!')
    end,
  },
  {
    id = 'KS.ShowHSConsole',
    title = "Show console",
    icon = "code",
    key = "I",
    mods = "bar",
    exec = function()
      hs.openConsole(true)
    end,
  },
  {
    id = 'KS.ReloadConfig',
    title = "Reload KittySupreme",
    icon = "reload",
    key = "W",
    mods = "bar",
    exec = function()
      delay(0.75, hs.reload)
    end,
  },
  {
    id = 'KS.RestartHS',
    title = "Reload Hammerspoon",
    icon = "reload",
    key = "X",
    mods = "bar",
    exec = function()
      delay(0.75, hs.relaunch)
    end,
  },
  {
    id = 'KS.TestWebviewText',
    title = "Test Webview Alert",
    key = "F",
    mods = "bar",
    exec = function()
      log.i('Testing HS Webview...')
      require('user.lua.ui.webview').test()
    end,
  },
  {
    id = 'KS.ChooseCommand',
    title = "Show command chooser",
    mods = "bar",
    key = "c",
    setup = function(cmd)

      local onCmdChosen = function(cmd)
        log.f('Chose command : %s', hs.inspect(cmd))
      end

      local cmdChooser = chooser.new(onCmdChosen)

      cmdChooser:choices(function()
        return lists(KittySupreme.commands):map(function(cmd)
          return {
            text = cmd.title or cmd.id,
            subText = cmd.id,
            command = cmd.id,
          }
        end)
      end)

      cmdChooser:searchSubText(true)

      return { chooser = cmdChooser }
    end,
    exec = function(cmd, ctx, params)
      ctx.chooser:refreshChoicesCallback()
      ctx.chooser:show()
    end
  }
}


local function scanForCmds()
  -- Stepping back 3 steps on the call stack to get calling module's filepath
  -- local modInfo = debug.getinfo(3, 'S')
  -- local rootdir = string.match(modInfo.source, '^@(.*)/')
  local rootdir = hs.fs.currentDir() or '/asdf/asdf/asdf'
  local mods = scan.loaddir(rootdir, 'user.lua')

  local commands = {}
  for file, mod in pairs(mods) do
    if (types.isTable(mod) and tables.has(mod, 'cmds')) then
      for i, cmd in ipairs(mod.cmds) do
        table.insert(commands, cmd)
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