local fs_loader = require 'aspect.loader.filesystem'
local config    = require 'aspect.config'
local template  = require 'aspect.template'
local json      = require 'user.lua.lib.json'
local paths     = require 'user.lua.lib.path'


config.json.encode = function(data, ...)
  return json.tostring(data)
end

config.json.decode = function(data, ...)
  return json.parse(data)
end

---@type aspect.template
local aspect = template.new({
  cache = false,
  debug = true,
  loader = fs_loader.new(paths.expand('@/resources/templates/aspect'))
})

return aspect