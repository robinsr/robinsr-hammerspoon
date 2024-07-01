local params  = require 'user.lua.lib.params'
local paths   = require 'user.lua.lib.path'
local symbols = require 'user.lua.ui.symbols'
local colors  = require 'user.lua.ui.color'


local img = {}


--
-- Creates a hs.image from path, width, and height (defaults to 100x100)
--
---@param path string
---@param width integer
---@param height integer
---@return hs.image
function img.from_path(path, width, height)
  params.assert.string(path, 1)
  width = params.default(width, 100)
  height = params.default(height, 100)

  local expath = paths.expand(path)
  local img

  if paths.exists(expath) then
    img = hs.image.imageFromPath(expath) --[[@as hs.image]]
  else
    img = symbols.toIcon('not_found', 12, colors.gray)
  end
  
  img:size({ w = width, h = height })

  return img
end


--
-- Creates a hs.image from icon name, width, and height (defaults to 100x100)
--
---@param icon string Name of an icon
---@param size? integer Size of image generated, only single int as image will be square
---@param color? HS.Color
---@return hs.image
function img.from_icon(icon, size, color)
  params.assert.number(symbols.get_codepoint('questionmark.app.dashed'), 999)

  params.assert.string(icon, 1)
  size = params.default(size, 12)
  color = params.default(color, colors.black)

  local codepoint

  if symbols.has_codepoint(icon) then
    codepoint = symbols.get_codepoint(icon)
  else
    codepoint = symbols.get_codepoint('questionmark.app.dashed')
  end

  local img = img.from_codepoint(codepoint, 12, color)
    
  if img == nil then
    error('Could not create icon image for '..codepoint)
  end

  img:setSize({ w = size, h = size })
  img:template(true)

  return img
end


--
-- Creates a usable HS Image from a SF-Symbols codepoint; basically screenshots
-- a single glyph unsing SF-Pro as the font, at a particular font-size
--
---@param codepoint integer Either a string that is a valid key in the Symbols.all table, or the unicode codepoint corresponding to a SF Symbol (integer)
---@param size integer Desired size of image (literally the font-size to apply to icon)
---@param color? HS.Color
---@return hs.image # Image to use
function img.from_codepoint(codepoint, size, color)
  params.assert.number(codepoint)
  size = params.default(size, 12)

  local text_style = {
    font = {
      size = size,
      name = 'SF Pro',
    },
    color = colors.ensure_color(color)
  }

  local canvas = hs.canvas.new({ x = 0, y = 0, h = 0, w = 0 }) --[[@as hs.canvas]]

  ---@cast codepoint integer
  local char = hs.styledtext.new(utf8.char(codepoint), text_style)

  canvas:size(canvas:minimumTextSize(char))
  canvas[#canvas + 1] = {
      type = "text",
      text = char
  }

  return canvas:imageFromCanvas()
end


return img