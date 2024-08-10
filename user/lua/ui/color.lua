local desktop = require 'user.lua.interface.desktop'
local lists   = require 'user.lua.lib.list'
local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'

local base     = require 'user.lua.ui.theme.colorbase'
local marTheme = require 'user.lua.ui.theme.mariana'
local icoTheme = require 'user.lua.ui.theme.icon'

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
---@field list string
---@field name string

---@class HS.HexColor
---@field hex string
---@field alpha number

---@alias HS.Color HS.RGBColor|HS.HSBColor|HS.GrayscaleColor|HS.SystemColor|HS.HexColor

---@alias ColorList Dict<HS.Color>

---@alias ks.theme.color { name?: string } | HS.Color


---@class ks.theme
---@field name       string
---@field black      HS.Color
---@field blue       HS.Color
---@field darkblue   HS.Color
---@field darkgrey   HS.Color
---@field disabled   HS.Color
---@field gray       HS.Color
---@field green      HS.Color
---@field lightgrey  HS.Color
---@field orange     HS.Color
---@field red        HS.Color
---@field teal       HS.Color
---@field violet     HS.Color
---@field yellow     HS.Color
---@field white      HS.Color



local colors = {
  lightgrey  = marTheme.lightgrey,
  gray       = marTheme.gray,
  darkgrey   = marTheme.darkgrey,
  red        = marTheme.red,
  orange     = marTheme.orange,
  yellow     = marTheme.yellow,
  green      = marTheme.green,
  teal       = marTheme.teal,
  blue       = marTheme.blue,
  violet     = marTheme.violet,
}

colors.black = base.black
colors.white = base.white
colors.disabled = base.disabled


---@enum ks.colors.variants
colors.variants = {
  c001 = 'text-content',
  c002 = 'bg-content',
  c003 = 'fg',
  c004 = 'bg',
  c005 = 'success',
  c006 = 'danger',
}


---@param variant ks.colors.variants
---@return HS.Color
function colors.get(variant)
  local mode = desktop.darkMode() and 'dark' or 'light'

  local configs = lists({
    { 'text-content', 'dark',  base.white },
    { 'text-content', 'light', base.black },
    { 'success',      'dark',  icoTheme.green },
    { 'success',      'light', icoTheme.green },
    { 'danger',       'dark',  icoTheme.red },
    { 'danger',       'light', icoTheme.red },
  })

  local matched = configs
    :filter(function(conf) return conf[2] == mode end)
    :first(function(conf) return conf[1] == variant end)

  if matched then
    return matched[3]
  end

  return colors.black
end


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
  return systemColors[color] or colors.black
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


colors.disabled = colors.system("disabledControlTextColor")

return colors
