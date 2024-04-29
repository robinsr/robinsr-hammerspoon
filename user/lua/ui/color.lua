local util = require 'user.lua.util'

local log = util.log('ui:color', 'info')

local colorlists = hs.drawing.color.lists()

---@cast colorlists -nil
local colorlistkeys = util.keys(colorlists)

log.df("Available color lists: %s", hs.inspect(colorlistkeys))

local systemColors = hs.drawing.color.colorsFor("System")

local function getSystemColor(color_name)
  ---@cast systemColors -nil
  return util.default(systemColors[color_name], { hex = '#000000' })
end


local colors = {
  black      = '#000000',
  white      = '#FFFFFF',
  chateau    = '#A5ACBA',
  bunker     = '#0C1017',
  outerspace = '#2E3842',
  carnation  = '#FE4D63',
  persimmon  = '#FF6F51',
  yorange    = '#FFAA4B',
  deyork     = '#8BCA91',
  pelorous   = '#39B7B5',
  danube     = '#589ACF',
  viola      = '#CF90C8',
  -- todo; what is the hex for disabled text in menubar item?
  disabled   = getSystemColor("disabledControlTextColor"),
}

return colors
