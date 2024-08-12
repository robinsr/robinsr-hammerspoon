local inspect = require 'hs.inspect'
local desktop = require 'user.lua.interface.desktop'
local alert   = require 'user.lua.interface.alert'
local func    = require 'user.lua.lib.func'
local lists   = require 'user.lua.lib.list'
local Option  = require 'user.lua.lib.optional'
local paths   = require 'user.lua.lib.path'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local valua   = require 'user.lua.lib.valua'
local types   = require 'user.lua.lib.typecheck'
local Hotkey  = require 'user.lua.model.hotkey'
local colors  = require 'user.lua.ui.color'
local images  = require 'user.lua.ui.image'
local text    = require 'user.lua.ui.text'
local symbols = require 'user.lua.ui.symbols'
local hs      = require 'user.lua.util.hs-objects'
local logr    = require 'user.lua.util.logger'

local log = logr.new('Command', 'info')


---@class ks.command.config
---@field id       string                   - Unique string to identify command
---@field exec     ks.command.execfn        - Callback function for the command, optionally returning an alert string
---@field module?  string                   - (optional) source module of the command
---@field title?   string                   - (optional) title for command
---@field desc?    string                   - (optional) What commmand do?
---@field setup?   ks.command.setupfn       - (optional) setup function, the return value passed to fn
---@field verify?  ks.command.verifyfn[]    - (optional) set of functions to verify if command shoul run
---@field flags?   ks.command.flag[]        - (optional) list of command feature flags
---@field icon?    string|hs.image          - (optional) icon for the command
---@field mods?    ks.keys.modifiers        - (optional) modifier keysfor the hotkey binding
---@field key?     string|ks.keys.keycode   - (optional) key for the hotkey binding
---@field menukey? string|ks.keys.keycode   - (optional) keycode for use in the KS menubar menu
---@field url?     string                   - (optional) hammerspoon url to bind to
---@field events?  string                   - (optional) hammerspoon url to bind to


---@class ks.command.context
---@field trigger        ks.command.trgger   - Source invoking the command
---@field activeApp      hs.application|nil  - Currently active app
---@field activeWindow   hs.window|nil       - Currently active window
---@field activeSpace    integer             - Currently active space ID
---@field activeScreen   hs.screen           - Screen containing the currently focused window


---@alias ks.command.flag
---|'test_flag'    Test purposes
---|'invalid'      Calls the "invalid" handler in command chooser
---|'hidden'       Hides the command from user view
---|'no-chooser'   Hides the command from appearing in the command chooser
---|'no-alert'     Disables the default alert generated when commands hotkey is invoked


---@class ks.command.result
---@field ok? string
---@field err? string


---@alias ks.command.execfn fun(cmd: ks.command, ctx: table|ks.command.context, params: table): string|ks.command.result|nil

---@alias ks.command.setupfn<T> fun(cmd: ks.command): T

---@alias ks.command.verifyfn fun(cmd: ks.command, ctx: ks.command.context, params: table): boolean

---@alias ks.command.trgger 'load'|'hotkey'|'menu'|'url'|'chooser'|'other'


-- Returns the active app, window, space, and screen. Memoized with 1 second cooldown
-- to not spam HS too much for the same data
---@return ks.command.context
local getCurentContext = func.cooldown(1, function() 
  local context = {
    activeApp = desktop.activeApp(),
    activeWindow = desktop.activeWindow(),
    activeSpace = desktop.activeSpace(),
    activeScreen = desktop.getScreen('active'),
  }

  log.logIf('debug', function()
    -- Just curious if it is ever the case that the 'active' screen
    -- is not the same as the active window, for some reason
    local _ids = {
      win = context.activeWindow:screen():id(),
      active = context.activeScreen:id(),
    }

    if _ids.win ~= _ids.active then
      log.w("Active window's screen ID does not match 'active' screen ID!", hs.inspect(_ids))
    end
  end)


  return context
end)



local id_alpha = "[%-%_%w]+"
local id_pattern =  strings.replace('^X%.X%.X$', 'X', id_alpha)

local valid = {
  id = {
    type  = valua:new().type("string"),
    match = valua:new().match(id_pattern)
  }
}


---@class ks.command: ks.command.config
---@field context any
---@field hotkey? ks.hotkey
local Command = {}


--
-- Command class
--
---@param config ks.command.config
---@return ks.command
function Command:new(config)

  ---@class ks.command
  local this = self ~= Command and self or config or {}

  assert(valid.id.type(this.id), ('id missing from %s'):format(hs.inspect(this)))
  assert(valid.id.match(this.id), ('invalid id pattern %q'):format(this.id))


  this.flags = this.flags or {}
  this.hotkey = nil
  this.context = nil

  local contextok, context = pcall(function()
    if types.isFunc(this.setup) then
      return this.setup(this)
    end

    if types.isTable(this.setup) then
      return this.setup
    end

    return {}
  end)

  if contextok then
    this.context = context
  else
    log.trace(context, "command setup error [%s]", this.id)
  end

  if types.notNil(this.key) and types.notNil(this.mods) then
    this.hotkey = Hotkey:new(this.mods, this.key)
  end

  log.vf('Command:new - %s', hs.inspect(this))

  return proto.setProtoOf(this, Command) --[[@as ks.command]]
end


--
-- Runs the command's execute callback
--
---@param trigger ks.command.trgger
---@param params? table
---@return nil
function Command:invoke(trigger, params)
  if types.is_not.func(self.exec) then
    error(('No exec function on command [%s]'):format(self.id or 'none'))
  end

  ---@type ks.command.context
  local ctx = tables.merge({ trigger = trigger }, getCurentContext())

  local verified = lists(self.verify or {}):every(function(verifier)
    return verifier(self, tables.merge(ctx, self.context), params or {})
  end)

  if not verified then
    log.df("Skipping execution of command [%s]", self.id)
    return
  end

  local ok, result = xpcall(function()
    return self.exec(self, tables.merge(ctx, self.context), params or {})
  end, debug.traceback)

  if not ok then
    log.ef("Command [%s] exec error: %q", self.id, result)
    
    return alert:new("Err: %s", strings.truncate(tostring(result), 160))
                :style({ textColor = colors.red })
                :show()
  end

  if types.isNil(result) then
    log.df('Command [%s] exec returned null', self.id)
    return
  end

  if result and result.err ~= nil then
    return alert:new("Err: %s", result.err)
                :style({ textColor = colors.red })
                :show()
  end

  -- Preferably return `hs.command.result`, eg { ok = 'It Worked!' }
  if result and result.ok and types.isString(result.ok) then
    alert:new(result.ok):icon(self:getMenuIcon(16)):show()
    return
  end

  -- Returning a string is (currently) a non-error, eg same as { ok = <string> }
  if types.isString(result) and result ~= '' then
    ---@cast result string
    alert:new(result):icon(self:getMenuIcon(16)):show()
  end

  log.df('Command [%s] exec returned weird: %q', self.id, result)
end


--
-- Returns true if this command has been flagged with `flag`
--
---@param flag ks.command.flag
---@return boolean
function Command:hasFlag(flag)
  return lists(self.flags or {}):includes(flag or 'NO_FLAG')
end


--
-- Returns true if this command has NOT been flagged with `flag`
--
---@param flag ks.command.flag
---@return boolean
function Command:hasntFlag(flag)
  return not self:hasFlag(flag)
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
---@return hs.menu.item
function Command:asMenuItem()
  local title = self.title or self.id

  if self:hasFlag('hidden') or self:getGroup(3):match('onLoad') then
    return { title = '-' }
  end

  local subtext = Option:ofNil(self.hotkey)
    :map(function(hk) return hk:getLabel('keys') --[[@as string]] end)
    :map(function(label) return ('  - (%s)'):format(label) end)
    :orElse('')

  ---@type hs.menu.item
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

  return images.from(self.icon, { w=size, h=size })
end


--
-- Returns descriptive text of the commands hotkey (if present) - keyboard symbols and command title
--
---@deprecated
---@return string
function Command:hotkeyLabel()
  return self.hotkey:getLabel('keys')
end


--
-- Is this command bound to a hotkey?
--
---@return boolean
function Command:hasHotkey()
  return types.notNil(self.hotkey)
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
  if (self.hotkey == nil) then
    return
  end

  self.hotkey:setCallback(func.bind(self.invoke, self, 'hotkey', {}))
  self.hotkey:setDescription(self.title)
  self.hotkey:setAlert(not self:hasFlag('no-alert'))

  local hotkey = self.hotkey:enable()

  if hotkey == nil then
    error(('Could not create hotkey for command [%s]'):format(self.id))
  end

  log.f("Mapped hotkey (%s) to command [%s]", strings.padEnd(self.hotkey:getLabel('keys'), 12), self.id)
end


--
-- Disables the command's hotkey. Optionally will re-enable the hotkey after
-- time specified in `sec`
--
---@param sec? int
function Command:disableHotkey(sec)
  if (self.hotkey == nil) then
    return
  end

  self.hotkey:disable()

  if sec ~= nil then
    func.delay(sec, function()
      self.hotkey:enable()
    end)
  end
end


--
-- Returns a error object for the given error message
--
---@param message string
function Command:fail(message)
  error({ err = ('Command [%s] failed to execute - %s'):format(self.id, message) })
end


return Command