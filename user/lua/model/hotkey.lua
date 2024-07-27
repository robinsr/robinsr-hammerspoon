local lists   = require 'user.lua.lib.list'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local valua   = require 'user.lua.lib.valua'
local icons   = require 'user.lua.ui.icons'
local json    = require 'user.lua.util.json'
local logr    = require 'user.lua.util.logger'

local log = logr.new('HotKey', 'info')


---@type ks.keys.keyevent[]
local KEY_EVENTS = { 'pressed', 'released', 'repeat' } 


local noop = function()
  -- do nothing
end


--
-- Returns the symbol character that corresponds to a key name
--
---@param key string
---@return string
local function get_key_symbol(key)
  return icons.keys:has(key) and icons.keys:get(key) or icons.replace
end


---@class ks.keys.presets
---@field [ks.keys.modcombo] ks.keys.modkey[]

---@type Table|ks.keys.presets
local combo_presets = tables{
  hyper  = { "ctrl", "alt", "shift", "cmd" }, -- all the keys!
  meh    = { "ctrl", "alt", "shift"        }, -- its just whatev
  peace  = { "ctrl", "alt", "shift"        }, -- "the peace sign" (same as "meh", just easier to remember)
  claw   = { "ctrl",        "shift", "cmd" }, -- THE CLAW! (same as fake-meh)
  btms   = { "ctrl", "alt",          "cmd" }, -- bottoms
  lil    = { "ctrl", "alt"                 }, -- just a "lil" thing

  -- Individual keys
  cmd    = {                         "cmd" },
  shift  = {                "shift"        },
  alt    = {         "alt"                 },
  ctrl   = { "ctrl"                        },

  -- Command+ combos
  ctcmd  = { "ctrl",                 "cmd" },
  altcmd = {         "alt",          "cmd" },
  scmd   = {                "shift", "cmd" },

  -- Others
  option_shift = { "alt", "shift" },
}



---@class ks.keys.hotkey
---@field key string
---@field mods ks.keys.modkey[]
---@field keyevents ks.keys.keyevent[]
---@field handlerfn ks.keys.callback
---@field showAlert boolean
---@field label string
---@field symbols string[]
---@field listener hs.hotkey|nil


---@class ks.keys.hotkey
local Hotkey = {}


--
-- Returns a Hotkey configuration
--
---@param mods ks.keys.modifiers The shortcut's modifier keys
---@param key ks.keys.keycode The shortcuts non-modifier key
---@return ks.keys.hotkey
function Hotkey:new(mods, key)

  ---@class ks.keys.hotkey
  local this = {
    key = key,
    keyevents = { "pressed" },
    mods = {},
    showAlert = false,
    label = '',
    symbols = {},
    handler = noop,
    listener = nil,
  }


  if types.isString(mods) then
    ---@cast mods ks.keys.modcombo
    if combo_presets:has(mods) then
      this.mods = combo_presets:get(mods) --[[@as ks.keys.modkey[] ]]
    else
      error(('Unrecognized mod combo "%s"'):format(mods))
    end
  elseif types.isTable(mods) then
    ---@cast mods ks.keys.modkey[]
    this.mods = mods
  else
    error('mods is neither a list of mod keynames or a preset combo')
  end

  local key_symbols = lists(this.mods):map(get_key_symbol)

  this.symbols = key_symbols:values()


  return setmetatable(this, { __index = Hotkey }) --[[@as ks.keys.hotkey]]
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
  self.label = ('%s: %s'):format(lists(self.mods):map(get_key_symbol):join(' '), desc)
  return self
end


--
-- Creates and enables the hotkey with hammerspoon
--
function Hotkey:enable()
  if self.listener == nil then
    local self_events = lists(self.keyevents)
    local triggers = lists(KEY_EVENTS):map(function(evt)
      return self_events:includes(evt) and self.handlerfn or noop
    end)

    local message = self.showAlert and self.label or nil

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
  -- return tables.toplain(self, { 'symbols', 'label' })
  return tables.toplain(self, {})
end


---@return string
function Hotkey:__tojson()
  return json.tostring(self:__toplain())
end


-- return setmetatable({}, { __index = Hotkey }) --[[@as ks.keys.hotkey]]
return Hotkey