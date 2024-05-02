local U = require 'user.lua.util'

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

local HotKeys = {

  ---@param cmds Command[]
  ---@return hs.hotkey[]
  bindall = function(cmds)
    local bound = {}

    for i, cmd in ipairs(cmds) do
      local hk = cmd.hotkey

      if (hk ~= nil) then
        local title = (hk.message == 'title' and cmd.title) or hk.message

        local function fn()
          cmd.fn({ trigger = 'hotkey' }, {})
        end

        local pressedfn = (U.contains(hk.on, 'pressed') and fn) or nil
        local releasedfn = (U.contains(hk.on, 'released') and fn) or nil
        local repeatfn = (U.contains(hk.on, 'repeat') and fn) or nil

        local bind = hs.hotkey.bind(mods[hk.mods], hk.key, title, pressedfn, releasedfn, repeatfn)

        table.insert(bound, bind)
      end
    end

    return bound
  end,
}

return HotKeys
