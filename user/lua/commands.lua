local chooser    = require 'hs.chooser'
local collect    = require 'user.lua.lib.collection'
local lists      = require 'user.lua.lib.list'
local scan       = require 'user.lua.lib.scan'
local strings    = require 'user.lua.lib.string'
local tables     = require 'user.lua.lib.table'
local types      = require 'user.lua.lib.typecheck'
local Command    = require 'user.lua.model.command'
local logr       = require 'user.lua.util.logger'
local delay      = require 'user.lua.util'.delay


local log = logr.new('commands', 'debug')

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
    mods = "bar",
    exec = function()
      hs.openConsole(true)
    end,
  },
  {
    id = 'ks.commands.reloadConfig',
    title = "Reload Config",
    icon = "reload",
    key = "W",
    mods = "bar",
    exec = function()
      delay(0.75, hs.reload)
    end,
  },
  {
    id = 'ks.commands.restartHS',
    title = "Relaunch Hammerspoon",
    icon = "reload",
    key = "X",
    mods = "bar",
    exec = function()
      delay(0.75, hs.relaunch)
    end,
  },
  {
    id = 'ks.commands.chooseCommand',
    title = "Show command chooser",
    mods = "bar",
    key = "c",
    setup = function(cmd)

      local onCmdChosen = function(choice)
        local cmd = KittySupreme.commands:first(function(cmd) return cmd.id == choice.id end)

        if types.notNil(cmd) then
          ---@cast cmd Command
          cmd:invoke('chooser', {})
        end

      end

      local cmdChooser = chooser.new(onCmdChosen)
        
      local not_events_glob = strings.glob(EVT_FILTER)

      cmdChooser:choices(function()
        return lists(KittySupreme.commands)
          :filter(function(cmd) return not_events_glob(cmd.id) end)
          :map(function(cmd)
            return {
              text = cmd.title or cmd.id,
              subText = cmd.id,
              id = cmd.id,
            }
          end)
          :values()
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