local console = require 'user.lua.interface.console'
local desk    = require 'user.lua.interface.desktop'
local Command = require 'user.lua.model.command'
local lists   = require 'user.lua.lib.list'
local fs      = require 'user.lua.lib.fs'
local funcs   = require 'user.lua.lib.func'
local paths   = require 'user.lua.lib.path'
local proto   = require 'user.lua.lib.proto'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local rdir    = require 'user.lua.ui.resource-dir'
local logr    = require 'user.lua.util.logger'


local log = logr.new('CommandList', 'info')


---@type ks.command[]
local command_list = {
  {
    id = 'ks.evt.onLoad',
    exec = function()
      log.i('Running KittySupreme onLoad...')

      local image_watcher = rdir:new(paths.expand('@/resources/images/')):watch()

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
      hs.toggleConsole()
      -- hs.openConsole(true)
    end,
  },
  {
    id = 'ks.commands.toggle_darkmode',
    title = "Toggle dark mode",
    icon = "@/resources/images/ios-day-and-night.template.png",
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
      funcs.delay(0.75, hs.reload)
      return cmd.hotkey.label
    end,
  },
  {
    id = 'ks.commands.restartHS',
    title = "Relaunch Hammerspoon",
    icon = "reload",
    key = "X",
    mods = "btms",
    exec = function(cmd)
      funcs.delay(0.75, hs.relaunch)
      return cmd.hotkey.label
    end,
  }
}

local EVT_FILTER = '!*.(evt|event|events).*'


---@class ks.commandlist : List
local CommandList = proto.setProtoOf({}, lists)



--
--
--
---@return ks.commandlist
function CommandList:new()
  ---@class ks.commandlist
  local this = {
    items = {}
  }

  return proto.setProtoOf({}, CommandList)
end


--
--
--
---@return ks.command.config[]
function CommandList:scanForConfigs()
  local commands = {}
  local rootdir = paths.cwd()
  local userpath = lists({ 'user', 'lua' })

  log.f("Scanning for command configurations in [%s/*s]", rootdir, userpath:join('/'))

  local mods = fs.loaddir(rootdir, userpath:join('.'))

  for module, exports in pairs(mods) do
    
    if (types.isTable(exports) and tables.has(exports, 'cmds')) then

      -- Support setting command's `module` prop value at the module level
      -- (can also be set on the commands individually)
      local modname = tables.has(exports, 'module') or module
      
      for i, cmd in ipairs(exports.cmds) do
        table.insert(commands, tables.merge({ module = module }, cmd))
      end
    end
  end

  return commands
end


--
--
--
---@return self
function CommandList:initialize()
  local commands = lists(command_list)
    :concat(self:scanForConfigs())
    :map(function(cmd) return Command:new(cmd) end)

  self.items = commands:values()

  return self
end


return setmetatable({}, { __index = CommandList }) --[[@as ks.commandlist]]