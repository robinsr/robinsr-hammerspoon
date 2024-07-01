local path    = require 'pl.path'
local plutils = require 'pl.utils'
local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'

local dkjson = require 'dkjson'

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
  params.assert.tabl(tabl)

  compact = compact or false

  local keys = tables.keys(tabl)
  table.sort(keys)

  local json_config = {
    indent = not compact,
    keyorder = keys,
  }


  local jsonstr

  if types.isFunc(tabl.__tojson) then
    jsonstr = dkjson.encode(tabl, json_config)
  else  
    jsonstr = dkjson.encode(tables.toplain(tabl), json_config)
  end

  
  if types.isString(jsonstr) then
    return jsonstr --[[@as string]]
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