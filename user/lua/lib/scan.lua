-- Require all other `.lua` files in the same directory
local U  = require 'user.lua.util'
local L  = require 'user.lua.lib.list'
local is = require 'user.lua.lib.typecheck'

local log = U.log('filescan', 'info')

local thisModule = ... or 'user.lua.lib.scan'

local scan = {}

--
-- Scans a directroy for files and returns a list of file names
--
-- // Tested with find user/lua -type f -name '*.lua' -maxdepth 100
--
---@param dirname string The directory to scan
---@param ext? string Optional string file extension to filter on
---@param depth? integer Optional how man levels to descend in directory tree; default 10
---@return string[] Table of string filenames (relative or what?)
function scan.scandir(dirname, ext, depth)
  local files, popen = {}, io.popen

  local primaries = {
    U.fmt(" -name '*.%s'", ext or 'lua'),
    U.fmt(" -maxdepth %d", depth or 10),
  }

  local findcmd = U.fmt('find %s -type f %s', dirname, U.join(primaries))

  log.f('Running command [%s]', findcmd)

  local pfind = popen(findcmd)

  if (pfind ~= nil) then
    for filename in pfind:lines() do
      table.insert(files, filename)
      
      if (#files > 150) then
        break
      end
    end


    pfind:close()
  else
    error('Could not scan dir '..dirname)
  end

  return files
end


---@param rootdir string Directory path to load modules from
---@param pkg string Lua package prefix
function scan.loaddir(rootdir, pkg)
  log.inspect(rootdir)

  local targetdir = string.format('%s/%s', rootdir, string.gsub(pkg, '%.', '/'))
  
  local luafiles = scan.scandir(targetdir, 'lua')

  local modules = L.reduce({}, luafiles, function(memo, filename)
    log.f('loading lua file %s', filename)

    local modname = filename:sub(rootdir:len() + 2)
      :gsub('%.lua', '')
      :gsub('%/', '.')
    
    log.f('transform file [%s] to module %s', filename, modname)

    if (modname ~= thisModule) then
      memo[filename] = require(modname)
    end

    return memo
  end)

  return modules
end

return scan