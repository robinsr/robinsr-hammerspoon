local lists   = require 'user.lua.lib.list'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local icons   = require 'user.lua.ui.icons'
local json    = require 'user.lua.util.json'
local logr    = require 'user.lua.util.logger'

local log = logr.new('HotKey', 'info')

--[[
https://www.hammerspoon.org/docs/hs.keycodes.html

Valid strings are any single-character string, or any of the following strings:
f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15,
f16, f17, f18, f19, f20, pad., pad*, pad+, pad/, pad-, pad=,
pad0, pad1, pad2, pad3, pad4, pad5, pad6, pad7, pad8, pad9,
padclear, padenter, return, tab, space, delete, escape, help,
home, pageup, forwarddelete, end, pagedown, left, right, down, up,
shift, rightshift, cmd, rightcmd, alt, rightalt, ctrl, rightctrl,
capslock, fn
]]


---@alias ModKeyCombo "hyper" | "meh" | "btms" | "peace" | "claw" | "lil" | "shift" | "alt" | "ctrl" | "cmd"
---@alias ModKeyname "shift" | "alt" | "ctrl" | "cmd"
---@alias KeyEventType "pressed" | "released" | "repeat"
---@alias EventHandler fun(): any

---@type Table
local preset_mods = tables{
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
-- Returns an event handler functin for key-pressed, key-released, 
-- and key-repeat as return values 1, 2, and 3
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



---@return table
function Hotkey:__toplain()
  return tables.toplain(self, { 'symbols', 'label' })
end


---@return string
function Hotkey:__tojson()
  return json.tostring(self:__toplain())
end


return {
  new = function(...) return Hotkey:new(...) end,
  presets = preset_mods,
}