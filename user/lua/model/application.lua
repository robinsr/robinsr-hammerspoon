local hotkey  = require 'user.lua.model.hotkey'
local lists   = require 'user.lua.lib.list'
local types   = require 'user.lua.lib.typecheck'



---@class HSAppMenuItem
---@field AXChildren HSAppMenuItem[]
---@field AXEnabled boolean
---@field AXMenuItemCmdChar string
---@field AXMenuItemCmdGlyph string
---@field AXMenuItemCmdModifiers string[]
---@field AXMenuItemMarkChar string
---@field AXRole 'AXMenuBarItem' | 'AXMenuItem'
---@field AXTitle string


---@class App
local App = {}


---@param app hs.application
function App.new(self, app)
  
end


---@param item HSAppMenuItem
---@return App.MenuItem
function App.menuItem(item)

  ---@class App.MenuItem
  local o = {}
  
  o.title = item.AXTitle or '[no title]'

  local mods = item.AXMenuItemCmdModifiers
  local char = item.AXMenuItemCmdChar

  if (not types.isEmpty(char)) then
    o.key = char
    o.mods = mods
    o.hotkey = hotkey.new(mods, char):toTable()
  else
    o.mods = {}
  end

  o.has_children = types.isTable(item.AXChildren) and types.isTable(item.AXChildren[1])

  o.children = o.has_children and lists(item.AXChildren[1]):map(App.menuItem):values() or {}

  return o
end


return App