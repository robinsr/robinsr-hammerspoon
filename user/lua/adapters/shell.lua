local shellg  = require 'shell-games'
local plutil  = require 'pl.utils'
local lists   = require 'user.lua.lib.list'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local json    = require 'user.lua.util.json'
local logr    = require 'user.lua.util.logger'

local fmt = strings.fmt
local pack = table.pack
local unpack = table.unpack


local log = logr.new('shell', 'info')


local ERR_MSG = "Command [%s] exited with code [%d]: %s"

local SHELL_OPTS = {
  capture = true,
  stderr = "&1"
}

---@module 'adapters.shell'
local Shell = {}

Shell.JSON = { json = true }


---@class RunOpts
---@field json? boolean    - parse stdout to json
---@field pick? string     - extract a value from output (implied `json` option)


---@class RunResult
---@field command string
---@field status boolean|number
---@field output string



--
-- Shell execution with some QOL bits
--
---@param args (string|number)[]|string
---@param options? RunOpts
---@return string|table, RunResult
function Shell.run(args, options)

  options = options or {}

  ---@type string|table
  local value = ''

  local result, err

  if type(args) == 'string' then
    result, err = shellg.run_raw(args, SHELL_OPTS)
  else
    result, err = shellg.run(args, SHELL_OPTS)
  end


  local cmd = result["command"]
  local code = result["status"]
  local out = result["output"]


  if (err) then
    log.e('Shell error:', err)
    log.e('Shell result:', hs.inspect(result))

    error(fmt(ERR_MSG, cmd, code, out))
  end

  value = strings.trim(out)

  if (options.json) then
    value = json.parse(out)
  end

  if (options.pick) then
    value = json.parse(out)
    value = tables.get(value, options.pick)
  end

  return value, result
end


--
-- Invokes Shell.run and returns only the first value (stdout)
--
---@param args (string|number)[]  
---@param options? RunOpts
---@return string|table
function Shell.get(args, options)
  return unpack(pack(Shell.run(args, options)), 1, 1)
end



---@param pattern string Format pattern
---@param args (string|number)[] Format parameters
---@return string
function Shell.fmt(pattern, args)
  return fmt(pattern, unpack(args))
end


---@param str string String to split
---@return string[]
function Shell.split(str)
  return strings.split(str, ' ')
end


---@param str string String to split
---@return string ...
function Shell.exp(str)
  return unpack(strings.split(str, ' '))
end


-- Creates a K=V/K="V" shell argument pair
--
---@param key string Parameter key
---@param val string Parameter value
---@return string
function Shell.kv(key, val)
  return fmt('%s=%s', key, shellg.quote(val))
end


-- Quotes a shell argument
--
Shell.quote = shellg.quote

-- Joins a list of shell arguments
--
Shell.join = shellg.join



return Shell