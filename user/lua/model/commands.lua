local Command = require 'user.lua.model.command'
local lists   = require 'user.lua.lib.list'
local fs      = require 'user.lua.lib.fs'
local func    = require 'user.lua.lib.func'
local paths   = require 'user.lua.lib.path'
local proto   = require 'user.lua.lib.proto'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local logr    = require 'user.lua.util.logger'

local log = logr.new('CommandList', 'info')



local EVT_FILTER = '!*.(evt|event|events).*'


---@class ks.commandlist : List
local CommandList = proto.setProtoOf({}, lists)


--
--
--
---@param commands? ks.command.config[] Optional default set of commands
---@return          ks.commandlist
function CommandList:new(commands)
  ---@class ks.commandlist
  local this = {
    items = commands or {}
  }

  return proto.setProtoOf(this, CommandList)
end


---@param id string  - ID of a command
---@return ks.command|nil
function CommandList:find(id)
  return lists(self.items or {}):first(function(cmd) return cmd.id == id end)
end


--
-- 
--
---@return { [string]: ks.command[] }
function CommandList:getHotkeyGroups()
  ---@type boolfn<ks.command>
  local notHidden = function(cmd) return cmd:hasntFlag('hidden') end

  ---@type boolfn<ks.command>
  local hasHotkey = function(cmd) return cmd:hasHotkey() end

  ---@type ClassifierFn<ks.command, string>
  local getCmdGroup = function(cmd, i)
    local key = (cmd.module or '')
      :gsub('user%.lua%.', '')
      :gsub('modules%.', '')
      :gsub('%.', ' → ')

      return not types.isEmpty(key) and key or 'Init'
  end
      
  return self:filter(notHidden):filter(hasHotkey):groupBy(getCmdGroup)
end


--
--
--
---@return ks.command.config[]
function CommandList:scanForConfigs()
  local commands = {}
  local rootdir = paths.cwd()
  local userpath = lists({ 'user', 'lua' })

  log.f("Scanning for command configurations in [%s/%s]", rootdir, userpath:join('/'))

  local mods = fs.loaddir(rootdir, userpath:join('.'))

  for module, exports in tables.entries(mods) do
    if (types.isTable(exports) and tables.has(exports, 'cmds')) then
      -- Support setting command's `module` prop value at the module level
      -- (can also be set on the commands individually)
      local modname = exports.module or module
      
      for i, cmd in ipairs(exports.cmds) do
        table.insert(commands, tables.merge({ module = modname }, cmd))
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
  self.items = lists(self:scanForConfigs())
    :map(Command.new)
    :values()

  return self
end



return setmetatable({}, { __index = CommandList }) --[[@as ks.commandlist]]