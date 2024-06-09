local alert   = require 'user.lua.interface.alert'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local valua   = require 'user.lua.lib.valua'
local types   = require 'user.lua.lib.typecheck'
local Hotkey  = require 'user.lua.model.hotkey'
local icons   = require 'user.lua.ui.icons'
local logr    = require 'user.lua.util.logger'

local log = logr.new('Command', 'info')


---@class CommandConfig<T>
---@field id string             - Unique string to identify command
---@field exec ExecFn           - A callback function for the command, optionally returning an alert string
---@field setup? SetupFn        - (optional) A setup function, the return value passed to fn
---@field title? string         - (optional) A title for command
---@field icon? hs.image|string - (optional) A icon for the command
---@field key? string           - (optional) A key for the hotkey binding
---@field menukey? string       - (optional) A shortcut key for use in the KS menubar menu
---@field mods? string          - (optional) A mods group for the hotkey binding
---@field url? string           - (optional) A hammerspoon url to bind to

---@alias ExecFn<T> fun(cmd: Command, ctx: T, params: table): string|nil

---@alias SetupFn<T> fun(cmd: Command): T

---@class CommandCtx
---@field trigger 'hotkey'|'menubar' Source invoking the command



local validate = function(v, msg, ...)
  if not v then
    assert(v, strings.fmt(msg, table.unpack({...})))
  end
end


local valid = {
  id = {
    type  = valua:new().type("string"),
    match = valua:new().match("^%w+%.%w+%.%w+$")
  }
}


---@class Command : CommandConfig
---@field context any
---@field hotkey? hs.hotkey
local Command = {}


---@param config CommandConfig
---@return Command
function Command:new(config)

  ---@class Command
  local this = config or {}

  validate(valid.id.type(this.id), 'id missing from %q', hs.inspect(this))
  validate(valid.id.match(this.id), 'invalid id pattern %q', this.id)

  this.context = config.setup and config.setup(config) or {}

  return proto.setProtoOf(this, Command) --[[@as Command]]
end


function Command:getMenuSection()
  return strings.split(self.id, ".")[1]
end


--
-- Returns an icon for this command as a hs.image object
--
---@return hs.image
function Command:getMenuIcon()
  local icon = self.icon or 'info'

  local ok, img = pcall(function()
    ---@diagnostic disable-next-line: param-type-mismatch
    return icons.menuIcon(icon)
  end)

  return ok and img or icons.menuIcon('info') --[[@as hs.image]]
end


--
--
--
function Command:hasHotkey()
  return types.isString(self.key) and types.isString(self.mods)
end


--
--
--
function Command:getHotkey()
  return Hotkey.new(self.mods, self.key)
end


--
-- Runs the command's exec callback
--
---@param from 'hotkey'|'menu'|'url'|'chooser'|'other'
---@param params? table
---@return nil
function Command:invoke(from, params)
  ---@type CommandCtx
  local ctx = tables.merge({}, self.context, { trigger = from })

  local ok, msg = pcall(function()
    if types.is_not.func(self.exec) then
      error(strings.fmt('No exec function on command "%s"', self.id))
    end

    return self.exec(self, ctx, params or {})
  end)

  if not ok then
    log.ef('Error while executing command "%s" - %s', self.id, msg)
    error(msg)
  end

  -- todo: command callback alert logic moved up somewhere
  if types.is_not.empty(msg) then
    alert:new(msg):show()
  end
end


function Command:bindURL()
  if (self.url == nil) then return end

  hs.urlevent.bind(self.url, function(name, params)
    self:invoke('url', params)
  end)
end


--
-- Binds the command hotkey
--
function Command:bindHotkey()
  local cmd = self

  if (not self:hasHotkey()) then
    return
  end

  local hotkey = self:getHotkey()
  local label = hotkey:label()

  local triggers = hotkey:getEventHandlers(function()
    self:invoke('hotkey', {})
  end)

  local bind = hs.hotkey.bind(hotkey.mods, hotkey.key, cmd.title, table.unpack(triggers))

  log.f("Command (%s) mapped to hotkey: %s", strings.padEnd(cmd.id, 20), label)

end

return Command