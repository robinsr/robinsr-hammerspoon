-- local params = require 'user.lua.lib.params'
local colors = require 'user.lua.ui.color'

local _fillColor = function(color)
  color = color or colors.transparent

  return { 
    fillColor = color
  }
end

---@class HS.FillColor
---@field fillColor HS.Color

---@overload fun(color: HS.Color): HS.FillColor
local background = setmetatable({
  none  = _fillColor(colors.transparent),
  white = _fillColor(colors.white),
}, {
  __call = function(tabl, color) return _fillColor(color) end
  -- __call = params.sub(_fillColor, {})
})

return background