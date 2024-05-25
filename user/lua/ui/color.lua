local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local logr    = require 'user.lua.util.logger'

local log = logr.new('ui:color', 'info')


---@class HS.RGBColor
---@field red number
---@field green number
---@field blue number
---@field alpha number

---@class HS.HSBColor
---@field hue number
---@field saturation number
---@field brightness number
---@field alpha number

---@class HS.GrayscaleColor
---@field white number
---@field alpha number

---@class HS.SystemColor
---@field list number
---@field name number

---@class HS.HexColor
---@field hex string
---@field alpha number

---@alias HS.Color HS.RGBColor|HS.HSBColor|HS.GrayscaleColor|HS.SystemColor|HS.HexColor

---@alias ColorList Dict<HS.Color>


---@enum KS.Colors
local colors = {
  chateau    = '#A5ACBA',
  bunker     = '#0C1017',
  outerspace = '#2E3842',
  carnation  = '#FE4D63',
  persimmon  = '#FF6F51',
  yorange    = '#FFAA4B',
  deyork     = '#8BCA91',
  pelorous   = '#39B7B5',
  danube     = '#589ACF',
  viola      = '#CF90C8',
}

colors.black = {
  red   = 0.0,
  green = 0.0,
  blue  = 0.0,
  alpha = 1.0,
}

colors.white = {
  red   = 1.0,
  green = 1.0,
  blue  = 1.0,
  alpha = 1.0,
}

colors.transparent = {
  red   = 1.0,
  green = 1.0,
  blue  = 1.0,
  alpha = 0.0,
}


--
-- Gets all system color lists
--
---@return Dict<ColorList> A table containing all color lists
function colors.getAllLists()
  return hs.drawing.color.lists() --[[@as Dict<ColorList>]]
end


--
-- Gets a specific system color list
--
---@param name string Name of the color list
---@return ColorList
function colors.getListColors(name)
  return hs.drawing.color.colorsFor(name) --[[@as ColorList]]
end



function colors.getSystemColor(name)
  local systemColors = hs.drawing.color.colorsFor("System")
  ---@cast systemColors -nil
  return params.default(systemColors[name], { hex = '#000000' })
end


colors.disabled = colors.getSystemColor("disabledControlTextColor")

return colors
