local M     = require 'moses'
local alert = require 'user.lua.interface.alert'
local cmd   = require 'user.lua.model.command'
local ui    = require 'user.lua.ui'
local U     = require 'user.lua.util'

local log   = U.log('ModApps', 'debug')

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
  return table.unpack(U.pick(item, picked))
end



local function traverseMenu(bin, items, p)
  local parent = table.concat(p, " - ")

  for k, item in ipairs(items) do
    local title, mods, char, children = unpackItem(item)

    if (U.isTable(children)) then
      local tail = { table.unpack(p), title }

      bin = traverseMenu(bin, children[1], tail)
    elseif (char ~= "") then

      local bits = {
        title = U.default(title, '(AXTitle nil)'),
        mods = mods and table.concat(mods, "-"),
        char = char,
        parent = parent,
      }

      table.insert(bin.mapped, bits)
    elseif (string.match(title, "\t+") ~= nil) then
      local beforeTabs = string.match(title, "[^\t]*")
      local afterTabs = string.gsub(title, beforeTabs .. "\t+", "")

      local bits = {
        title = U.default(beforeTabs, '(AXTitle nil)'),
        sequence = afterTabs,
        parent = parent,
      }

      table.insert(bin.mapped, bits)
    else
      table.insert(bin.unmapped, U.default(title, '(AXTitle nil)'))
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

  alert.alert(U.fmt("Getting keys for %s...", activeapp:name()), nil, nil, 10)

  U.delay(1, function ()
    activeapp:getMenuItems(function(menus)
      
      table.insert(menus, 1, {})
      
      local items = traverseMenu({ mapped = {}, unmapped = {} }, { menus[4] }, {})
      
      log.inspect(items, U.d3)
    end)
  end)
end

Apps.cmds = {
  {
    id = 'Apps.getMenusForActiveApp',
    title = 'Show Keys for active app',
    menubar = cmd.menubar{ "general", nil, ui.icons.command },
    hotkey = cmd.hotkey{ "bar", "K", "title" },
    fn = function(ctx, params)
      Apps.getMenusForActiveApp()
    end,
  },
}

return Apps