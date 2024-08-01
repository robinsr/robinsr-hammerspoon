local tables  = require 'user.lua.lib.table'
local colors  = require 'user.lua.ui.color'
local images  = require 'user.lua.ui.image'
local bg      = require 'user.lua.ui.drawing.styles-background'
local rounded = require 'user.lua.ui.drawing.styles-rounded'
local border  = require 'user.lua.ui.drawing.styles-border'
local pad     = require 'user.lua.ui.drawing.styles-padding'


local elements = {}

local function elem(id, type, ...)
  return tables.merge({ id = id, type = type }, table.unpack({...}))
end

function elements.rect(id, ...)
  return elem(id, "rectangle", table.unpack({...}))
end

function elements.text(id, content,  ...)
  return elem(id, "text", tables.merge({ text = content }, table.unpack({...})))
end

function elements.img(id, ...)
  return elem(id, "image", table.unpack({...}))
end

function elements.clipRect(id, ...)
  local clip_props = {
    action = 'clip',
    reversePath = true
  }

  return elem(id, "rectangle", tables.merge(clip_props, table.unpack({...})))
end

function elements.reset()
  return { type = 'resetClip' }
end


local props = {}


function props.width(val)
  return { frame = { w = val } }
end

function props.height(val)
  return { frame = { h = val } }
end

function props.x_pos(val)
  return { frame = { x = val } }
end

function props.y_pos(val)
  return { frame = { y = val } }
end


return {
  el = elements,
  props = props,
  dim = {
    w = props.width,
    h = props.height,
  },
  pos = {
    x = props.x_pos,
    y = props.y_pos,
  }
}