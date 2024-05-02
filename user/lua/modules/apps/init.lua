local M     = require 'moses'
local alert = require 'user.lua.interface.alert'
local U     = require 'user.lua.util'

local log   = U.log('mods:apps', 'debug')

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


return {
  onLoad = function()
    local preload = hs.application.find('hammerspoon')
    log.df('Pre-loading hs.application; returned %s', hs.inspect(preload, U.d2))
  end,

  getMenusForActiveApp = function()
    local activeapp = hs.application.frontmostApplication()

    alert.alert(U.fmt("Getting keys for %s...", activeapp:name()), nil, nil, 10)

    U.delay(1, function ()
      activeapp:getMenuItems(function(menus)
        
        table.insert(menus, 1, {})
        
        local items = traverseMenu({ mapped = {}, unmapped = {} }, { menus[4] }, {})
        
        log.inspect(items, U.d3)
      end)
    end)
  end,
}