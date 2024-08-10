local desktop = require 'user.lua.interface.desktop'
local events  = require 'user.lua.interface.events'
local func    = require 'user.lua.lib.func'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local types   = require 'user.lua.lib.typecheck'
local images  = require 'user.lua.ui.image'

local log = require('user.lua.util.logger').new('Alert', 'info')


---@class HS.AlertStyle
---@field fillColor? HS.Color     The background color for the alert; defaults to { white = 0, alpha = 0.75 }.
---@field strokeColor? HS.Color   The outline color for the alert, defaults to { white = 1, alpha = 1 }.
---@field strokeWidth? number     The width of the outline for the alert, defaults to 2
---@field radius? number          The radius used for the rounded corners of the alert box, defaults to 27
---@field textColor? HS.Color     The message text color for the alert, defaults to { white = 1, alpha = 1 }.
---@field textFont? string        The font to be used for the alert text, defaults to ".AppleSystemUIFont" which is a symbolic name representing the systems default user interface font.
---@field textSize? number        The font size to be used for the alert text, defaults to 27.
---@field textStyle? table        Message should be converted to an `hs.styledtext` object using the style elements specified in this table.  This table should conform to the key-value pairs as described in the documentation for the `hs.styledtext` module.  If this table does not contain a `font` key-value pair, one will be constructed from the `textFont` and `textSize` keys (or their defaults); likewise, if this table does not contain a `color` key-value pair, one will be constructed from the `textColor` key (or its default).
---@field padding? number         Pixels to reserve around each side of the text and/or image, defaults to textSize/2
---@field atScreenEdge? 0|1|2     One of — 0: screen center (default); 1: top edge; 2: bottom edge . Note when atScreenEdge>0, the latest alert will overlay above the previous ones if multiple alerts visible on same edge; and when atScreenEdge=0, latest alert will show below previous visible ones without overlap.
---@field fadeInDuration? number  The fade in duration of the alert in seconds, defaults to 0.15
---@field fadeOutDuration? number The fade out duration of the alert in seconds, defaults to 0.15



---@class ks.alert.config
---@field text     string|hs.styledtext
---@field style    HS.AlertStyle
---@field icon     hs.image
---@field timing   AlertTime


---@class ks.alert
---@field config ks.alert.config
local Alert = {}


---@enum AlertTime
Alert.timing = {
  FAST = 0.4,
  NORMAL = 1.8,
  LONG = 3,
}


--
-- Returns a builder for a new alert
--
---@param text string|hs.styledtext
---@param ... any pattern variables
---@return ks.alert
function Alert.new(self, text, ...)

  -- Modify alert style as needed
  local style = hs.alert.defaultStyle

  -- 0: center
  -- 1: top edge
  -- 2: bottom edge
  style.atScreenEdge = 0

  text = type(text) == "string" and strings.fmt(text, ...) or text

  local config = {
    text = text,
    timing = Alert.timing.LONG,
    style = style
  }

  return proto.setProtoOf({ config = config }, Alert)
end


--
-- Alias for `Alert.new` (both a format string as first parameter)
--
Alert.fmt = Alert.new


---@param style HS.AlertStyle
---@return ks.alert
function Alert.style(self, style)
  self.config.style = style
  return self
end


---@param icon hs.image
---@return ks.alert
function Alert.icon(self, icon)
  self.config.icon = icon
  return self
end


--
-- stores the currently displayed alert
--
local prev_alert = nil

local isEscKey = function(code)
  return code == hs.keycodes.map.escape
end


---@type hs.eventtap
local escape_press = events.newKeyDownTap(function(evt)
  if events.isKey(evt, 'escape') and prev_alert ~= nil then
    Alert.closeAll()

    return events.blockNext
  end

  return events.allowNext
end)



function Alert.closeAll()
  if prev_alert ~= nil then
    hs.alert.closeSpecific(prev_alert, 0)
    prev_alert = nil
  end
end


--
-- Shows the configured alert
--
---@param timing? AlertTime|integer
function Alert.show(self, timing)
  hs.alert.closeSpecific(prev_alert, 0)

  local text = self.config.text or ''
  local icon = self.config.icon or nil
  local style = self.config.style or {}
  local screen = hs.screen.mainScreen()
  local seconds = timing or self.config.timing or Alert.timing.NORMAL

  log.df("Alert Config: %s", hs.inspect({ text, icon, style, screen:name(), seconds }))

  if types.notNil(self.config.icon) then
    prev_alert = hs.alert.showWithImage(text, icon, style, screen, 'manualclose')
  else
    prev_alert = hs.alert.show(text, style, screen, 'manualclose')
  end

  func.delay(seconds, Alert.closeAll)
  
  if not escape_press:isEnabled() then
    escape_press:start()
  end
end




Alert.cmds = {
  {
    id = 'ks.test.alert1',
    title = 'Test alert with image',
    icon = 'info',
    mods = 'peace',
    key = 'J',
    setup = {
      img = images.fromPath("@/resources/images/icons8-esc-100.png", { w=50, h=50 }),
    },
    exec = function(cmd, ctx, params)
      Alert:new("Use the escape key")
        :icon(ctx.img)
        :show(20)
    end,
  }
}


return Alert