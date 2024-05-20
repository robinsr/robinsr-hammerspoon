local pretty  = require 'pl.pretty'
local alert   = require 'user.lua.interface.alert'
local list    = require 'user.lua.lib.list'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local logr    = require 'user.lua.util.logger'

local log = logr.new('hotkeys.lua', 'info')

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

local modgroups = tables.keys(mods, true)

local symbols = {
  ["cmd"] = "⌘",
  ["ctrl"] = "⌃",
  ["alt"] = "⌥",
  ["shift"] = "⇧",
}

local HotKeys = {}

--
-- Binds key handlers
--
---@param cmds Command[]
---@return hs.hotkey[]
 function HotKeys.bindall(cmds)
  local bound = {}

  for i, cmd in ipairs(cmds) do
    local hk = cmd.hotkey

    if (hk ~= nil) then

      if not tables.contains(modgroups, hk.mods) then
        error(strings.fmt('Bad hotkey modifiers in command: %s', hs.inspect(cmd)))
      end


      local modsymbols = list.map(mods[hk.mods], function(m) return symbols[m] end)
      local expr = strings.join(list.push(modsymbols, hk.key), " ")
      local title = (hk.message == 'title' and cmd.title) or hk.message

      local function fn()
        local context = tables.merge({}, cmd, { trigger = 'hotkey', hotkey = expr })
        local params = {}

        local ok, msg = pcall(cmd.fn, context, params)

        if not ok then
          log.wf('Hotkey callback %s not ok', cmd.id)
        end

        -- todo: command callback alert logic moved up somewhere
        if msg then
          alert.alert(msg)
        end
      end

      local pressedfn = (tables.contains(hk.on, 'pressed') and fn) or nil
      local releasedfn = (tables.contains(hk.on, 'released') and fn) or nil
      local repeatfn = (tables.contains(hk.on, 'repeat') and fn) or nil

      local bind = hs.hotkey.bind(mods[hk.mods], hk.key, title, pressedfn, releasedfn, repeatfn)

      table.insert(bound, bind)

      log.f("Command (%s) mapped to hotkey: %s", strings.pad(cmd.id, 20), expr)
    end
  end

  return bound
end

return HotKeys
