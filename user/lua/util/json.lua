local path    = require 'pl.path'
local plutils = require 'pl.utils'
local strings = require 'user.lua.lib.string'
local types   = require 'user.lua.lib.typecheck'

local json = {}

-- Decodes JSON string to a table
---@param rawjson string
---@return table
function json.parse(rawjson)
  local tabl = hs.json.decode(rawjson)
  
  if (type(tabl) ~= "nil") then
    return tabl --[[@as table]]
  end

  error('JSON parsing nil with input: '..rawjson)
end

-- Encodes a table to JSON string
---@param tabl table
---@param compact? boolean
---@return string A JSON string
function json.tostring(tabl, compact)
  ---@type boolean
  local prettyprint = plutils.choose(types.isTrue(compact), false, true)

  local jsonstr = hs.json.encode(tabl, prettyprint)
  
  if types.isString(jsonstr) then
    return jsonstr
  end

  error('Could not encode Lua table: ' .. strings.truncate(hs.inspect(tabl), 1000))
end


function json.write(filepath, tabl)
  filepath, err = path.expanduser(filepath)

  if err ~= nil then
    error(err)
  end

  if not path.isdir(path.dirname(filepath)) then
    error(strings.fmt('cannot write to path "%s"; directory not found', filepath))
  end

  ---@cast filepath string
  local file, err = io.open(filepath, "w")

  if err ~= nil then
    error(err)
  end

  if file ~= nil then
    file:write(json.tostring(tabl)):close()
  else
    error('No file to write to')
  end
end

return json