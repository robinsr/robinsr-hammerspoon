local strings = require 'user.lua.lib.string'
local types   = require 'user.lua.lib.typecheck'
local plpath  = require 'pl.path'

local log = require('user.lua.util.logger').new('path', 'error')

---@class Paths
local Paths = {}

local PathsMeta = {}

PathsMeta.__index = function(p, key)
  if types.notNil(Paths[key]) then
    return Paths[key]
  else
    return plpath[key]
  end
end


--
-- Returns the current dir (location of root init.lua file)
--
---@return string 
function Paths.cwd()
  local dir, err =  plpath.currentdir()

  if err then
    error(err)
  end

  return dir
end


--
-- Returns a normalized path string from individual path components
--
---@param ... string Path components
---@return string Joined path
function Paths.join(...)
  return plpath.normpath(strings.join({...}, '/'))
end


--
-- Returns filesystem path for a module name
--
---@param modname string Module name
---@return string 
function Paths.mod(modname)
  local dir, err = plpath.package_path(modname)
  
  if dir then
    return dir
  end
  
  if err then
    error(err)
  end

  error(strings.fmt('No path found for module [%s]', modname))
end



return setmetatable({}, PathsMeta) --[[@as Paths]]