local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local types   = require 'user.lua.lib.typecheck'
local plutils = require 'pl.utils'

local prev_alert = nil


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



---@class AlertConfig
---@field text string
---@field style HS.AlertStyle
---@field icon hs.image
---@field timing AlertTime


---@class Alert
---@field config AlertConfig
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
---@param pattern string
---@param ... any[] pattern variables
---@return Alert
function Alert.new(self, pattern, ...)
  local config = {
    text = strings.fmt(pattern, ...)
  }

  return proto.setProtoOf({ config = config }, Alert)
end


---@param style HS.AlertStyle
---@return Alert
function Alert.style(self, style)
  self.config.style = style
  return self
end


---@param icon hs.image
---@return Alert
function Alert.icon(self, icon)
  self.config.icon = icon
  return self
end


--
-- Shows the configured alert
--
---@param timing? AlertTime
function Alert.show(self, timing)
  hs.alert.closeSpecific(prev_alert, 0)

  local text = self.config.text
  local icon = self.config.icon
  local style = self.config.style
  local screen = hs.screen.mainScreen()
  local seconds = self.config.timing or Alert.timing.NORMAL

  if types.notNil(self.config.icon) then
    prev_alert = hs.alert.showWithImage(text, icon, style, screen, seconds)
  else
    prev_alert = hs.alert.show(text, style, screen, seconds)
  end
end


return Alert