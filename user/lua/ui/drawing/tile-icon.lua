local tables  = require 'user.lua.lib.table'
local bg      = require 'user.lua.ui.drawing.styles-background'
local rounded = require 'user.lua.ui.drawing.styles-rounded'
local border  = require 'user.lua.ui.drawing.styles-border'
local pad     = require 'user.lua.ui.drawing.styles-padding'
local colors  = require 'user.lua.ui.color'

local function elem(id, type, ...)
  return tables.merge({ id = id, type = type }, table.unpack({...}))
end

local function rect(id, ...)
  return elem(id, "rectangle", table.unpack({...}))
end

local width = function(val) return { frame = { w = val } } end
local height = function(val) return { frame = { h = val } } end
local x_pos = function(val) return { frame = { x = val } } end
local y_pos = function(val) return { frame = { y = val } } end

local fg_color = colors.blue

local tile_active = tables.merge({},
  border(fg_color),
  border.md,
  rounded.sm,
  rounded.sm,
  pad.none,
  bg(fg_color),
  width("44%"),
  height("44%")
)

local tile_inactive = tables.merge({},
  tile_active,
  bg.none,
  border.dashed({ 4, 8 })
)



return {
  -- filename = '/Users/ryan/Desktop/four-squares.png',
  debug = true,
  frame = { w = 256, h = 256 },
  elements = {
    rect("panel-frame", rounded.none, border.none, bg(colors.transparent)),
    rect('box-A1', tile_active, x_pos("4%"), y_pos("4%")),
    rect('box-B1', tile_inactive, x_pos("4%"), y_pos("52%")),
    rect('box-A2', tile_inactive, x_pos("52%"), y_pos("4%")),
    rect('box-B2', tile_inactive, x_pos("52%"), y_pos("52%")),
  }
}