local image   = require 'user.lua.ui.image'
local tables  = require 'user.lua.lib.table'
local colors  = require 'user.lua.ui.color'
local symbols = require 'user.lua.ui.symbols'


--
-- Preconfigured SF Symbol code points, see symbols.lua for more
--
---@type Table : { [string]: hs.image }
local static_icons = tables{
  kitty      = image.from_icon("cat", 12, colors.black),
  info       = image.from_icon("info.circle", 13, colors.disabled),
  tag        = image.from_icon("tag", 13, colors.black),
  reload     = image.from_icon("arrow.counterclockwise", 13, colors.black),
  term       = image.from_icon("terminal", 13, colors.black),
  code       = image.from_icon("htmltag", 14, colors.black),
  command    = image.from_icon("command", 14, colors.black),
  running    = image.from_icon("circle.fill", 14, colors.deyork),
  stopped    = image.from_icon("circle.fill", 14, colors.carnation),
  unknown    = image.from_icon("circle.fill", 14, colors.chateau),
  float      = image.from_icon("macwindow.on.rectangle", 14, colors.black),
  spaceLeft  = image.from_icon("rectangle.righthalf.inset.filled.arrow.right", 72, colors.white),
  spaceRight = image.from_icon("rectangle.lefthalf.inset.filled.arrow.left", 72, colors.white),
  default    = image.from_icon("tornado", 72, colors.white),
}


---@class ks.icons
local Ico = {
  static = static_icons,
  replace = utf8.char(0xFFFD),
}

return Ico