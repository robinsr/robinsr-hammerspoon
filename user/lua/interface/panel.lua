local hsalert   = require 'hs.alert'
local hscanvas  = require 'hs.canvas'
local alert     = require 'user.lua.interface.alert'
local desk      = require 'user.lua.interface.desktop'
local strings   = require 'user.lua.lib.string'
local tables    = require 'user.lua.lib.table'
local types     = require 'user.lua.lib.typecheck'
local colors    = require 'user.lua.ui.color'
local logr      = require 'user.lua.util.logger'

local log = logr.new('panel', 'debug')


local function getTestText()
  return KittySupreme.commands:map(function(cmd) 
    ---@cast cmd Command
    return strings.join({ cmd.id, cmd:hasHotkey() and cmd:getHotkey():label() or 'none' }, ': ')
  end):join('\n')
end

local FADE_TIME = alert.timing.FAST

local ALERT_ATTRS = tables.merge({}, tables.pick(hsalert.defaultStyle, { 
  "fillColor", "strokeColor", "strokeWidth", "textColor", "textFont"
}), {
  textSize = 16,
})


local function elem(id, type, ...)
  local args = table.pack(...)

  local attrs = {}

  for i,v in ipairs(args) do
    attrs = tables.merge(attrs, v)
  end

  return tables.merge(attrs, { id = id, type = type })
end


local P = {}

---@type hs.canvas|nil
P.current = nil


function P.testpanel()

  if types.notNil(P.current) then
    P.current = P.current:delete(FADE_TIME)
    return
  end

  local panel_dimensions = desk.getScreen('active'):frame():scale({ w = 0.50, h = 0.90 })

  ---@type hs.canvas
  local panel = hscanvas.new(panel_dimensions)
  
  panel:insertElement(elem("panel-frame", "rectangle", ALERT_ATTRS, {
    roundedRectRadii = { xRadius = 10.0, yRadius = 10.0 }
  }))

  panel:insertElement(elem("test-text", "text", {
    padding = 10.0,
    text = getTestText(),
    textColor = colors.white,
    textSize = 16,
  }))

  P.current = panel:show(FADE_TIME)
end



P.cmds = {
  {
    id = "KS.Experiments.Panel",
    title = "Canvas Experiment",
    -- mods = "btms",
    -- key = "F",
    exec = function(cmd, ctx)
      P.testpanel()
    end
  }
}


return P