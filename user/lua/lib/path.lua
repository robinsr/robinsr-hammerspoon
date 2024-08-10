local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local types   = require 'user.lua.lib.typecheck'
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
-- Returns "file" from the path "/some/path/file.ext"
--
---@param path string
---@param suffix? string
---@return string
function Paths.basename(path, suffix)
  local base = plpath.basename(path)

  ---@cast suffix string
  return types.isString(suffix) and strings.replace(base, suffix, '') or base
end


--
-- Returns ".ext" from the path "/some/path/file.ext"
--
---@param path string
---@return string
function Paths.extname(path)
  return plpath.extension(path)
end


--
-- Returns "/some/path" from the path "/some/path/file.ext"
--
---@param path string
---@return string
function Paths.dirname(path)
  return plpath.dirname(path)
end


--
-- Assert path exists
--
---@param path string
---@return boolean
function Paths.exists(path)
  return plpath.exists(Paths.expand(path))
end


--
-- Return a suitable full path to a new temporary file name
--
---@return string
function Paths.tmp()
  return plpath.tmpname()
end


--
-- Returns a boolean if supplied path matches the pattern
--
---@param path string
---@param pattern string
---@param options? table
---@return boolean
function Paths.matches(path, pattern, options)
  params.assert.string(path, 1)
  params.assert.string(pattern, 2)
  
  return (path or ''):match(pattern) ~= nil
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

  log.df("expanded path %q to %q", old_path, filepath)

  if not plpath.exists(filepath) then
    log.wf("Expanded path %q does not exist!", filepath)
  end

  return filepath
end


--
-- Returns a new filename from template
--
---@param filepath string
---@param pattern string
---@param addvars? table Optional additional format string variables
function Paths.rename(filepath, pattern, addvars)
  params.assert.string(filepath)
  params.assert.string(pattern)

  local vars = {}

  vars.name = Paths.basename(filepath)
  vars.ext  = Paths.extname(filepath)
  vars.dir  = Paths.dirname(filepath)
  vars.base = Paths.basename(filepath, vars.ext)

  for k,v in pairs(addvars or {}) do
    vars[k] = v
  end

  local result = pattern:gsub('%{(%w+)%}', function(n)
    return vars[n]
  end)

  return plpath.normpath(result)
end


return setmetatable({}, PathsMeta) --[[@as Paths]]