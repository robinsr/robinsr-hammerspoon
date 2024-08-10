local plpath   = require 'pl.path'
local plfile   = require 'pl.file'
local lists    = require 'user.lua.lib.list'
local params   = require 'user.lua.lib.params'
local strings  = require 'user.lua.lib.string'
local types    = require 'user.lua.lib.typecheck'
local is       = require 'user.lua.lib.typecheck'
local logr     = require 'user.lua.util.logger'

local log = logr.new('lib.fs', 'info')

local THISMOD = ... or 'user.lua.lib.fs'
local MAXFILES = 150

local FS = {}


--
-- Returns contents of file at `filepath` as string
--
---@param filepath string
---@return string
function FS.readfile(filepath)
  return plfile.read(filepath)
end


--
-- Writes `contents` to a file at path `filepath`
--
---@param filepath string
---@param contents string
---@return boolean? ok -- `true` or `nil`
---@return string? err_msg -- error message
function FS.writefile(filepath, contents)
  params.assert.string(filepath, 1)
  params.assert.string(contents, 2)

  return plfile.write(filepath, contents)
end


--
-- Move a file
--
---@param src   string
---@param dest  string
---@return boolean? ok -- `true` or `nil`
---@return string? err_msg -- error message
function FS.moveFile(src, dest)
  params.assert.path(src, 1)
  params.assert.string(dest, 2)

  return plfile.move(src, dest)
end


--
-- Creates a directory
--
---@param dirpath string
function FS.mkdir(dirpath)
  params.assert.string(dirpath, 1)

  plpath.mkdir(dirpath)
end


--
-- Lists contents of a directory and all sub-directories
--
---@param dirname string The directory to scan
---@param ext? string Optional string file extension to filter on
---@param depth? integer Optional how man levels to descend in directory tree; default 10
---@param max? integer Optional max length of list
---@return string[] Table of string filenames (relative or what?)
function FS.listdir(dirname, ext, depth, max)

  local files= {}

  local primaries = {
    strings.fmt(" -name '*.%s'", ext or 'lua'),
    strings.fmt(" -maxdepth %d", depth or 10),
  }

  local findcmd = strings.fmt('find %s -type f %s', dirname, strings.join(primaries))

  log.df('Running command [%s]', findcmd)

  local pfind = io.popen(findcmd)

  if (pfind ~= nil) then
    for filename in pfind:lines() do
      table.insert(files, filename)
      
      if (#files > (max or MAXFILES)) then
        break
      end
    end


    pfind:close()
  else
    error(strings.fmt('Could not scan dir [%s]', dirname))
  end

  log.inspect('Scan directory complete:', files)

  return files
end

--
-- From a root directory, maps lua filepaths to a module name (string used in `require` calls)
--
---@param dir string Directory path to load modules from
---@param pkg string Lua package prefix
---@return table table of filepaths and correspnding lua module name
function FS.mapdir(dir, pkg)
  local targetdir = plpath.join(dir, strings.replace(pkg, '.', '/'))
  local luafiles = FS.listdir(targetdir, 'lua')

  local modules = lists(luafiles):reduce({}, function(memo, filename)
    log.df('loading lua file [%s]', filename)

    memo[filename] = filename:sub(dir:len() + 2)
      :gsub('%.lua', '')
      :gsub('%/', '.')
      :gsub('%.init$', '')

    return memo
  end)

  log.inspect('Mapped lua files:', modules)

  return modules
end


--
-- Requires in all lua files into a table
--
---@param dir string Directory path to load modules from
---@param pkg string Lua package prefix
---@return table<string, table>
function FS.loaddir(dir, pkg)
  log.f('Loading lua modules in package [%s] from directory [%s]', pkg, dir)
  
  local luafiles = FS.mapdir(dir, pkg)

  local modules = {}
  for file, mod in pairs(luafiles) do
    if (mod ~= THISMOD) then
      modules[mod] = require(mod)
    end
  end

  return modules
end

return FS