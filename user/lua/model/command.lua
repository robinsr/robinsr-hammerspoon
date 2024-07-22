local plfunc  = require 'pl.func' 
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


---@class CommandConfig
---@field id string             - Unique string to identify command
---@field exec CmdExecFn           - A callback function for the command, optionally returning an alert string
---@field module? string        - source module of the command
---@field setup? CmdSetupFn        - (optional) A setup function, the return value passed to fn
---@field title? string         - (optional) A title for command
---@field desc? string          - (optional) What commmand do?
---@field flags? CmdFeature[]   - (optional) List of command feature flags
---@field icon? hs.image|string - (optional) A icon for the command
---@field key? string           - (optional) A key for the hotkey binding
---@field menukey? string       - (optional) A shortcut key for use in the KS menubar menu
---@field mods? string          - (optional) A mods group for the hotkey binding
---@field url? string           - (optional) A hammerspoon url to bind to


---@alias CmdFeature 'invalid_choice' | 'test_flag'


---@class NextAction
---@field message? string

---@alias CmdExecFn<T> fun(cmd: Command, ctx: T, params: table): string|nil

---@alias CmdSetupFn<T> fun(cmd: Command): T

---@class CommandCtx
---@field trigger 'hotkey'|'menubar' Source invoking the command



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


---@class Command : CommandConfig
---@field context any
---@field hotkey? Hotkey
local Command = {}


--
-- Command class
--
---@param config CommandConfig
---@return Command
function Command:new(config)

  ---@class Command
  local this = config or {}

  validate(valid.id.type(this.id), 'id missing from %q', hs.inspect(this))
  validate(valid.id.match(this.id), 'invalid id pattern %q', this.id)

  this.flags = this.flags or {}

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

  this.hotkey = nil

  if types.isString(this.key) and types.isString(this.mods) then
    this.hotkey = Hotkey.new(this.mods, this.key)
  end

  return proto.setProtoOf(this, Command) --[[@as Command]]
end


--
-- Runs the command's execute callback
--
---@param from 'hotkey'|'menu'|'url'|'chooser'|'other'
---@param params? table
---@return nil
function Command:invoke(from, params)
  if types.is_not.func(self.exec) then
    error(('No exec function on command [%s]'):format(self.id or 'none'))
  end

  ---@type CommandCtx
  local ctx = tables.merge({}, self.context, { trigger = from })

  local ok, post_msg = xpcall(function()
    return self.exec(self, ctx, params or {}) --[[@as string]]
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
  local subtext = self.hotkey and self.hotkey:label() or ''

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
---@return string
function Command:hotkeyLabel()
  local prefix = self.hotkey and self.hotkey:label() or ''
  
  return strings.join({ prefix, ': ', self.title })
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
    local label = self.hotkey:label()
    local triggers = self.hotkey:getEventHandlers(plfunc.bind(self.invoke, self, 'hotkey', {}))
    -- todo, how to configure this
    local show_message = false
    local message = show_message and self.title or nil
    local bind = hs.hotkey.bind(self.hotkey.mods, self.hotkey.key, message, table.unpack(triggers))

    log.f("Command (%s) mapped to hotkey: %s", strings.padEnd(self.id, 20), label)
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