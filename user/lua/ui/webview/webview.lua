local alert  = require 'user.lua.interface.alert'
local desk   = require 'user.lua.interface.desktop'
local tables = require 'user.lua.lib.table'
local types  = require 'user.lua.lib.typecheck'
local vm     = require 'user.lua.ui.webview.viewmodel'
local render = require 'user.lua.ui.webview.renderer'
local json   = require 'user.lua.util.json'

local log = require('user.lua.util.logger').new('webview', 'debug')

---@alias HS.Webview.Masks
---| 'HUD'
---| 'borderless'
---| 'closable'
---| 'fullSizeContentView'
---| 'miniaturizable'
---| 'nonactivating'
---| 'resizable'
---| 'texturedBackground'
---| 'titled'
---| 'utility'

local winmasks = hs.webview.windowMasks


---@alias HS.WindowBehaviors
---| 'canJoinAllSpaces'
---| 'default'
---| 'fullScreenAllowsTiling'
---| 'fullScreenAuxiliary'
---| 'fullScreenDisallowsTiling'
---| 'fullScreenPrimary'
---| 'ignoresCycle'
---| 'managed'
---| 'moveToActiveSpace'
---| 'participatesInCycle'
---| 'stationary'
---| 'transient'


local FADE_TIME = alert.timing.FAST


local Webview = {}

---@type hs.webview|nil
Webview.current = nil


function Webview.showing()
  return types.notNil(Webview.current)
end


function Webview.close_all()
  if types.notNil(Webview.current) then
    Webview.current = Webview.current:delete(true, FADE_TIME)
    return
  end
end


--
-- Returns a new hs.webview instance with sensible defaults
--
-- For future, config options to include
-- - frame dimensions
-- - 
--
---@return hs.webview
function Webview.new_webview()
  local controller = hs.webview.usercontent.new('kittysupreme') --[[@as hs.webview.usercontent]]

  controller:setCallback(function(msg)
    log.df('webview controller post-message: %s', hs.inspect(msg.body))

    local jsonok, json = pcall(function() return json.decode(msg.body) end)

    if jsonok and json.action then
      if json.action == 'pbcopy' then
        return desk.setPasteBoard(json.data)
      end

      if json.action == 'print' then
        return log.f('Webview print: %s', hs.inspect(json.data))
      end

      if json.action == 'close' then
        return Webview.close_all()
      end
    end

    if msg.body == 'close' then
      return Webview.close_all()
    end
  end)

  local MAX_WIDTH = 1680
  local MAX_HEIGHT = 1124

  local screen_frame = desk.getScreen('active'):frame()
  local max_startx = screen_frame.center.x - (MAX_WIDTH/2)
  local max_starty = screen_frame.center.y - (MAX_HEIGHT/2)
  local webview_max = hs.geometry.new({ max_startx, max_starty, MAX_WIDTH, MAX_HEIGHT })

  local webview_frame = desk.getScreen('active'):frame():scale({ w = 0.88, h = 0.92 })
    
  if not webview_frame:inside(webview_max) then
    -- webview_frame:fit(webview_max)
    webview_frame = webview_max
  end

  local WEBVIEW_OPTS = {
    developerExtrasEnabled = true,
  }

  local view = hs.webview.new(webview_frame, WEBVIEW_OPTS, controller) --[[@as hs.webview]]

  -- view:windowStyle({ "borderless", "closable", "utility" })
  view:windowStyle(winmasks.fullSizeContentView)
  view:behaviorAsLabels({ "canJoinAllSpaces", "stationary" })
  view:transparent(true)
  view:darkMode(desk.darkMode())
  view:closeOnEscape(true)
  view:allowGestures(true)
  view:allowTextEntry(true)
  view:shadow(true)


  log.f("Webview Using zoom level %q", view:magnification())

  return view
end


--
-- Creates a webview with content provided by parameter
--
---@param content string
---@param title? string
function Webview.content(content, title)
  if Webview.showing() then
    return Webview.close_all()
  end

  title = title or vm.base_model().title

  ---@type hs.webview
  local view = Webview.new_webview()

  view:windowTitle(title)
  view:html(content)
  view:show(FADE_TIME)
  
  view:hswindow():becomeMain():focus()

  view:windowCallback(function(obj) 
    log.df("Webview (%s) window callback: %s", title, hs.inspect(obj))
  end)

  Webview.current = view
end


--
-- Creates a webview with content rendered from 'template' within a whole-page HTML wrapper
--
---@param template string
---@param viewmodel? table
---@param title? string
function Webview.page(template, viewmodel, title)
  Webview.content(render.page(template, viewmodel or {}), title)
end


--
-- Creates a webview with content rendered from 'template' without a HTML wrapper.
--
---@param filepath string
---@param viewmodel? table
---@param title? string
function Webview.file(filepath, viewmodel, title)
  Webview.content(render.file(filepath, viewmodel or {}), title)
end


return Webview