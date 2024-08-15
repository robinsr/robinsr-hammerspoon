local dialog = require 'user.lua.interface.dialog'
local shell  = require 'user.lua.adapters.shell'
local keys   = require 'user.lua.model.keys'
local logr   = require 'user.lua.util.logger'

local log = logr.new('mod-macos', 'info')

local mac = {}

mac.module = 'MacOS Utils'

---@type ks.command.config[]
mac.cmds = {
  {
    id    = 'user.finder.refresh',
    title = 'Update finder items',
    desc  = 'Refresh finder windows if files are not updating correctly',
    icon  = '@/resources/images/icons/macos-finder.tmpl.png',
    key   = keys.code.END,
    mods  = keys.preset.btms,
    exec  = function(cmd, ctx, params)
      local ok, result, err = hs.osascript.applescript([[
        tell application "Finder" to tell front window to update every item
      ]])

      return ok and { ok = "Refreshed finder windows" } or { err = result }
    end,
  },

  {
    id    = 'user.killall.prompt',
    title = 'Killall',
    desc  = 'Will invoke command `killall {input}` on submit',
    icon  = 'term',
    flags = { 'no-alert' },
    exec  = function(cmd, ctx, params)
      local placeholder = 'Dock, Finder, etc...'

      local ok, input = dialog.prompt(cmd.title, cmd.desc, placeholder)

      if not ok then
        return { ok = 'cancelled' }
      end

      local result = shell.result({ 'killall', input })

      hs.notify.new(nil, {
        title = 'KittySupreme',
        subTitle = ('Killall %s'):format(input),
        informativeText = ('Exit result: %s'):format(result.output)
      }):send()

      return { ok = ('Killall %s exited with code %d'):format(input, result.code) }
    end,
  }
}

return mac