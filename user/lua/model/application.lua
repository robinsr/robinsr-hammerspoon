local Hotkey  = require 'user.lua.model.hotkey'
local lists   = require 'user.lua.lib.list'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'



---@class HS.AppMenuItem
---@field AXChildren HS.AppMenuItem[]
---@field AXEnabled boolean
---@field AXMenuItemCmdChar string
---@field AXMenuItemCmdGlyph string
---@field AXMenuItemCmdModifiers string[]
---@field AXMenuItemMarkChar string
---@field AXRole 'AXMenuBarItem' | 'AXMenuItem'
---@field AXTitle string



---@class ks.app.menuitem
---@field title       string
---@field hasHotkey   boolean
---@field hotkey      ks.keys.hotkey
---@field children    ks.app.menuitem
---@field hasChildren boolean


---@class ks.app
local App = {}


---@param app hs.application
function App.new(self, app)
    
end


---@param item HS.AppMenuItem
---@return ks.app.menuitem
function App.menuItem(item)

  ---@class ks.app.menuitem
  local menuitem = {}
  
  menuitem.title = item.AXTitle or '[no title]'

  local mods = item['AXMenuItemCmdModifiers']
  local char = item['AXMenuItemCmdChar']


  if types.is_not.empty(char) then
    -- local hk = Hotkey:new(mods, char):setDescription(menuitem.title)

    menuitem.hasHotkey = true
    menuitem.hotkey = Hotkey:new(mods, char):setDescription(menuitem.title)
  else
    menuitem.hasHotkey = false
  end

  menuitem.hasChildren = types.isTable(item.AXChildren) and types.isTable(item.AXChildren[1])

  menuitem.children = menuitem.hasChildren and lists(item.AXChildren[1]):map(App.menuItem):values() or {}

  return menuitem
end


return App