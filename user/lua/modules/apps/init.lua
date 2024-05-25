local alert   = require 'user.lua.interface.alert'
local app     = require 'user.lua.model.application'
local cmd     = require 'user.lua.model.command'
local lists   = require 'user.lua.lib.list'
local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local ui      = require 'user.lua.ui'
local json    = require 'user.lua.util.json'
local logr    = require 'user.lua.util.logger'
local delay   = require 'user.lua.util'.delay

local log   = logr.new('ModApps', 'debug')

-- Returns relevant fields from hs.application.menuitem
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

  alert:new("Getting keys for %s...", activeapp:name()):show()

  delay(1, function ()
    activeapp:getMenuItems(function(menus)
      json.write('~/Desktop/hs-activeapp-getmenuitems.json', menus)

      local items = lists(menus):map(app.menuItem):items()
      
      log.inspect(items, { depth = 3 })
    end)
  end)
end

Apps.cmds = {
  {
    id = 'Apps.getMenusForActiveApp',
    title = 'Show Keys for active app',
    icon = ui.icons.command,
    mods = "bar",
    key = "K",
    exec = function(ctx, params)
      Apps.getMenusForActiveApp()
    end,
  },
}

return Apps