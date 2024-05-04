local alert = require 'user.lua.interface.alert'
local U     = require 'user.lua.util'

local log = U.log('hotkeys.lua', 'debug')

--- Uncomment to inspect system keycodes
-- log.i(hs.inspect(hs.keycodes.map))

local mods = {
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

local symbols = {
  ["cmd"] = "⌘",
  ["ctrl"] = "⌃",
  ["alt"] = "⌥",
  ["shift"] = "⇧",
}

local HotKeys = {

  ---@param cmds Command[]
  ---@return hs.hotkey[]
  bindall = function(cmds)
    local bound = {}

    for i, cmd in ipairs(cmds) do
      local hk = cmd.hotkey

      if (hk ~= nil) then
        local modsymbols = U.map(mods[hk.mods], function(m) return symbols[m] end)
        local expr = U.join(U.concat(modsymbols, { hk.key }))
        local title = (hk.message == 'title' and cmd.title) or hk.message

        local function fn()
          local msg = cmd.fn(U.merge(cmd, { trigger = 'hotkey', hotkey = expr }), {})
          -- todo: command callback alert logic moved up somewhere
          if msg then alert.alert(msg) end
        end

        local pressedfn = (U.contains(hk.on, 'pressed') and fn) or nil
        local releasedfn = (U.contains(hk.on, 'released') and fn) or nil
        local repeatfn = (U.contains(hk.on, 'repeat') and fn) or nil

        local bind = hs.hotkey.bind(mods[hk.mods], hk.key, title, pressedfn, releasedfn, repeatfn)

        table.insert(bound, bind)

        log.f("Command (%s) mapped to hotkey: %s", U.pad(cmd.id, 20), expr)
      end
    end

    return bound
  end,
}

return HotKeys
