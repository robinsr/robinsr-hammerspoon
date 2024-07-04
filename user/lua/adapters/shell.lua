local plutil  = require 'pl.utils'
local fs      = require 'user.lua.lib.fs'
local lists   = require 'user.lua.lib.list'
local paths   = require 'user.lua.lib.path'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local json    = require 'user.lua.util.json'
local logr    = require 'user.lua.util.logger'

local shell_games  = require 'shell-games'

local fmt = strings.fmt
local pack = table.pack
local unpack = table.unpack
local quote_arg = shell_games.quote

local log = logr.new('shell', 'info')

local ERR_MSG = "Command %q exited with code [%q]: %q"


---@param sh_result table
local function cmd_error(sh_result, sh_err)
  local cmd = sh_result["command"]
  local code = sh_result["status"]
  local out = sh_result["output"]

  log.e('Shell error:\n\t', sh_err)
  log.e('Shell result:\n\t', hs.inspect(sh_result))

  return fmt(ERR_MSG, cmd, code, out)
end

local SHELL_OPTS = {
  capture = true,
  stderr = "&1",
}

local PROFILE = paths.expand("~/.profile")


--
-- Returns commmand string with profile prefix source 
--
---@param args string|string[]
---@return string
local function splice_args(args)
  local string_args
  local args_env = lists({}):concat({ "source", PROFILE, "&&" })

  if type(args) == 'string' then
    string_args = args_env:push(args):join(' ')
  else
    string_args = args_env:push(unpack(args)):join(' ')
  end
  
  log.v(string_args)

  return string_args
end


--
-- Shell functions
--
---@class KS.Shell
local Shell = {}

-- Shell.JSON = { json = true }


---@class KS.Shell.RunOpts
---@field json? boolean    - parse stdout to json
---@field pick? string     - extract a value from output (implied `json` option)

---@class ShellResult
---@field command string
---@field status boolean|number
---@field code integer
---@field output string
local ShellResult = {}


function ShellResult:new(args)
---@type ShellResult
  local this = self == ShellResult and {} or self

  this.command = nil
  this.status = nil
  this.code = nil
  this.output = nil

  return proto.setProtoOf(this, ShellResult)
end



---@return ShellResult
function ShellResult:from_result(sh_result)

  ---@type ShellResult
  local this = self == ShellResult and {} or self

  ShellResult._post_run(this, sh_result)

  return proto.setProtoOf(this, ShellResult)
end


function ShellResult:_post_run(sh_result)
  self.command = sh_result["command"]
  self.status = sh_result["status"]
  self.code = types.isNum(sh_result["status"]) and sh_result["status"] or 0
  self.output = strings.trim(sh_result["output"] or '')
end


--
---@param pattern string when matched against stderr output, result is considered non-error
function ShellResult:allow(pattern)

end


function ShellResult:run()
  --- TODO
end


---@return boolean
function ShellResult:ok()
  return self.code == 0
end


function ShellResult:error_msg()
  if self:ok() then
    return ''
  end

  return cmd_error(self, nil)
end


---@param jq_filter string JQ args
function ShellResult:jq(jq_filter)

  if self.code == 0 then

    local ok, data = pcall(function() return json.parse(self.output) end)

    if not ok then
      error("Invalid JSON, cannot invoke jq - " .. self.output)
    end

    local jq_cmd = fmt("echo '%s' | /opt/homebrew/bin/jq -c -M '%s'", self.output, jq_filter)
    -- local jq_result, err = shell_games.run_raw(jq_cmd, SHELL_OPTS)
    local jq_result, err = shell_games.run_raw(splice_args(jq_cmd), SHELL_OPTS)

    if err ~= nil then
      error(cmd_error(jq_result, err))
    end

    self.output = strings.trim(jq_result["output"])
  end

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

function ShellResult:__tojson(state)
  local o = tables.pick(self, { 'status', 'code', 'command', 'output' })
  
  return json.tostring(o, not state.indent)
end



---@return ShellResult
function Shell.build(args)
  return ShellResult:new(args)
end


--
-- Executes shell command and returns a `KS.Shell.Result` wrapper object
--
---@param args (string|number)[]|string
---@return ShellResult
function Shell.result(args)
  local sh_result, sh_err = shell_games.run_raw(splice_args(args), SHELL_OPTS)

  local cmd = sh_result["command"]
  local code = sh_result["status"]
  local out = sh_result["output"]

  log.v(cmd, code, out)

  if (sh_err) then
    log.w('Shell error:', sh_err)
    log.w('Shell result:', hs.inspect(sh_result))
  end

  return ShellResult:from_result(sh_result)
end


--
-- Shell execution with some QOL bits
--
---@param args (string|number)[]|string
---@param options? KS.Shell.RunOpts
---@return string|table, ShellResult
---@deprecated
function Shell.run(args, options)

  options = options or {}

  ---@type string|table
  local value = ''

  local sh_result, sh_err = shell_games.run_raw(splice_args(args), SHELL_OPTS)


  local cmd = sh_result["command"]
  local code = sh_result["status"]
  local out = sh_result["output"]


  if (sh_err) then
    log.e('Shell error:', sh_err)
    log.e('Shell result:', hs.inspect(sh_result))

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

  return value, sh_result
end


--
-- Invokes Shell.run and returns only the first value (stdout)
--
---@param args (string|number)[]  
---@param options? KS.Shell.RunOpts
---@return string|table
---@deprecated
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


--
-- Creates a K=V/K="V" shell argument pair
--
---@param key string Parameter key
---@param val string Parameter value
---@return string
function Shell.kv(key, val)
  local kv_pattern = '%s=%s'

  if string.match(val, '%s') then
    kv_pattern = '%s="%s"'
  end

  -- return fmt(kv_pattern, key, shellg.quote(val))
  return fmt(kv_pattern, key, val)
end


-- Quotes a shell argument
--
Shell.quote = shell_games.quote

-- Joins a list of shell arguments
--
Shell.join = shell_games.join


return Shell