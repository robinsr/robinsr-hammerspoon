local symbols = require 'user.lua.ui.symbols'
local colors  = require 'user.lua.ui.color'
local util    = require 'user.lua.util'

local log = util.log('UI:init', 'info')

-- Preconfigured SF Symbol code points, see symbols.lua for more
---@enum
local icons = {
  kitty      = symbols.toIcon("cat", 12, colors.black),
  info       = symbols.toIcon("info.circle", 13, colors.disabled),
  tag        = symbols.toIcon("tag", 13, colors.black),
  reload     = symbols.toIcon("arrow.counterclockwise", 13, colors.black),
  term       = symbols.toIcon("terminal", 13, colors.black),
  code       = symbols.toIcon("htmltag", 14, colors.black),
  command    = symbols.toIcon("command", 14, colors.black),
  running    = symbols.toIcon("circle.fill", 14, colors.deyork),
  stopped    = symbols.toIcon("circle.fill", 14, colors.carnation),
  unknown    = symbols.toIcon("circle.fill", 14, colors.chateau),
  float      = symbols.toIcon("macwindow.on.rectangle", 14, colors.black),
  spaceLeft  = symbols.toIcon("rectangle.righthalf.inset.filled.arrow.right", 72, colors.white),
  spaceRight = symbols.toIcon("rectangle.lefthalf.inset.filled.arrow.left", 72, colors.white),
  default    = symbols.toIcon("tornado", 72, colors.white),
}

local UI = {
  btn = {
    confirm = "OK",
    cancel = "Cancel",
  },
  alert = {
    window = {
      atScreenEdge = 0,
      radius = 6,
      padding = 20,
    },
    icon = {
      color = {
        hex = colors.white,
      },
      backgroundColor = {
        hex = colors.viola,
        alpha = 0.15,
      },
    },
    ts = {
      normal = 1.8,
      fast = 0.4,
      flash = 0.25,
    },
  },
  icons = icons,
  colors = colors,
  console = {},
}


local icon_font = {
  size = 12,
  name = 'SF Pro',
  color = colors.white,
}


function UI.sf_symbol(code, size, attrs, asText)
  local defSize = util.default(size, icon_font.size)
  return symbols.toIcon(code, defSize, colors.white, asText)
end

return UI
