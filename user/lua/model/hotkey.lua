local lists   = require 'user.lua.lib.list'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local logr    = require 'user.lua.util.logger'

local log = logr.new('HotKey', 'info')


---@alias ModKeyCombo "hyper" | "meh" | "bar" | "modA" | "modB" | "shift" | "alt" | "ctrl" | "cmd"

---@alias ModKeyname "shift" | "alt" | "ctrl" | "cmd"

---@alias KeyEventType "pressed" | "released" | "repeat"

---@alias EventHandler fun(): any

---@type Table
local STD_MODS = tables{
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

local SYMBOLS = tables{
  cmd   = "⌘",
  ctrl  = "⌃",
  alt   = "⌥",
  shift = "⇧",
}


---@class Hotkey
---@field key string
---@field mods ModKeyname[]
---@field keyevents KeyEventType[]
local Hotkey = {}


--
-- Returns a Hotkey configuration
--
---@param mods ModKeyCombo|ModKeyname[] The shortcut's modifier keys
---@param key string The shortcuts non-modifier key
---@param keyevents? KeyEventType[]
---@return Hotkey
function Hotkey:new(mods, key, keyevents)

  ---@type Hotkey
  local hotkey = {
    key = key,
    keyevents = keyevents or { "pressed" },
    mods = {},
  }


  if types.isString(mods) then
    ---@cast mods string
    if STD_MODS:has(mods) then
      hotkey.mods = STD_MODS:get(mods) --[[ @as ModKeyname[] ]]
    else
      error('Unrecognized modifiers: '..mods)
    end
  end

  if (types.isTable(mods)) then
    ---@cast mods ModKeyname[]
    hotkey.mods = mods
  end

  return proto.setProtoOf(hotkey, Hotkey) --[[ @as Hotkey ]]
end


---@return string[]
function Hotkey:symbols()
  return lists.map(self.mods, function(m) return SYMBOLS[m] end)
end


---@return string
function Hotkey:label()
  return lists(self:symbols()):push(self.key):join(' ')
end

---@return table
function Hotkey:toTable()
  return {
    key = self.key,
    mods = self.mods,
    symbols = self:symbols(),
    label = self:label(),
  }
end


--
--
--
---@param fn EventHandler
---@return { [0]: EventHandler, [0]:  EventHandler, [0]: EventHandler}
function Hotkey:getEventHandlers(fn)
  local evts = { 'pressed', 'released', 'repeat' } 
  
  local noop = function()
    -- do nothing
  end
  
  return lists(evts):map(function(evt)
    return lists(self.keyevents):includes(evt) and fn or noop
  end)
end


return {
  new = function(...) return Hotkey:new(...) end,
  MODS = STD_MODS,
}