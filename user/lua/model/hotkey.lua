local lists   = require 'user.lua.lib.list'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local icons   = require 'user.lua.ui.icons'
local logr    = require 'user.lua.util.logger'

local log = logr.new('HotKey', 'info')


---@alias ModKeyCombo "hyper" | "meh" | "bar" | "modA" | "modB" | "shift" | "alt" | "ctrl" | "cmd"
---@alias ModKeyname "shift" | "alt" | "ctrl" | "cmd"
---@alias KeyEventType "pressed" | "released" | "repeat"
---@alias EventHandler fun(): any

---@type Table
local preset_mods = tables{
  hyper = { "cmd", "ctrl", "alt", "shift" },
  meh   = { "cmd", "ctrl",        "shift" },
  ctcmd = { "cmd", "ctrl",                },
  bar   = { "cmd", "ctrl", "alt"          },
  modA  = {        "ctrl", "alt"          },
  modB  = {        "ctrl", "alt", "shift" },
  shift = {                       "shift" },
  alt   = {                "alt"          },
  ctrl  = {        "ctrl"                 },
  cmd   = { "cmd"                         },
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
    if preset_mods:has(mods) then
      hotkey.mods = preset_mods:get(mods) --[[ @as ModKeyname[] ]]
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


local function get_key_symbol(key)
  return icons.keys:has(key) and icons.keys:get(key) or icons.replace
end


--
--
---@return string[]
function Hotkey:symbols()
  return lists(self.mods):map(get_key_symbol):values()
end


--
--
---@return string
function Hotkey:label()
  local key = icons.keys:get(self.key) or self.key

  return lists(self:symbols()):push(key):join(' ')
end


--
--
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
  presets = preset_mods,
}