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

local log = logr.new('Desktop', 'debug')

---@class ks.app
---@field name string
---@field path string
---@field title string
---@field bundle_id string


---@class ks.window
---@field app string
---@field id string
---@field role string
---@field subrole string
---@field title string


---@class ks.window.constraints
---@field maxp    Dimensions
---@field maxu    Dimensions
---@field minp?   Dimensions
---@field minu?   Dimensions


---@alias ks.screen.selector ks.screen.type | number


---@alias ks.screen.type
---| 'main'     Screen containing the currently focused window / foremost app (the app receiving text input)
---| 'active'   Alias for the 'main' screen
---| 'mouse'    The screen containing the pointer
---| 'primary'  The primary screen contains the menubar and dock


---@alias hs.screen.pos table<hs.screen, Coord>


---@type { [ks.screen.type]: fun(): hs.screen }
local selectors = {
  main    = hs.screen.mainScreen,
  mouse   = hs.mouse.getCurrentScreen,
  active  = hs.screen.mainScreen,
  primary = hs.screen.primaryScreen,
}

local SBAR_HEIGHT = 40


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


--
-- Returns all screns
--
---@return hs.screen[]
function desktop.screens()
  return hs.screen.allScreens() --[[@as hs.screen[] ]]
end


--
-- Gets the relevant hs.screen object from HS
--
---@param sel ks.screen.selector
---@return hs.screen
function desktop.getScreen(sel)
  ---@type hs.screen
  local default = hs.screen.allScreens()[1]

  if type(sel) == 'string' and tables.has(selectors, sel) then
    return selectors[sel]() or default
  end

  if type(sel) == 'number' then
    return hs.screen.allScreens()[sel]
  end

  error(strings.fmt("Invalid screen selector [%q]", sel), 2)
end


--
-- Returns a `hs.geometry` object representing the space on the active screen that
-- windows can be moved within. Accounts for Sketchybar and preference for window
-- padding
--
---@param sel ks.screen.selector
---@return hs.geometry
function desktop.getAvailableSpace(sel)
  local sbar = KittySupreme:getService('SketchyBar')
  local screen = desktop.getScreen(sel):frame():copy()

  ---@type ks.window.constraints
  local consts = {
    maxp = { w = screen.w, h = screen.h },
    maxu = { w = 0.98, h = 0.98 },
  }

  local scale = { x = 0.98, y = 0.98 }
  local offset = { x = 0, y = 0 }

  if sbar.running then
    screen.h = screen.h - SBAR_HEIGHT
    offset.y = -SBAR_HEIGHT
  end

  return screen:copy():scale(scale)
    -- :move(offset)
    -- :scale(scale)
end


---@type ks.window.constraints
local reasonable = {
  maxp = { w = 1680, h = 1200 },
  maxu = { w = 0.88, h = 0.92 },
}


--
-- Returns a `hs.geometry` object representing a portion of space on the specified
-- screen considered a "reasonable" size for a window (not too big, not too small).
-- If supplied with constraints, will clip the size to within reasonable
--
---@param sel     ks.screen.selector
---@param prefs?  ks.window.constraints
---@return hs.geometry
function desktop.getReasonableSpace(sel, prefs)
  prefs = tables.merge({}, reasonable, prefs or {}) --[[@as ks.window.constraints]]
  
  local scale = { x = prefs.maxu.w, y = prefs.maxu.h }
  
  local sbar = KittySupreme:getService('SketchyBar')
  local screen = desktop.getScreen(sel):frame():copy()

  if sbar.running then
    screen.center.y = screen.center.y - SBAR_HEIGHT/2
  end

  local max_pixels = hs.geometry.new({
    w = prefs.maxp.w,
    h = prefs.maxp.h,
    x = screen.center.x - prefs.maxp.w/2,
    y = screen.center.y - prefs.maxp.h/2,
  })

  local max_unit = screen:copy():scale(scale)

  log.d('max_pixels = ', hs.inspect(max_pixels.table))
  log.d('max_unit = ', hs.inspect(max_unit.table))


  return max_unit:intersect(max_pixels)

  -- return max_frame:inside(max_cent) and max_frame or max_cent
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


--
-- According to the HS docs:
--   "Returns the 'main' screen, i.e. the one containing the currently focused window"
--
function desktop.activeScreen()
  hs.screen.mainScreen()
end


--
-- Returns a table of int IDs of the spaces for the specified screen in their current order.
--
---@param sel ks.screen.selector
---@return Array<integer>
function desktop.spacesForScreen(sel)
  return hs.spaces.spacesForScreen(desktop.getScreen(sel)) --[[@as Array<integer>]]
end



--
--
--
---@return hs.screen.pos
function desktop.screenPositions()
  return hs.screen.screenPositions() --[[@as hs.screen.pos]]
end


--
-- Returns a integer index for the space specified with `spaceId` relative to other
-- spaces on the same screen. Defaults to "main" screen (see `desktop.activeScreen`)
--
-- (This is helpful in translating between Yabai's mission-control-index-based screen
-- selectors and Hammerspoon's use of space ID numbers)
--
---@param spaceId int
---@return int
function desktop.getIndexOfSpace(spaceId)
  params.assert.number(spaceId, 1)

  local screen_pos = tables.invert(desktop.screenPositions())

  local all_spaces = lists(tables.keys(screen_pos))
    :sort(function(a, b) return a.x > b.x end)
    :map(function(coord) return hs.spaces.spacesForScreen(screen_pos[coord]) end)
    :flatten()

  log.d('All spaces:', hs.inspect(all_spaces:values()))
  
  return lists(all_spaces):indexOf(spaceId)
end


--
-- Returns all the displayable properties of a `hs.application` object
--
---@param app         hs.application
---@param noWindows?  boolean
---@return            ks.app
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
---@return         ks.window
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