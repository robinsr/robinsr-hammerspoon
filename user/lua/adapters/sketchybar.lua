local class       = require 'middleclass'
local BrewService = require 'user.lua.adapters.base.brew-service'
local shell       = require 'user.lua.interface.shell'
local util        = require 'user.lua.util'

local wrap = shell.wrap
local log = util.log('yabai.lua', 'debug')


local SketchyBar = class('SketchyBar', BrewService)

function SketchyBar:initialize()
  BrewService.initialize(self, 'sketchybar')
end

SketchyBar.update = wrap("sketchybar --update")
SketchyBar.reload = wrap("sketchybar --reload")
SketchyBar.trigger = {
  onNewLabel = wrap("sketchybar --trigger ya_new_label YA_SPACE_ID=%d YA_LABEL='%s'"),
  onLayoutChange = wrap("sketchybar --trigger ya_layout_change YA_SPACE_ID=$d YA_LAYOUT=$s"),
}
SketchyBar.onLoad = wrap("sketchybar --set front_app label='%s'")

local sketchybar = SketchyBar:new()

log.df('SketchyBar status: "%s"', sketchybar:status()) 

return sketchybar