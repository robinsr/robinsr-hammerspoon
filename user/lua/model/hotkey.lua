local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local logr    = require 'user.lua.util.logger'

local log = logr.new('HotKey', 'info')


---@alias ModKeyCombo "hyper" | "meh" | "bar" | "modA" | "modB" | "shift" | "alt" | "ctrl" | "cmd"

---@alias ModKeyname "shift" | "alt" | "ctrl" | "cmd"

---@type Record<ModKeyCombo, ModKeyname[]>
local MODS = {
  hyper = { "shift", "alt", "ctrl", "cmd" },
  meh   = { "shift",        "ctrl", "cmd" },
  bar   = {          "alt", "ctrl", "cmd" },
  modA  = { "shift", "alt"                },
  modB  = { "shift", "alt", "ctrl"        },
  shift = { "shift"                       },
  alt   = {          "alt"                },
  ctrl  = {                 "ctrl"        },
  cmd   = {                         "cmd" },
}


---@return boolean
local function modAllowed(name)
  return tables.has(MODS, name)
end

local MODS_KEYS = tables.keys(MODS, true)


---@class Hotkey
local Hotkey = {}

--
-- Returns a Hotkey configuration
--
---@params mods ModKeyCombo
---@params key string
---@params message? string Alert message to show. Passing an empty string will just show keys, "title" will copy command title as message, nil will disable message
---@params on? ("pressed" | "released" | "repeat")[]
---@return Hotkey
function Hotkey:new(mods, key, message, on)
  if not modAllowed(mods) then
    log.ef("Hotkey mods '%s' not allowed", mods)
  end

  local o = {}
  
  self.mods = MODS[mods]
  self.key = key
  self.message = message
  self.on = params.default(on, { "pressed" })

  setmetatable(o, self)

  return o
end


function Hotkey:getMods()
  if modAllowed(self.mods) then
    
  end

  error('')
end

HotkeyMaker = setmetatable(Hotkey, {

  __call = function(self, a,b,c,d)
    return Hotkey:new(a,b,c,d)
  end
})


local testhk = Hotkey('bar', 'B', 'Boogey Wonderland', { 'pressed' })





return Hotkey