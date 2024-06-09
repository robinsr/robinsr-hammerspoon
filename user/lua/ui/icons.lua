local tables  = require 'user.lua.lib.table'
local colors  = require 'user.lua.ui.color'
local symbols = require 'user.lua.ui.symbols'
local logr    = require 'user.lua.util.logger'

local log = logr.new('ui-icons', 'info')


local icon_aliases = tables{
  default    = "cat",
  kitty      = "cat",
  info       = "info.circle",
  tag        = "tag",
  reload     = "arrow.counterclockwise",
  term       = "terminal",
  code       = "htmltag",
  command    = "command",
  running    = "circle.fill",
  stopped    = "circle.fill",
  unknown    = "circle.fill",
  float      = "macwindow.on.rectangle",
  spaceLeft  = "rectangle.righthalf.inset.filled.arrow.right",
  spaceRight = "rectangle.lefthalf.inset.filled.arrow.left",
  copy       = "doc.on.doc",
}

--
-- Preconfigured SF Symbol code points, see symbols.lua for more
--
---@module 'ui.icons'
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


--
-- Returns template hs.image to use in menubars
--
---@param icon string
---@param hscolor? HS.Color
---@return hs.image
function icons.menuIcon(icon, hscolor)

  local cp = 'questionmark'

  if icon_aliases:has(icon) then
    cp = icon_aliases[icon]
  end

  if symbols:has(icon) then
    cp = symbols[icon]
  end

  local img = symbols.toIcon(cp, 12, hscolor or colors.black)
    
  if img == nil then
    error('Could not create icon image for '..cp)
  end

  img:setSize({ w = 16, h = 16 })
  img:template(true)

  return img
end

return icons