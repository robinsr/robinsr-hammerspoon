local sh      = require 'user.lua.adapters.shell'
local paths   = require 'user.lua.lib.path'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local symbols = require 'user.lua.ui.symbols'
local colors  = require 'user.lua.ui.color'
local logr    = require 'user.lua.util.logger' 


local log = logr.new('ui-image', 'info')


---@class HS.Canvas.Matrix
---@field append      fun(matrix: any, ...: any): HS.Canvas.Matrix
---@field identity    fun(): HS.Canvas.Matrix
---@field invert      fun(): HS.Canvas.Matrix
---@field prepend     fun(matrix: any, ...: any): HS.Canvas.Matrix
---@field rotate      fun(angle: any, ...: any): HS.Canvas.Matrix
---@field scale       fun(xFactor: any, yFactor: any, ...: any): HS.Canvas.Matrix
---@field shear       fun(xFactor: any, yFactor: any, ...: any): HS.Canvas.Matrix
---@field translate   fun(x: any, y: any, ...: any): HS.Canvas.Matrix



-- -@class HS.Image : hs.image
-- -@field bitmapRepresentation  fun(size, gray): any
-- -@field colorAt               fun(point): any
-- -@field copy                  fun(): any
-- -@field croppedCopy           fun(rectangle): any
-- -@field encodeAsURLString     fun(scale, type): any
-- -@field getExifFromPath       fun(path: string): any
-- -@field iconForFile           fun(file): any
-- -@field iconForFileType       fun(fileType): any
-- -@field imageFromAppBundle    fun(bundleID): hs.image
-- -@field imageFromASCII        fun(ascii, context): hs.image
-- -@field imageFromMediaFile    fun(file): hs.image
-- -@field imageFromName         fun(name: string): hs.image
-- -@field imageFromPath         fun(path: string): hs.image
-- -@field imageFromURL          fun(url: string, callbackFn): hs.image
-- -@field name                  fun(name): any
-- -@field saveToFile            fun(filename, scale, filetype): any
-- -@field setName               fun(Name): any
-- -@field setSize               fun(size, absolute): hs.image  - Returns a **copy** of the image resized to the height and width specified in the any
-- -@field size                  fun(): any
-- -@field template              fun(state: boolean): hs.image
-- -@field toASCII               fun(width, height): hs.image



---@class ks.images
local imgm = {}


--
-- Creates a hs.image from path, width, and height (defaults to 100x100)
--
---@param path string
---@param width? integer
---@param height? integer
---@return hs.image
function imgm.from_path(path, width, height)
  params.assert.string(path, 1)
  
  width = width or 100
  height = height or 100
  
  local expath = paths.expand(path)
  local isTmpl = paths.matches(path, '%.template%.')

  if not paths.exists(expath) then
    return imgm.from_icon('not_found', math.min(width, height), colors.gray)
  end

  local image = hs.image.imageFromPath(expath) --[[@as hs.image]]
  
  image = imgm.resize(image, { w = width, h = height })
  iamge = image:template(isTmpl)
  
  return image
end


--
-- Creates a hs.image from icon name, width, and height (defaults to 100x100)
--
---@param icon   string   - Name of an icon
---@param size?  integer  - Optional size, defaults to 12; used as both width and height
---@param color? HS.Color - Optional color, defaults to black
---@return hs.image
function imgm.from_icon(icon, size, color)
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

  local icon = imgm.from_codepoint(codepoint, size, color)
    
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
-- `codepoint` can be either a string that is a valid key in the Symbols.all table,
-- or a unicode codepoint hex number corresponding to a SF Symbol
--
---@param codepoint integer|string  - Codepoint number or key in symbols table
---@param size?     integer         - Defaults to 12
---@param color?    HS.Color        - Defaults to black
---@return hs.image
function imgm.from_codepoint(codepoint, size, color)
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

  return canvas:imageFromCanvas() --[[@as hs.image]]
end


--
-- WIP!
--
---@param image_data table
function imgm.from_data(image_data)
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

  return canvas:imageFromCanvas() --[[@as hs.image]]
end


--
-- Add ability to resize image
--
---@param image hs.image
---@param dimensions hs.geometry
---@return hs.image
function imgm.resize(image, dimensions)

  local height = dimensions.h
  local width = dimensions.w

  log.df("Dimensions [%s]: %s", image:name(), hs.inspect(image:size()))

  local resized = image:size({ w = width, h = height }) --[[@as hs.image]]

  return resized
end


--
-- Add ability to invert image colors
--
---@param image hs.image
---@return hs.image
function imgm.invert(image)
  local inpath = paths.tmp()
  local outpath = paths.tmp()

  image:saveToFile(inpath)

  local cmd = { 'magick','convert', inpath, '-channel', 'RGB', '-negate', outpath }

  local result = sh.result(cmd)

  if result.code == 0 then
    return imgm.from_path(outpath)
  end

  error(result.output)
end


--
-- Add rotation function
--
---@param image hs.image
---@param deg integer
---@return hs.image
function imgm.rotate(image, deg)
  local dim = image:size() --[[@as hs.geometry]]
  
  local w2 = dim.w/2
  local h2 = dim.h/2

  local canvas = hs.canvas.new(hs.geometry.rect(0, 0, dim.w, dim.h)) --[[@as hs.canvas]]
  local matrix = hs.canvas.matrix --[[@as HS.Canvas.Matrix]]

  -- image:copy():template(false)

  canvas:appendElements({
    type = "image",
    image = image,
    transformation = matrix.translate(w2, h2):rotate(180):translate(-w2, -h2),
    imageAlpha = 1.0,
  })

  return canvas:imageFromCanvas() --[[@as hs.image]]
end


return imgm




-- --
-- -- Creates base64 encoded URL string from a image file, width, and height (defaults to 100x100)
-- --
-- ---@param path string
-- ---@param width integer
-- ---@param height integer
-- ---@return string
-- function img.encode_from_path(path, width, height)
--   params.assert.string(path, 1)
--   width = params.default(width, 100)
--   height = params.default(height, 100)

--   local image = img.from_path(path, width, height)
--   return image:encodeAsURLString() or ''
-- end