local colors = require 'user.lua.ui.color'

local _strokeWidth = function(width)
  width = width or 0.0

  return { 
    strokeWidth = width,
    -- strokeCapStyle = "butt",
    strokeCapStyle = "round",
    -- strokeCapStyle = "square"
  }
end

local _strokeColor = function(color)
  color = color or colors.black

  return { 
    strokeColor = colors.blue
  }
end


--
-- Default {}. Specifies an array of numbers specifying a dash pattern for stroked lines
-- when an element's action attribute is set to stroke or strokeAndFill. The numbers in
-- the array alternate with...
--   1. the first element specifying a dash length in points
--   2. the second specifying a gap length in points
--   3. the third a dash length, etc. 
-- The array repeats to fully stroke the element. Ignored for the canvas, image, and text types.
--
---@param pattern number[]
---@return { strokeDashPattern: number[] }
local _strokeDashPattern = function(pattern)
  -- pattern = pattern or {}

  return { 
    strokeDashPattern = pattern
  }
end

local border = setmetatable({
  none = _strokeWidth(0),
  sm   = _strokeWidth(2),
  md   = _strokeWidth(4),
  lg   = _strokeWidth(8),
  dashed = _strokeDashPattern
}, {
  __call = function(tabl, val) return _strokeColor(val) end
})

return border