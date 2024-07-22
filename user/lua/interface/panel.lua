local hsalert   = require 'hs.alert'
local hscanvas  = require 'hs.canvas'
local alert     = require 'user.lua.interface.alert'
local desk      = require 'user.lua.interface.desktop'
local lists     = require 'user.lua.lib.list'
local paths     = require 'user.lua.lib.path'
local strings   = require 'user.lua.lib.string'
local tables    = require 'user.lua.lib.table'
local types     = require 'user.lua.lib.typecheck'
local colors    = require 'user.lua.ui.color'
local json      = require 'user.lua.util.json'

local logr      = require 'user.lua.util.logger'



local log = logr.new('panel', 'debug')

local keydown = hs.eventtap.event.types.keyDown


local close_panel = function(on_close)
  local keydown_listener = nil

  keydown_listener = hs.eventtap.new({ keydown }, function(evt)
    ---@cast evt hs.eventtap.event
    ---@cast keydown_listener hs.eventtap

    if evt:getKeyCode() == hs.keycodes.map.escape then
      on_close(evt)
      keydown_listener:stop()
      return true
    end

    return false
  end):start()

  return keydown_listener
end


local function getTestText()
  return KittySupreme.commands:map(function(cmd) 
    ---@cast cmd Command
    return strings.join({ cmd.id, cmd:hasHotkey() and cmd.hotkey:label() or 'none' }, ': ')
  end):join('\n')
end

local FADE_TIME = alert.timing.FAST

local ALERT_ATTRS = tables.merge({}, tables.pick(hsalert.defaultStyle, { 
  "fillColor", "strokeColor", "strokeWidth", "textColor", "textFont"
}), {
  textSize = 16,
})


local function elem(id, type, ...)
  return tables.merge({ id = id, type = type }, table.unpack({...}))
end


local P = {}

---@type hs.canvas|nil
P.current = nil


function P.testpanel()

  if types.notNil(P.current) then
    P.current = P.current:delete(FADE_TIME)
    return
  end

  local image_data = loadfile(paths.mod('user.lua.ui.drawing.tile-icon'))()

  log.f('image_data json: %s', json.encode(image_data))

  -- local panel_dimensions = desk.getScreen('active'):frame():scale({ w = 0.50, h = 0.90 })
  local screen_frame = desk.getScreen('active'):frame()
  
  local panel_dimensions = { 
    w = image_data.frame.w,
    h = image_data.frame.h,
    x = (screen_frame.w - image_data.frame.w) / 2,
    y = (screen_frame.h - image_data.frame.h) / 2,
  }

  ---@type hs.canvas
  local panel = hscanvas.new(panel_dimensions)
  
  -- panel:insertElement(elem("panel-frame", "rectangle", ALERT_ATTRS, {
  --   roundedRectRadii = { xRadius = 10.0, yRadius = 10.0 }
  -- }))

  for i,elem in ipairs(image_data.elements) do
    panel:insertElement(elem)
  end

  if image_data.debug then
    log.f("image data: %s", hs.inspect(image_data, { depth = 4 }))
  end

  if image_data.filename then
    panel:imageFromCanvas():saveToFile(image_data.filename, 'png')
  end


  P.current = panel:show(FADE_TIME)

  close_panel(function()
    panel:delete(FADE_TIME)
    P.current = nil
  end)

  -- local real_colors = lists(tables(colors):values())
  -- local elems = lists(image_data.elements)

  -- local counter = 0
  -- hs.timer.doEvery(1, function()
  --   counter = counter + 1
  --   local elem = elems:at(counter)
  --   local index = elems:indexOf(elem)

  --   if elem ~= nil then
  --     panel:elementAttribute(index, "fillColor", real_colors:at(counter))
  --   end
  -- end)
end



P.cmds = {
  {
    id = "KS.Experiments.Panel",
    title = "Canvas Experiment",
    mods = "btms",
    key = "F",
    exec = function(cmd, ctx)
      P.testpanel()
    end
  }
}


return P