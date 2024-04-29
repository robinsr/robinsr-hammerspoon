local util = require 'user.lua.util'
local cmds = require 'user.lua.commands'
local M = require 'moses'

local log = hs.logger.new('hotkeys.lua', 'debug')

-- log.i(hs.inspect(hs.keycodes.map))

local mods = {
  hyper = { "shift", "alt", "ctrl", "cmd" },
  meh   = { "shift",        "ctrl", "cmd" },
  bar   = {          "alt", "ctrl", "cmd" },
  modA  = { "shift", "alt"                },
  modB  = { "shift", "alt", "ctrl"        },
}

local HotKeys = {
  bindall = function(cmds)
    return M(cmds)
      :filter(function(i, cmd) 
        return type(cmd.hotkey) ~= 'nil'
      end)
      :map(function(i, cmd) 
        local mod = cmd.hotkey[1]
        local key = cmd.hotkey[2]
        
        return hs.hotkey.bind(util.path(mods, mod), key, cmd.title, cmd.fn)    
      end)
      :value()
  end,
}

return HotKeys