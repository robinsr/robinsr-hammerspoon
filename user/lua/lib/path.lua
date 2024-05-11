local str    = require 'user.lua.lib.string'
local plpath = require 'pl.path'

local log = require('user.lua.util.logger').new('path', 'error')


local path = {}

path.pl = plpath


--
-- Returns the current dir (location of root init.lua file)
--
---@return string 
function path.cwd()
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
function path.join(...)
  return plpath.normpath(str.join({...}, '/'))
end


--
-- Returns filesystem path for a module name
--
---@param modname string Module name
---@return string 
function path.mod(modname)
  local dir, err = plpath.package_path(modname)
  
  if dir then
    return dir
  
  elseif err then
    error(err)
  end

  log.ef('No path found for module [%s]', modname)
end



return path