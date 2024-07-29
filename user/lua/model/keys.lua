local params = require 'user.lua.lib.params'
local Option = require 'user.lua.lib.optional'
local tables = require 'user.lua.lib.table'


---@alias ks.keys.modkey 'shift'|'alt'|'ctrl'|'cmd'

---@alias ks.keys.modcombo 'hyper'|'meh'|'btms'|'peace'|'claw'|'lil'|'shift'|'alt'|'ctrl'|'cmd'

---@alias ks.keys.modifiers ks.keys.modcombo | ks.keys.modkey[]

---@alias ks.keys.presets  { [ks.keys.modcombo]: ks.keys.modkey[] }

---@alias ks.keys.keyevent 'pressed'|'released'|'repeat'

---@alias ks.keys.callback fun(): any

---@alias ks.keys.keycode string|number


local Keys = {}


---@type ks.keys.keyevent[]
Keys.events = { 'pressed', 'released', 'repeat' } 


---@type Table | table<string, string>
Keys.symbols = tables{
  cmd   = "⌘",
  ctrl  = "⌃",
  alt   = "⌥",
  shift = "⇧",
  right = '→',
  left  = '←',
  up    = '↑',
  down  = '↓',
  space = '␣',
}


---@type Table | table<string, string>
Keys.cardinal = tables{
  north = 'w',
  south = 's',
  east = 'd',
  west = 'a',
}


---@type Table | ks.keys.presets
Keys.presets = tables{
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


--
-- Returns the symbol character that corresponds to a key name
--
---@param key string
---@return string
function Keys.getSymbol(key)
  params.assert.string(key)

  return Keys.symbols:get(key) or key
end


return Keys