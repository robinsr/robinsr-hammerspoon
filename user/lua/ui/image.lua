local params  = require 'user.lua.lib.params'
local paths   = require 'user.lua.lib.path'
local symbols = require 'user.lua.ui.symbols'
local colors  = require 'user.lua.ui.color'

local log = require('user.lua.util.logger').new('ui-image', 'info')


local img = {}


--
-- Creates a hs.image from path, width, and height (defaults to 100x100)
--
---@param path string
---@param width? integer
---@param height? integer
---@return hs.image
function img.from_path(path, width, height)
  params.assert.string(path, 1)
  
  width = width or 100
  height = height or 100
  
  local expath = paths.expand(path)
  local image

  if paths.exists(expath) then
    image = hs.image.imageFromPath(expath) --[[@as hs.image]]
    image = img.resize(image, { w = width, h = height })

    if paths.basename(path):match('%.template%.') then
      image:template(true)
    end
  else
    image = img.from_icon('not_found', math.min(width, height), colors.gray)
  end

  -- return 
  return image --[[@as hs.image]]
end


--
-- Creates base64 encoded URL string from a image file, width, and height (defaults to 100x100)
--
---@param path string
---@param width integer
---@param height integer
---@return string
function img.encode_from_path(path, width, height)
  params.assert.string(path, 1)
  width = params.default(width, 100)
  height = params.default(height, 100)

  local image = img.from_path(path, width, height)
  return image:encodeAsURLString() or ''
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

  local icon = img.from_codepoint(codepoint, size, color)
    
  if icon == nil then
    error('Could not create icon image for '..codepoint)
  end

  icon:setSize({ w = size, h = size })
  icon:template(true)

  return icon
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


--
--
--
function img.from_data(image_data)
  local canvas_dimensions = { 
    w = image_data.frame.w,
    h = image_data.frame.h,
    x = 0,
    y = 0,
  }

  ---@type hs.canvas
  local canvas = hs.canvas.new(canvas_dimensions)  --[[@as hs.canvas]]

  for i,elem in ipairs(image_data.elements) do
    canvas:insertElement(elem)
  end

  if image_data.debug then
    log.f("image data: %s", hs.inspect(image_data, { depth = 4 }))
  end

  if image_data.filename then
    -- canvas:imageFromCanvas():saveToFile(image_data.filename, 'png')
  end

  return canvas:imageFromCanvas()
end



local counter = 0


--
--
--
---@param image hs.image
---@param dimensions hs.geometry
function img.resize(image, dimensions)

  local height = dimensions.h
  local width = dimensions.w

  local filename = image:name()
  local current = image:size()

  log.df("Dimensions [%s]: %s", filename, hs.inspect(current))

  local resized = image:size({ w = width, h = height }) --[[@as hs.image]]

  -- counter = counter + 1
  -- local test_name = ('~/Desktop/test-resize-%d-%d.png'):format(os.time(), counter)
  -- resized:saveToFile(paths.expand(test_name), 'png')

  return resized
end


return img