local params = require 'user.lua.lib.params'
local Option = require 'user.lua.lib.optional'
local tables = require 'user.lua.lib.table'


---@alias ks.keys.modkey 'shift'|'alt'|'ctrl'|'cmd'

---@alias ks.keys.modspressed table<ks.keys.modkey, boolean>

---@alias ks.keys.modcombo 'hyper'|'meh'|'btms'|'peace'|'claw'|'lil'|'shift'|'alt'|'ctrl'|'cmd'

---@alias ks.keys.modifiers ks.keys.modcombo | ks.keys.modkey[]

---@alias ks.keys.presets  table<ks.keys.modcombo, ks.keys.modkey[]>

---@alias ks.keys.keyevent 'pressed'|'released'|'repeat'

---@alias ks.keys.callback fun(): any

---@alias ks.keys.keycode string


local Keys = {}


---@type ks.keys.keyevent[]
Keys.events = { 'pressed', 'released', 'repeat' } 

Keys.code = {
  A = "a",
  B = "b",
  C = "c",
  D = "d",
  E = "e",
  F = "f",
  G = "g",
  H = "h",
  I = "i",
  J = "j",
  K = "k",
  L = "l",
  M = "m",
  N = "n",
  O = "o",
  P = "p",
  Q = "q",
  R = "r",
  S = "s",
  T = "t",
  U = "u",
  V = "v",
  W = "w",
  X = "x",
  Z = "z",
  Y = "y",
  TICK = '`',
  OPEN_BRACKET = '[',
  CLOSE_BRACKET = ']',
  OPEN_ANGLE = ',',
  CLOSE_ANGLE = '.',
  OPEN_PAREN = '9',
  CLOSE_PAREN = '0',
  UP = 'up',
  DOWN = 'down',
  LEFT = 'left',
  RIGHT = 'right',
  PAGEUP = 'pageup',
  PAGEDOWN = 'pagedown',
  BACKSLASH = '\\',
  SEMICOLON = ';',
  QUOTE = "'",
  SLASH = '/',
  QUESTION = '/',
  PLUS = '=',
  MINUS = '-',
  BANG = '1',
  AT = '2',
  HASH = '3',
  DOLLAR = '4',
  PERCENT = '5',
  CARET = '6',
  AMP = '7',
  ASTERISK = '8',
  HOME = 'home',
  END = 'end',
  SPACE = "space",
  TAB = "tab",
}


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


Keys.cardinal = {
  north = 'w',
  south = 's',
  east = 'd',
  west = 'a',
}


Keys.preset = {
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

  -- Shift-and combos
  shift_ctrl = { "shift", "ctrl" },
  shift_alt  = { "shift", "alt" },
  shift_cmd  = { "shift", "cmd" },
}


---@type Table | ks.keys.presets
Keys.presets = tables(Keys.preset)


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