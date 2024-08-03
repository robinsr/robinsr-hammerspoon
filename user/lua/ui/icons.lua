local image   = require 'user.lua.ui.image'
local tables  = require 'user.lua.lib.table'
local colors  = require 'user.lua.ui.color'
local symbols = require 'user.lua.ui.symbols'


---@class ks.icons
local Ico = {}

Ico.replace = utf8.char(0xFFFD) -- "�"

--
-- Preconfigured SF Symbol code points, see symbols.lua for more
--
---@type Table : { [string]: hs.image }
Ico.static = tables{
  kitty      = image.fromIcon("cat", 12, colors.black),
  info       = image.fromIcon("info.circle", 13, colors.disabled),
  tag        = image.fromIcon("tag", 13, colors.black),
  reload     = image.fromIcon("arrow.counterclockwise", 13, colors.black),
  term       = image.fromIcon("terminal", 13, colors.black),
  code       = image.fromIcon("htmltag", 14, colors.black),
  command    = image.fromIcon("command", 14, colors.black),
  running    = image.fromIcon("circle.fill", 14, colors.deyork),
  stopped    = image.fromIcon("circle.fill", 14, colors.carnation),
  unknown    = image.fromIcon("circle.fill", 14, colors.chateau),
  float      = image.fromIcon("macwindow.on.rectangle", 14, colors.black),
  spaceLeft  = image.fromIcon("rectangle.righthalf.inset.filled.arrow.right", 72, colors.white),
  spaceRight = image.fromIcon("rectangle.lefthalf.inset.filled.arrow.left", 72, colors.white),
  default    = image.fromIcon("tornado", 72, colors.white),
}

Ico.layout = {
  float = "macwindow.on.rectangle",
  stack = "square.3.layers.3d.top.filled",
  bsp   = "rectangle.split.2x2.fill",
  cols  = "rectangle.split.3x1.fill",
}


return Ico