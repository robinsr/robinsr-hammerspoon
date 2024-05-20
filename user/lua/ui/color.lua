local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local logr    = require 'user.lua.util.logger'


local log = logr.new('ui:color', 'info')

local colorlists = hs.drawing.color.lists()

log.i(hs.inspect(tables, { metatables = true }))

---@cast colorlists -nil
local colorlistkeys = tables.get(colorlists)

log.df("Available color lists: %s", strings.join(colorlistkeys, ', '))

local systemColors = hs.drawing.color.colorsFor("System")

local function getSystemColor(color_name)
  ---@cast systemColors -nil
  return params.default(systemColors[color_name], { hex = '#000000' })
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
