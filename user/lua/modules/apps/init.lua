local alert   = require 'user.lua.interface.alert'
local appmodel = require 'user.lua.model.application'
local cmd     = require 'user.lua.model.command'
local lists   = require 'user.lua.lib.list'
local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local icons   = require 'user.lua.ui.icons'
local image   = require 'user.lua.ui.image'
local webview = require 'user.lua.ui.webview'
local json    = require 'user.lua.util.json'
local logr    = require 'user.lua.util.logger'
local delay   = require 'user.lua.util'.delay

local log   = logr.new('apps', 'debug')


---@class CurrentApp
---@field name string
---@field path string
---@field title string
---@field bundle_id string


---@class CurrentWindow
---@field app string
---@field id string
---@field role string
---@field subrole string
---@field title string


local Apps = {}

function Apps.onLoad()
  log.df('Pre-loading hs.application; returned %s', hs.application.find('hammerspoon'))
end


---@return CurrentApp
function Apps.currentApp()
  local app = hs.application.frontmostApplication()

  return {
    name = app:name(),
    path = app:path(),
    title = app:title(),
    bundle_id = app:bundleID(),
  }
end

---@return CurrentWindow
function Apps.currentWindow()
  local app = hs.application.frontmostApplication()
  local window = app:focusedWindow()

  return {
    app = app:name(),
    id = window:id(),
    role = window:role(),
    subrole = window:subrole(),
    title = window:title(),
  }
end



---@type CommandConfig[]
Apps.cmds = {
  {
    id = 'apps.current.window',
    title = 'Copy JSON for current window',
    icon = image.from_icon('doc.on.doc'),
    exec = function(ctx, params)
      local window = Apps.currentWindow()

      alert:new('Copying JSON for window "%s"', window.title):show(alert.timing.LONG)

      hs.pasteboard.setContents(json.tostring(window))
    end,
  },
  {
    id = 'apps.current.name',
    title = 'Copy JSON for current app',
    icon = image.from_icon('doc.on.doc'),
    exec = function(ctx, params)
      local app = Apps.currentApp()

      alert:new('Copying JSON for app "%s"', app.name):show(alert.timing.LONG)

      hs.pasteboard.setContents(json.tostring(app))
    end,
  },
}

return Apps