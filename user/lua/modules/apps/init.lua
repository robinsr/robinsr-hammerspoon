local M     = require 'moses'
local alert = require 'user.lua.interface.alert'
local util  = require 'user.lua.util'

local log = util.log('mods:apps', 'debug')

local Apps = {}

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

function Apps.getMenusForActiveApp()
  local activeapp = hs.application.frontmostApplication()
  
  activeapp:getMenuItems(function (menus)

    local slice = { menus[1], menus[2] }

    local topmenus = M.map(slice, function (k, v)
      log.inspect(k, { depth = 1 })
      return util.default(util.path(v, 'AXTitle'), '(AXTitle nil)')
    end)

    log.inspect(topmenus)
  end)

end


return Apps
