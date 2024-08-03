local images  = require 'user.lua.ui.image'
local tables  = require 'user.lua.lib.table'
local bg      = require 'user.lua.ui.drawing.styles-background'
local rounded = require 'user.lua.ui.drawing.styles-rounded'
local border  = require 'user.lua.ui.drawing.styles-border'
local pad     = require 'user.lua.ui.drawing.styles-padding'
local colors  = require 'user.lua.ui.color'

local fg_color = colors.black
local bg_color = colors.white
local bg_trans = colors.transparent

local drawing = require 'user.lua.ui.drawing.drawlib'

local dl = drawing
local el = drawing.el
local props = drawing.props


local space_object = tables.merge({},
  border(fg_color),
  rounded.sm,
  border.width(8),
  border.dash({ 8, 16 }),
  border.cap('square'),
  bg(bg_trans),
  props.width("100%"),
  props.height("90%")
)


local window_frame = tables.merge({},
  props.width("70%"),
  props.x_pos("15%"),
  props.height("60%"),
  props.y_pos("20%")
)

local window_object = tables.merge({},
  window_frame,
  border.color(fg_color),
  border.sm,
  rounded.sm,
  bg(bg_trans)
)

local window_bar = tables.merge({}, 
  window_frame, 
  border.none,
  bg(fg_color),
  props.height('6%')
)


local arrow_img = images.fromPath('@/resources/images/arrow-right-100x100.template.png', { w=100, h=100 })

local arrow_object = tables.merge({}, 
  window_frame, 
  props.y_pos("22%"),
  {
    imageScaling = "scaleProportionally",
    imageAlpha = 1.0,
    image = images.rotate(arrow_img, 180),
    -- image = arrow_img,
  }
)


local filename = 'next-space.template.png'

return {
  -- filename = '/Users/ryan/Desktop/' .. filename,
  -- filename = '@/resources/images/' .. filename,
  debug = true,
  export = false, -- save the json
  frame = { w = 256, h = 256 },
  elements = {
    el.rect("panel-frame", { action = "build" }),
    el.clipRect('clip-for-window', window_object),
    el.rect('from-space', space_object, props.x_pos("-60%"), props.y_pos("5%")),
    el.rect('to-space', space_object, props.x_pos("65%"), props.y_pos("5%")),
    el.reset(),
    el.rect('moving-window', window_object),
    el.rect('window-bar', window_bar),
    el.img('arrow', arrow_object)
  }

}