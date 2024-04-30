local M     = require 'moses'
local alert = require 'user.lua.interface.alert'
local util  = require 'user.lua.util'

local log   = util.log('mods:apps', 'debug')

local Apps  = {}

function Apps.onLoad()
  local preload = hs.application.find('hammerspoon')
  log.df('Pre-loading hs.application; returned %s', hs.inspect(preload, { depth = 2 }))
end

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

local function traverseMenu(bin, items)
  for k, item in ipairs(items) do
    if (item["AXChildren"]) then
      bin = traverseMenu(bin, item["AXChildren"][1])
      -- item["AXChildren"] = nil
    elseif (item["AXMenuItemCmdChar"] ~= "") then
      local mods = item["AXMenuItemCmdModifiers"]

      local bits = {
        title = util.default(util.path(item, 'AXTitle'), '(AXTitle nil)'),
        mods = mods and table.concat(mods, "-"),
        -- mods = item["AXMenuItemCmdModifiers"],
        char = item["AXMenuItemCmdChar"],
      }

      table.insert(bin, bits)
    else
      log.d("No key, no children:", item["AXTitle"], item["AXMenuItemCmdChar"])
    end
  end

  return bin
end
function Apps.getMenusForActiveApp()
  local activeapp = hs.application.frontmostApplication()

  alert.alert(util.fmt("Getting keys for %s...", activeapp:name()), nil, nil, 10)

  util.delay(50, function ()
    activeapp:getMenuItems(function(menus)
      -- local slice = { menus[2] }
      table.insert(menus, 1, {})
      local items = traverseMenu({}, menus)
      log.inspect(items, { depth = 3 })
    end)
  end)

end

return Apps
