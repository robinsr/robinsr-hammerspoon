local desktop = require 'user.lua.interface.desktop'
local menubar = require 'user.lua.interface.menubar'

---@type ks.command.config
local showContextMenu = {
  id = 'ks.commands.show_context_menu',
  title = 'Shows the context menu on global hotkey',
  flags = { 'no-chooser', 'no-alert' },
  icon = 'info',
  key = 'home',
  mods = 'btms',
  setup = function(cmd) end,
  exec = function(cmd, ctx, params)
    local ctx_menu = hs.menubar.new(false, "kittysupreme-ctx")

    if (ctx_menu == nil) then
      error('Could not create context menu')
    end

    ctx_menu:setMenu(menubar.primary_items())
    ctx_menu:popupMenu(desktop.mouse_position())
  end,
}

return {
  module = "Context Menu",
  cmds = {
    showContextMenu
  }
}