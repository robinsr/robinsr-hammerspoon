local plfunc  = require 'pl.func' 
local desktop = require 'user.lua.interface.desktop'
local alert   = require 'user.lua.interface.alert'
local lists   = require 'user.lua.lib.list'
local paths   = require 'user.lua.lib.path'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local valua   = require 'user.lua.lib.valua'
local types   = require 'user.lua.lib.typecheck'
local Hotkey  = require 'user.lua.model.hotkey'
local image   = require 'user.lua.ui.image'
local text    = require 'user.lua.ui.text'
local symbols = require 'user.lua.ui.symbols'
local logr    = require 'user.lua.util.logger'

local log = logr.new('Command', 'info')


---@class ks.command.config
---@field id       string              - Unique string to identify command
---@field module?  string              - (optional) source module of the command
---@field title?   string              - (optional) A title for command
---@field desc?    string              - (optional) What commmand do?
---@field exec     ks.command.execfn   - A callback function for the command, optionally returning an alert string
---@field setup?   ks.command.setupfn  - (optional) A setup function, the return value passed to fn
---@field flags?   ks.command.flag[]   - (optional) List of command feature flags
---@field icon?    string|hs.image     - (optional) A icon for the command
---@field mods?    ks.keys.modifiers   - (optional) A mods group for the hotkey binding
---@field key?     ks.keys.keycode     - (optional) A key for the hotkey binding
---@field menukey? ks.keys.keycode     - (optional) A shortcut key for use in the KS menubar menu
---@field url?     string              - (optional) A hammerspoon url to bind to


---@class ks.command.context
---@field trigger        ks.command.trgger   - Source invoking the command
---@field activeApp      hs.application|nil  - Currently active app
---@field activeWindow   hs.window|nil       - Currently active window ID


---@alias ks.command.flag 'invalid_choice' | 'test_flag' | 'no-chooser'


---@alias ks.command.execfn fun(cmd: Command, ctx: ks.command.context, params: table): string|nil


---@alias ks.command.setupfn<T> fun(cmd: Command): T


---@alias ks.command.trgger 'hotkey'|'menu'|'url'|'chooser'|'other'



local validate = function(v, msg, ...)
  if not v then
    assert(v, strings.fmt(msg, table.unpack({...})))
  end
end

local id_alpha = "[%-%_%w]+"
local id_pattern =  strings.replace('^X%.X%.X$', 'X', id_alpha)

local valid = {
  id = {
    type  = valua:new().type("string"),
    match = valua:new().match(id_pattern)
  }
}


---@class Command : ks.command.config
---@field context any
---@field hotkey? ks.keys.hotkey
local Command = {}


--
-- Command class
--
---@param config ks.command.config
---@return Command
function Command:new(config)

  ---@class Command
  local this = config or {}

  validate(valid.id.type(this.id), 'id missing from %q', hs.inspect(this))
  validate(valid.id.match(this.id), 'invalid id pattern %q', this.id)

  this.flags = this.flags or {}
  this.hotkey = nil
  this.context = nil

  local contextok, context = pcall(function()
    if types.isFunc(config.setup) then
      return config.setup(config)
    end

    if types.isTable(config.setup) then
      return config.setup
    end

    return {}
  end)

  if contextok then
    this.context = context
  else
    log.trace(context, "command setup error [%s]", config.id)
  end

  if types.notNil(this.key) and types.isString(this.mods) then
    this.hotkey = Hotkey:new(this.mods, this.key)
  end

  return proto.setProtoOf(this, Command) --[[@as Command]]
end


--
-- Runs the command's execute callback
--
---@param from ks.command.trgger
---@param params? table
---@return nil
function Command:invoke(from, params)
  if types.is_not.func(self.exec) then
    error(('No exec function on command [%s]'):format(self.id or 'none'))
  end

  ---@type ks.command.context
  local ctx = { 
    trigger = from,
    activeApp = desktop.activeApp(),
    activeWindow = desktop.activeWindow(),
  }

  local ok, post_msg = xpcall(function()
    return self.exec(self, tables.merge(ctx, self.context), params or {}) --[[@as string]]
  end, debug.traceback)

  if not ok then
    log.ef("command invoke error [%s]\n%s", self.id, post_msg)
    return
  end

  if types.isNil(post_msg) then
    return
  end

  -- todo: command callback alert logic moved up somewhere
  if (post_msg == 'default') then
    alert:fmt('%s: %s', self.hotkey:label(), self.title):show()
    return
  end

  if (post_msg ~= '') then
    alert:new(post_msg):show()
  end
end


--
---@param flag string
---@return boolean
function Command:has_flag(flag)
  return lists(self.flags or {}):includes(flag or 'NO_FLAG')
end


--
-- Returns the first or second partial of the command ID string
-- Example command if "foo.bar.baz" 
--    - cmd:getGroup(1) -> "foo"
--    - cmd:getGroup(2) -> "bar"
--    - cmd:getGroup(3) -> "baz"
---@param num integer
---@return string
function Command:getGroup(num)
  local matchers = {
    [1] = '^(X)%.X%.X$',
    [2] = '^X%.(X)%.X$',
    [3] = '^X%.X%.(X)$',
  }

  if matchers[num] == nil then
    num = 1
  end

  return self.id:match(strings.replace(matchers[num], 'X', id_alpha))
end


--
-- Returns a table that can be used in Hammerspoon menus
--
---@return HS.MenubarItem
function Command:as_menu_item()
  local title = self.title or self.id
  local subtext = self.hotkey and self.hotkey.symbols or ''

  ---@type HS.MenubarItem
  local menuitem = {
    title = text.textAndHint(title, subtext),
    shortcut = self.menukey,
    image = self:getMenuIcon(12) or nil,
    fn = function()
      self:invoke('menu', {})
    end
  }
  
  return menuitem
end


--
-- Returns an icon for this command as a hs.image object
--
---@param size? integer Size of icon, defaults to 12
---@return hs.image
function Command:getMenuIcon(size)
  size = size or 12
  
  log.df("icon type %s for command %s", type(self.icon), self.id)

  local icon = self.icon or 'info'

  if types.isNil(self.icon) then
    return image.from_icon('info', size)
  end

  if type(self.icon) == "string" then
    local icon = self.icon --[[@as string]]
      
    if symbols.has_codepoint(icon) then
      return image.from_icon(icon, size)
    end

    if paths.exists(icon) then
      return image.from_path(icon, size, size)
    end

    return image.from_icon('info', size)
  end

  -- local ok, img = pcall(function()
  --   ---@diagnostic disable-next-line: param-type-mismatch
  --   return image.from_icon(icon, size)
  -- end)

  -- return ok and img or image.from_icon('info', size) --[[@as hs.image]]

  return self.icon --[[@as hs.image]]
end


--
-- Returns descriptive text of the commands hotkey (if present) - keyboard symbols and command title
--
---@deprecated
---@return string
function Command:hotkeyLabel()
  return self.hotkey.label
end


--
-- Is this command bound to a hotkey?
--
---@return boolean
function Command:hasHotkey()
  return types.isString(self.key) and types.isString(self.mods)
end


--
-- Binds the command to a hs:// URL
--
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

  if (self.hotkey ~= nil) then
    self.hotkey:setCallback(plfunc.bind(self.invoke, self, 'hotkey', {}))
    self.hotkey:setDescription(self.title)

    local hotkey = self.hotkey:enable()

    if hotkey == nil then
      error(('Could not create hotkey for command [%s]'):format(self.id))
    end

    log.f("Command (%s) mapped to hotkey: %s", strings.padEnd(self.id, 20), self.hotkey.label)
  end
end



--
-- Returns the command as a data-table row 
-- 
-- See: https://stevedonovan.github.io/Penlight/api/libraries/pl.data.html
--
---@return table
function Command:asdatarow()
  return { self.id, self.title, self.flags, self.hotkey and self.hotkey.mods, self.hotkey and self.hotkey.key, self.url }
end

return Command