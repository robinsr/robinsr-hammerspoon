local shellg  = require 'shell-games'
local plutil  = require 'pl.utils'
local lists   = require 'user.lua.lib.list'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local json    = require 'user.lua.util.json'
local logr    = require 'user.lua.util.logger'

local fmt = strings.fmt
local pack = table.pack
local unpack = table.unpack


local log = logr.new('shell', 'info')

local ERR_MSG = "Command %q exited with code [%q]: %q"


---@param sh_result table
local function cmd_error(sh_result, sh_err)
  local cmd = sh_result["command"]
  local code = sh_result["status"]
  local out = sh_result["output"]

  log.e('Shell error:', sh_err)
  log.e('Shell result:', hs.inspect(sh_result))

  return fmt(ERR_MSG, cmd, code, out)
end




local SHELL_OPTS = {
  capture = true,
  stderr = "&1"
}


---@class KS.Shell.RunOpts
---@field json? boolean    - parse stdout to json
---@field pick? string     - extract a value from output (implied `json` option)

---@class KS.Shell.Result
---@field command string
---@field status boolean|number
---@field code integer
---@field output string
local ShellResult = {}

---@return KS.Shell.Result
function ShellResult:new(sh_result)

  ---@type KS.Shell.Result
  local this = self == ShellResult and {} or self

  this.command = sh_result["command"]
  this.status = sh_result["status"]
  this.code = types.isNum(sh_result["status"]) and sh_result["status"] or 0
  this.output = strings.trim(sh_result["output"] or '')

  return proto.setProtoOf(this, ShellResult)
end


---@param args string JQ args
function ShellResult:jq(args)
  local jq_cmd = fmt("echo '%s' | jq -cM '%s'", self.output, args)
  local jq_result, err = shellg.run_raw(jq_cmd, SHELL_OPTS)

  if err ~= nil then
    error(cmd_error(jq_result, err))
  end

  self.output = strings.trim(jq_result["output"])

  return self
end

---@return table
function ShellResult:json()
  return json.parse(self.output)
end

---@return Table
function ShellResult:table()
  return tables(self:json())
end

---@return any
function ShellResult:pick(key)
  local json = self:table()
  return json:contains(key) and json:get(key) or nil
end



--
-- Shell functions
--
---@class KS.Shell
local Shell = {}

Shell.JSON = { json = true }


--
-- Executes shell command and returns a `KS.Shell.Result` wrapper object
--
---@param args (string|number)[]|string
---@return KS.Shell.Result
function Shell.result(args)
  local sh_result, sh_err

  if type(args) == 'string' then
    sh_result, sh_err = shellg.run_raw(args, SHELL_OPTS)
  else
    sh_result, sh_err = shellg.run(args, SHELL_OPTS)
  end


  local cmd = sh_result["command"]
  local code = sh_result["status"]
  local out = sh_result["output"]


  if (sh_err) then
    log.e('Shell error:', sh_err)
    log.e('Shell result:', hs.inspect(sh_result))

    error(fmt(ERR_MSG, cmd, code, out))
  end

  return ShellResult:new(sh_result)
end


--
-- Shell execution with some QOL bits
--
---@param args (string|number)[]|string
---@param options? KS.Shell.RunOpts
---@return string|table, KS.Shell.Result
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
---@param options? KS.Shell.RunOpts
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