local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'

local theme = require 'user.lua.ui.mariana'

-- local log = require('user.lua.util.logger').new('ui-color', 'info')


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


local colors = {
  lightgrey  = theme.chateau,
  gray       = theme.outerspace,
  darkgrey   = theme.bunker,
  red        = theme.carnation,
  orange     = theme.persimmon,
  yellow     = theme.yorange,
  green      = theme.deyork,
  teal       = theme.pelorous,
  blue       = theme.danube,
  violet     = theme.viola,
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
function colors.lists()
  return hs.drawing.color.lists() --[[@as Dict<ColorList>]]
end


--
-- Retrieves a list of colors from the available pre-defined hammerspoon color list
--
---@param listname string Name of the color list
---@return ColorList
function colors.list(listname)
  return hs.drawing.color.colorsFor(listname) --[[@as ColorList]]
end


--
-- Retrieves a hs.color from one of the predefined hammerspoon color list
--
---@param listname string
---@param color string
---@return HS.Color
function colors.from(listname, color)
  local tabl = tables(colors.list(listname) or {})
  
  if tabl:has(color) then
    return tabl:get(color)
  end

  error(strings.fmt("No color %q in list %q", color, listname))
end


--
-- Retrieves a hs.color from the pre-defined System color list
--
---@param color string
---@return HS.Color
function colors.system(color)
  local systemColors = hs.drawing.color.colorsFor("System")
  ---@cast systemColors -nil
  return params.default(systemColors[color], colors.black)
end


--
-- Tries to create a usable HS.Color from the input
--   - string -> assume a hex string, returns a HS.HexColor
--   - table  -> assumes table is a valid HS.Color, returns the table
--   - other  -> returns a default color (black)
--
---@param input any
---@return HS.Color
function colors.ensure_color(input)
  if types.isString(input) then
    return { hex = input }
  end

  if types.isTable(input) then
    return input
  end

  return colors.black
end


---@deprecated
colors.do_color = colors.ensure_color


colors.disabled = colors.system("disabledControlTextColor")

return colors
