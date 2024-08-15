local inspect = require 'inspect'
local nanoid  = require 'nanoid'
local desk    = require 'user.lua.interface.desktop'
local func    = require 'user.lua.lib.func'
local json    = require 'user.lua.lib.json'
local params  = require 'user.lua.lib.params'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local vm      = require 'user.lua.ui.webview.viewmodel'
local render  = require 'user.lua.ui.webview.renderer'
local logr    = require 'user.lua.util.logger'

local log = logr.new('webview', 'debug')


---@alias HS.WindowBehavior
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


---@alias HS.Webview.Mask
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


-- Function to be called when the webview window is moved or closed
---@alias HS.Webview.CallbackFn fun(action: HS.Webview.CallbackAction, webview: hs.webview, ...: hs.geometry|boolean): nil 

---@alias HS.Webview.CallbackAction
---|'closing'     - is being closed, either by the user or with the `hs.webview:delete` method 
---|'focusChange' - has either become or stopped being the focused window. `state` - boolean true if gained focused, false if lost focus
---|'frameChange' - has been moved or resized. `frame` - a rect-table containing the new co-ordinates and size of the webview window


---@alias ks.webview.type 'standard'|'dialog'|'alert'|'info'


---@class ks.webview.typeconfig
---@field behaviors      HS.WindowBehavior[]
---@field masks          HS.Webview.Mask[]
---@field constraints    ks.window.constraints
---@field allowText      boolean
---@field transparent    boolean


---@type { [ks.webview.type]: Dimensions }
local webview_sizes = {
  standard = { w = 1680, h = 1124 },
  dialog   = { w = 768, h = 640 },
  alert    = { w = 768, h = 480 },
  info     = { w = 768, h = 360 },
}

---@type { [ks.webview.type]: ks.webview.typeconfig }
local webview_types = {
  standard = {
    behaviors   = { 'canJoinAllSpaces', 'stationary' },
    masks       = { 'fullSizeContentView' },
    allowText   = true,
    transparent = true,
    constraints = {
           maxp = { w = 1680, h = 1124 },
           maxu = { w = 0.88, h = 0.92 },
    },
  },
  dialog = {
    behaviors   = { 'default' },
    masks       = { 'closable', 'miniaturizable', 'resizable', 'titled' },
    allowText   = true,
    transparent = false,
    constraints = {
           maxp = { w = 1024,  h = 768 },
           maxu = { w = 0.60, h = 0.80 },
    },
  }
}


---@class hs.webview
local Webview = {}

---@type { [string]: hs.webview }
Webview.windows = {}

---@type number
Webview.timing = 0.5


--
-- Returns true if a webview with a matching ID is currently displayed on screen
--
---@param id string
---@return boolean
function Webview.showing(id)
  return types.notNil(Webview.windows[id])
end


--
-- Closes the currently webview, performs cleanup, refocuses previously focused window 
--
---@param id? string
function Webview.close(id)
  local closeWindow = function(id)
    if Webview.windows[id] ~= nil then
      Webview.windows[id]:delete(true, Webview.timing)
      Webview.windows[id] = nil

      -- Refocuses the previously focused window
      -- Are these getting garbage collected?
      func.delay(0.5, function()
        desk.topWindow():focus()
      end)
    end
  end

  if id ~= nil then
    closeWindow(id)
  else
    for key, _ in tables.entries(Webview.windows) do
      closeWindow(key)
    end
  end
end


--
--
--
---@param id   string
---@return hs.webview.usercontent
local function newController(id)
  local controller = hs.webview.usercontent.new('kittysupreme') --[[@as hs.webview.usercontent]]

  local jsLogger = logr.new(('webview-%s'):format(id))

  jsLogger.f('New JS Logger created for webview#%s', id)

  controller:setCallback(function(msg)
    log.df('webview controller post-message: %s', hs.inspect(msg.body))

    local jsonok, json = pcall(json.decode, msg.body)

    if jsonok and json.action then
      
      if json.action == 'pbcopy' then
        desk.setPasteBoard(json.data)
      end

      if json.action == 'print' then
        log.f('Webview print: %s', hs.inspect(json.data))
      end

      if json.action == 'log' then
        log.df('Webview log: %s', hs.inspect(json.data))
        
        jsLogger[json.data.level](json.data.message, table.unpack(json.data.vars or {}))
      end

      if json.action == 'close' then
        Webview.close(id)
      end

      return
    end

    if msg.body == 'close' then
      return Webview.close(id)
    end
  end)

  return controller
end


--
-- Returns a new hs.webview instance with sensible defaults
--
---@param id   string
---@param type ks.webview.type
---@return hs.webview
local function createWebview(id, type)
  params.assert.string(id, 1)
  params.assert.string(type, 2)


  ---@type ks.webview.typeconfig
  local conf = webview_types[type]

  local webview_frame = desk.getReasonableSpace('active', conf.constraints)
  local controller = newController(id)


  local WEBVIEW_OPTS = {
    developerExtrasEnabled = true,
  }

  Webview.windows[id] = hs.webview.new(webview_frame, WEBVIEW_OPTS, controller) --[[@as hs.webview]]

  Webview.windows[id]:windowStyle(conf.masks)
  Webview.windows[id]:behaviorAsLabels(conf.behaviors)
  Webview.windows[id]:allowTextEntry(conf.allowText)
  Webview.windows[id]:transparent(conf.transparent)
  
  Webview.windows[id]:darkMode(desk.darkMode())
  Webview.windows[id]:closeOnEscape(true)
  Webview.windows[id]:allowGestures(true)
  Webview.windows[id]:shadow(true)

  ---@type HS.Webview.CallbackFn
  local onCallback = function(action, wv, ...)
    if action ~= 'frameChange' then
      log.df("Webview (%s) %s callback: %s", wv:title(), action, inspect({...}))
    end
  end

  Webview.windows[id]:windowCallback(onCallback)

  log.f("Webview Using zoom level %q", Webview.windows[id]:magnification())

  return Webview.windows[id]
end



--
-- 
--
---@param template   string
---@param viewmodel  ks.viewmodel
function Webview.mainWindow(template, viewmodel)
  if Webview.showing('main') then
    return Webview.close('main')
  end

  local ok, content = pcall(render.file, template, viewmodel)
  
  if not ok then
    error(content)
  end

  ---@type hs.webview
  local view = createWebview('main', 'standard')

  view:windowTitle(viewmodel.title or '')
  view:html(content)
  view:show(Webview.timing)
  view:hswindow():becomeMain():focus()

  Webview.current = view
end


--
--
--
---@param id         string         - Unique identifier for this dialog
---@param template   string         - Name of template file to render
---@param viewmodel  ks.viewmodel   - Template viewmodel
function Webview.dialog(id, template, viewmodel)
  local ok, content = pcall(render.file, template, viewmodel)
  
  if not ok then
    error(content)
  end

  local webviewId = nanoid.generate(8) --[[@as string]]

  ---@type hs.webview
  local view = createWebview(webviewId, 'dialog')

  view:windowTitle(viewmodel.title or '')
  view:html(content)
  view:show(Webview.timing)
  view:hswindow():becomeMain():focus()
end


return Webview