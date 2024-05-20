local alert   = require 'user.lua.interface.alert'
local cmd     = require 'user.lua.model.command'
local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local ui      = require 'user.lua.ui'
local logr    = require 'user.lua.util.logger'
local delay   = require 'user.lua.util'.delay

local log   = logr.new('ModApps', 'debug')

-- Returns relevant fields from hs.application.menuitem
--[[
  AXChildren = {...},
  AXEnabled = true,
  AXMenuItemCmdChar = "",
  AXMenuItemCmdGlyph = "",
  AXMenuItemCmdModifiers = {...},
  AXMenuItemMarkChar = "",
  AXRole = "AXMenuBarItem",
  AXTitle = "Messages"
]]
local function unpackItem(item)
  local picked = { "AXTitle", "AXMenuItemCmdModifiers", "AXMenuItemCmdChar", "AXChildren" }
  return table.unpack(tables.pick(item, picked))
end



local function traverseMenu(bin, items, p)
  local parent = table.concat(p, " - ")

  for k, item in ipairs(items) do
    local title, mods, char, children = unpackItem(item)

    if (types.isTable(children)) then
      local tail = { table.unpack(p), title }

      bin = traverseMenu(bin, children[1], tail)
    elseif (char ~= "") then

      local bits = {
        title = params.default(title, '(AXTitle nil)'),
        mods = mods and table.concat(mods, "-"),
        char = char,
        parent = parent,
      }

      table.insert(bin.mapped, bits)
    elseif (string.match(title, "\t+") ~= nil) then
      local beforeTabs = string.match(title, "[^\t]*")
      local afterTabs = string.gsub(title, beforeTabs .. "\t+", "")

      local bits = {
        title = params.default(beforeTabs, '(AXTitle nil)'),
        sequence = afterTabs,
        parent = parent,
      }

      table.insert(bin.mapped, bits)
    else
      table.insert(bin.unmapped, params.default(title, '(AXTitle nil)'))
    end
  end

  return bin
end


local Apps = {}

function Apps.onLoad()
  log.df('Pre-loading hs.application; returned %s', hs.application.find('hammerspoon'))
end

function Apps.getMenusForActiveApp()
  local activeapp = hs.application.frontmostApplication()

  alert.alert(strings.fmt("Getting keys for %s...", activeapp:name()), nil, nil, 10)

  delay(1, function ()
    activeapp:getMenuItems(function(menus)
      
      table.insert(menus, 1, {})
      
      local items = traverseMenu({ mapped = {}, unmapped = {} }, { menus[4] }, {})
      
      log.inspect(items, { depth = 3 })
    end)
  end)
end

Apps.cmds = {
  {
    id = 'Apps.getMenusForActiveApp',
    title = 'Show Keys for active app',
    menubar = cmd.menubar{ "general", nil, ui.icons.command },
    hotkey = cmd.hotkey("bar", "K", "title"),
    fn = function(ctx, params)
      Apps.getMenusForActiveApp()
    end,
  },
}

return Apps