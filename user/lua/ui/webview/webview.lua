local alert  = require 'user.lua.interface.alert'
local desk   = require 'user.lua.interface.desktop'
local tables = require 'user.lua.lib.table'
local types  = require 'user.lua.lib.typecheck'
local vm     = require 'user.lua.ui.webview.viewmodel'
local render = require 'user.lua.ui.webview.renderer'
local logr   = require 'user.lua.util.logger'

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

local log = logr.new('webview', 'info')

local FADE_TIME = alert.timing.FAST
local WEBVIEW_OPTS = {
  developerExtrasEnabled = true,
}


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
    log.i('webview controller callback', hs.inspect(msg.body))

    if msg.body == 'close' then
      Webview.close_all()
      return
    end

  end)

  local win_dimensions = desk.getScreen('active'):frame():scale({ w = 0.50, h = 0.90 })

  local view = hs.webview.new(win_dimensions, WEBVIEW_OPTS, controller) --[[@as hs.webview]]

  view:windowStyle({ "borderless", "closable", "utility" })
  view:behaviorAsLabels({ 'moveToActiveSpace' })
  view:transparent(true)
  view:darkMode(desk.darkMode())
  view:closeOnEscape(true)
  view:allowGestures(true)
  view:allowTextEntry(true)
  -- view:shadow(true)

  return view
end


--
--
---@param template string
---@param viewmodel? table
---@param title? string
function Webview.page(template, viewmodel, title)

  if Webview.showing() then
    return Webview.close_all()
  end

  viewmodel = viewmodel or {}
  title = title or vm.base_model.title

  ---@type hs.webview
  local view = Webview.new_webview()

  view:windowTitle(title)
  view:html(render.page(template, viewmodel))
  view:show(FADE_TIME)
  
  view:hswindow():becomeMain():focus()

  view:windowCallback(function(obj) print(hs.inspect(obj)) end)

  Webview.current = view
end


--
--
---@param file string
---@param viewmodel? table
---@param title? string
function Webview.file(file, viewmodel, title)
  if Webview.showing() then
    return Webview.close_all()
  end

  viewmodel = viewmodel or {}
  title = title or vm.base_model.title

  ---@type hs.webview
  local view = Webview.new_webview()

  view:windowTitle(title)
  view:html(render.file(file, viewmodel))
  view:show(FADE_TIME)

  view:windowCallback(function(obj) print(hs.inspect(obj)) end)


  Webview.current = view
end

return Webview



--[[
Example webview callback data


{
  body = "popopopo",
  frameInfo = {
    mainFrame = true,
    request = {
      HTTPHeaderFields = {},
      HTTPMethod = "GET",
      HTTPShouldHandleCookies = true,
      HTTPShouldUsePipelining = false,
      URL = {
        __luaSkinType = "NSURL",
        url = "about:blank"
      },
      cachePolicy = "protocolCachePolicy",
      networkServiceType = "default",
      timeoutInterval = 60.0
    },
    securityOrigin = {
      host = "",
      port = 0,
      protocol = ""
    }
  },
  name = "kittysupreme",
  webView = <userdata 1> -- hs.webview: KittySupreme Hotkeys (0x6000002abbf8)
}


]]