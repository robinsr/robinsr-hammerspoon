local strings = require 'user.lua.lib.string'


-- Shows an alert on screen. 
-- Clears previous alert on subsequenct alert calls, preventing alerts from stacking
local Alert = {}

local prev_alert = nil

-- Shows an alert on screen. 
-- Currently just proxies to hs.alert.show with no modifications
--
---@param str string The string or `hs.styledtext` object to display in the alert
---@param style? table an optional table containing one or more of the keys specified in [hs.alert.defaultStyle](#defaultStyle).  If `str` is already an `hs.styledtext` object, this argument is ignored.
---@param screen? any string an optional `hs.screen` userdata object specifying the screen (monitor) to display the alert on.  Defaults to `hs.screen.mainScreen()` which corresponds to the screen with the currently focused window.
---@param seconds? integer The number of seconds to display the alert. Defaults to 2.  If seconds is specified and is not a number, displays the alert indefinitely.
function Alert.alert(str, style, screen, seconds, ...)
  hs.alert.closeSpecific(prev_alert, 0)
  prev_alert = hs.alert.show(str, style, screen, seconds, ...)
end


function Alert.showf(fmt_string, fmt_args, style, screen, seconds)
  hs.alert.closeSpecific(prev_alert, 0)
  local str = strings.fmt(fmt_string, table.unpack(fmt_args))
  Alert.alert(str, style, screen, seconds)
end

-- Shows an alert on screen with an image. 
-- Currently just proxies to hs.alert.show with no modifications
--
---@param str string The string or `hs.styledtext` object to display in the alert
---@param image any The image to display in the alert
---@param style? table an optional table containing one or more of the keys specified in [hs.alert.defaultStyle](#defaultStyle).  If `str` is already an `hs.styledtext` object, this argument is ignored.
---@param screen? any string an optional `hs.screen` userdata object specifying the screen (monitor) to display the alert on.  Defaults to `hs.screen.mainScreen()` which corresponds to the screen with the currently focused window.
---@param seconds? integer The number of seconds to display the alert. Defaults to 2.  If seconds is specified and is not a number, displays the alert indefinitely.
function Alert.imageAlert(str, image, style, screen, seconds, ...)
  hs.alert.closeSpecific(prev_alert, 0)
  prev_alert = hs.alert.showWithImage(str, image, style, screen, seconds, ...)
end

return Alert