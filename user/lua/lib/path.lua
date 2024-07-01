local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local plpath  = require 'pl.path'

local log = require('user.lua.util.logger').new('path', 'info')

---@class Paths
local Paths = {}

local PathsMeta = {}

PathsMeta.__index = function(p, key)
  if Paths[key] ~= nil then
    return Paths[key]
  else
    return plpath[key]
  end
end



--
-- Assert path exists
--
---@param path string
---@return boolean
function Paths.exists(path)
  return plpath.exists(path)
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
-- WIP --- Returns filesystem path for a module name
--
---@param modname string Module name
---@return string 
function Paths.mod(modname)
  -- TODO - get caller from debug.getinfo instead of requiring a modname parameter
  -- local debug_info = debug.getinfo(2)
  -- print(hs.inspect(debug_info))

  local dir, err = plpath.package_path(modname)
  
  if dir then
    return dir
  end
  
  if err then
    error(err)
  end

  error(strings.fmt('No path found for module [%s]', modname))
end


--
-- Maps placeholder strings in filepaths to values
--
---@param filepath string Path string
---@return string 
function Paths.expand(filepath)
  params.assert.string(filepath)

  local old_path = filepath

  -- if filepath:startswith('@') then
  --   filepath = filepath:replace('@', plpath.currentdir())
  -- end
  if strings.startswith(filepath, '@') then
    filepath = strings.replace(filepath, '@', plpath.currentdir())
  end

  filepath = plpath.expanduser(filepath)

  log.f("expanded path %q to %q", old_path, filepath)

  if not plpath.exists(filepath) then
    log.wf("Expanded path %q does not exist!", filepath)
  end

  return filepath
end



return setmetatable({}, PathsMeta) --[[@as Paths]]