local fn      = require 'user.lua.lib.func'
local lists   = require 'user.lua.lib.list'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local valua   = require 'user.lua.lib.valua'
local keys    = require 'user.lua.model.keys'
local json    = require 'user.lua.util.json'
local logr    = require 'user.lua.util.logger'

local log = logr.new('HotKey', 'info')


---@class ks.hotkey
---@field key         ks.keys.keycode     The non-modifier key to bind to
---@field mods        ks.keys.modkey[]    List of modifier keys to bind to
---@field keyevents   ks.keys.keyevent[]  List of keyevents to bind to
---@field handlerfn   ks.keys.callback    The callback function when the hotkey fires
---@field showAlert   boolean             A boolean, when true will use the default Hammerspoon alert
---@field description string              A string description of what the keycode does
---@field symbols     string[]            A list of symbols (display characters), signifying the modifier keys
---@field listener    hs.hotkey|nil       The actual hammerspoon key binding


---@alias ks.hotkey.disp_fmt
---|'mods'    Modifier symbols only
---|'keys'    Modifier symbols and keycode (all keys involved)
---|'full'    Modifier symbols, keycode, and description


---@class ks.hotkey
local Hotkey = {}



--
-- Returns a Hotkey configuration
--
---@param mods ks.keys.modifiers   The shortcut's modifier keys
---@param key  ks.keys.keycode     The shortcuts non-modifier key
---@return ks.hotkey
function Hotkey:new(mods, key)

  ---@class ks.hotkey
  local this = {
    key = key,
    keyevents = { "pressed" },
    mods = {},
    showAlert = false,
    description = '',
    symbols = {},
    handler = fn.noop,
    listener = nil,
  }


  if types.isString(mods) then
    ---@cast mods ks.keys.modcombo
    if keys.presets:has(mods) then
      this.mods = keys.presets:get(mods) --[[@as ks.keys.modkey[] ]]
    else
      error(('Unrecognized mod combo "%s"'):format(mods))
    end
  elseif types.isTable(mods) then
    ---@cast mods ks.keys.modkey[]
    this.mods = mods
  else
    error('mods is neither a list of mod keynames or a preset combo')
  end

  this.symbols = lists(this.mods):map(keys.getSymbol):values()

  return setmetatable(this, { __index = Hotkey }) --[[@as ks.hotkey]]
end


--
-- Sets which key events this hotkey should fire on (press, release, repeat)
--
---@param evts ks.keys.keyevent[]
function Hotkey:setKeyEvents(evts)
  self.keyevents = evts
  return self
end


--
-- Sets the handler callback function
--
---@param fn ks.keys.callback
function Hotkey:setCallback(fn)
  self.handlerfn = fn
  return self
end


--
-- Sets whether the hotkey will automatically show an alert message on events
--
---@param val boolean
function Hotkey:setAlert(val)
  self.showAlert = val
  return self
end


--
-- Reformats the label (message) with a text description
--
---@param desc string
function Hotkey:setDescription(desc)
  self.description = desc
  return self
end


--
-- Returns a string combining the hotkey's modifier symbols, keycode, and description
--
---@param format? ks.hotkey.disp_fmt
---@return string
function Hotkey:getLabel(format)
  format = format or 'keys'

  local symbols = lists(self.symbols):join('')
  local key = self.key
  local desc = self.description

  if format == 'mods' then
    return symbols
  end

  if format == 'keys' then
    return symbols..self.key
  end

  return ('%s %s: %s'):format(symbols, self.key, self.description)
end


--
-- Creates and enables the hotkey with hammerspoon
--
function Hotkey:enable()
  if self.listener == nil then
    local self_events = lists(self.keyevents)
    local triggers = lists(keys.events):map(function(evt)
      return self_events:includes(evt) and self.handlerfn or fn.noop
    end)

    local message = self.showAlert and self.description or nil

    self.listener = hs.hotkey.new(self.mods, self.key, message, triggers:unpack())
  end

  self.listener:enable()

  return self.listener
end


--
-- Disables the hotkey
--
function Hotkey:disable()
  if self.listener ~= nil then
    self.listener:disable()
  end
end



---@return table
function Hotkey:__toplain()
  return tables.toplain(self, {})
end


---@return string
function Hotkey:__tojson()
  return json.tostring(self:__toplain())
end


return Hotkey