-- Require all other `.lua` files in the same directory
local utils = require 'user.lua.util'
local M = require('moses')

local log = utils.log('init_d', 'debug')

local info = debug.getinfo(1, 'S')
log.inspect(info)
local module_directory = string.match(info.source, '^@(.*)/')
local module_filename = string.match(info.source, '/([^/]*)$')

-- Apparently the name of this module is given as an argument when it is
-- required, and apparently we get that argument with three dots.
local module_name = ... or "init.d"


local function scandir(directory)
  local t, popen = {}, io.popen
  local pfile = popen('ls -a "'..directory..'"')
  for filename in pfile:lines() do
    table.insert(t, filename)
  end
  pfile:close()
  return t
end

return function (target_dir)
  log.inspect(target_dir)
  local files = scandir(target_dir)

  files = M.map(files, function(a,b,c) 
    return b
  end)

  local modules = M.chain(files)
    .filter(function (i, filename)
      log.i(filename)
      local is_lua_module = string.match(filename, "[.]lua$")
      local is_this_file = filename == module_filename
      return is_lua_module and not is_this_file
    end)
    .filter(function (i, filename)
      local config_module = string.match(filename, "(.+).lua$")
      local mod = require(module_name.."."..config_module)

      return mod.singleton
    end)
    .value()

    return modules
end