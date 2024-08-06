local App     = require 'user.lua.model.application'
local fns     = require 'user.lua.lib.func'
local lists   = require 'user.lua.lib.list'
local params  = require 'user.lua.lib.params'
local paths   = require 'user.lua.lib.path'
local strings = require 'user.lua.lib.string'
local types   = require 'user.lua.lib.typecheck'
local tables  = require 'user.lua.lib.table'
local json    = require 'user.lua.util.json'
local logr    = require 'user.lua.util.logger'

local log = logr.new('Desktop', 'info')

---@class ks.desktop.app
---@field name string
---@field path string
---@field title string
---@field bundle_id string


---@class ks.desktop.window
---@field app string
---@field id string
---@field role string
---@field subrole string
---@field title string




local query_dark_mode = fns.cooldown(10, function()
  log.d('Querying "System Events" for current dark mode')

  local ok, darkModeState = hs.osascript.javascript(
    'Application("System Events").appearancePreferences.darkMode()'
  )

  if not ok then
    error('Error executing osascript (js):')
  end

  return types.tobool(darkModeState) --[[@as boolean]]
end)




---@class ks.desktop
local desktop = {}


---@alias ks.desktop.selectscreen
---| 'main'     Screen containing the currently focused window / foremost app (the app receiving text input)
---| 'active'   Alias for the 'main' screen
---| 'mouse'    The screen containing the pointer
---| 'primary'  The primary screen contains the menubar and dock

---@type { [ks.desktop.selectscreen]: fun(): hs.screen }
local selectors = {
  main    = hs.screen.mainScreen,
  mouse   = hs.mouse.getCurrentScreen,
  active  = hs.screen.mainScreen,
  primary = hs.screen.primaryScreen,
}

--
-- Gets the relevant hs.screen object from HS
--
---@param sel ks.desktop.selectscreen
---@return hs.screen
function desktop.getScreen(sel)
  ---@type hs.screen
  local default = hs.screen.allScreens()[1] 

  if (types.isString(sel) and tables.has(selectors, sel)) then
    return selectors[sel]() or default
  else
    error(strings.fmt("Invalid screen selector [%q]", sel), 2)
  end
end



--
-- Returns all screns
--
---@return hs.screen[]
function desktop.screens()
  return hs.screen.allScreens() --[[@as hs.screen[] ]]
end


--
-- Returns the numerical ID of the currently active window, or nil if none exists
--
---@return integer
function desktop.activeWindowId()
  return hs.window.focusedWindow():id() or 0
end


--
-- Returns the currently active window, or nil if none exists
--
---@return hs.window|nil
function desktop.activeWindow()
  return hs.window.focusedWindow()
end


--
-- Returns the currently active app, or nil if none exists
--
---@return hs.application|nil
function desktop.activeApp()
  local focused = desktop.activeWindow()
  return focused and focused:application()
end


--
-- Returns the space ID for the currently focused space. The focused space is
-- the currently active space on the currently active screen (i.e. that the 
-- user is working on)
--
---@return integer
function desktop.activeSpace()
  return hs.spaces.focusedSpace()
end


-- --
-- -- Gets the spaceId's for the selected screen (defaults to active screen)
-- --
-- ---@param screen? ks.desktop.selectscreen
-- ---@return integer[]
-- function desktop.screenSpaces(screen)
--   screen = screen or 'active'

--   local screen_ids, err = hs.spaces.spacesForScreen(desktop.getScreen(screen))

--   if err ~= nil then
--     error(err)
--   end

--   return screen_ids --[[@as integer[] ]]
-- end


--
-- Returns all the displayable properties of a `hs.application` object
--
---@param app         hs.application
---@param noWindows?  boolean
---@return            ks.desktop.app
function desktop.appInfo(app, noWindows)
  noWindows = noWindows or false

  local appInfo = {
    name = app:name(),
    title = app:title(),
    path = app:path(),
    pid = app:pid(),
    bundleID = app:bundleID(),
  }

  if not noWindows then
    appInfo.windows = lists(app:allWindows()):map(function(w)
      return w and desktop.windowInfo(w, true)
    end):values()
  end
  
  return appInfo
end


--
-- Returns all the displayable properties of a `hs.window` object
--
---@param window   hs.window
---@param noApp?   boolean
---@return         ks.desktop.window
function desktop.windowInfo(window, noApp)
  noApp = noApp or false

  local winInfo = {
    id = window:id(),
    role = window:role(),
    subrole = window:subrole(),
    title = window:title(),
    frame = window:frame(),
    isFullScreen = window:isFullScreen(),
    isMaximizable = window:isMaximizable(),
    isMinimized = window:isMinimized(),
    isStandard = window:isStandard(),
    isVisible = window:isVisible(),
  }

  if not noApp then
    local app = window:application()

    if app then
      winInfo.app = desktop.appInfo(app, true)
    end
  end

  return winInfo
end


--
-- Returns the current state of dark mode
--
---@return boolean
function desktop.darkMode()
  return query_dark_mode()
end


--
-- returns a geometry object describing the current position of the mouse
--
function desktop.mouse_position()
  return hs.mouse.absolutePosition()
end


--
-- Sets the pasteboard contents
--
---@param val string
function desktop.setPasteBoard(val)
  hs.pasteboard.setContents(val)
end



--
-- Gets the top window on screen
--
---@return hs.window
function desktop.getTopWindow()
  local screen = desktop.getScreen('mouse')

  return lists(hs.window.orderedWindows())
    :filter(function(win)
      ---@cast win hs.window
      return win:screen():id() == screen:id()
    end)
    :first(function(win) return win ~= nil end) --[[@as hs.window]]

  -- return hs.window:frontmostWindow()
end


--
--
--
function desktop.getMenuItems(app)
  local rawitems = app:getMenuItems()
  
  json.write('~/Desktop/menuitems.json', rawitems)

  ---@param memo table
  ---@param item ks.app.menuitem
  local function reducer(memo, item)
    if item.hasChildren then
      for i,child in ipairs(item.children) do
        reducer(memo, child)
      end
    else
      table.insert(memo, item)
    end

    return memo
  end
  
  -- log.inspect(rawitems, logr.d3)
  

  local menuitems = lists(rawitems)
    :map(function(mi)
      return App.menuItem(mi)
    end)
    :map(function(mi)
      local parent = mi.title
      local childs = lists(mi.children):reduce({}, reducer)
    
      return lists(childs)
        :filter(function(item)
          return item.title ~= ""
        end)
        :map(function(item) 
          item.children = nil
          item.hasChildren = nil
          item.hasHotkey = nil
          item.parent = mi.title
          return item
        end)
        :values()
    end)
    :flatten()
    :values()

  log.inspect(menuitems)
  
  return menuitems
end


return desktop