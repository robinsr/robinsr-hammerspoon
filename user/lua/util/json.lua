local fs      = require 'user.lua.lib.fs'
local paths   = require 'user.lua.lib.path'
local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'

local dkjson = require 'dkjson'

local json = {}


--
-- Decodes JSON string to a table
--
---@param rawjson string
---@return table
function json.decode(rawjson)
  params.assert.string(rawjson)

  local tabl = hs.json.decode(rawjson)
  
  if (type(tabl) ~= "nil") then
    return tabl --[[@as table]]
  end

  error('JSON parsing nil with input: '..rawjson)
end

json.parse = json.decode


--
-- Encodes a table to JSON string
--
---@param tabl table
---@param compact? boolean
---@return string A JSON string
function json.encode(tabl, compact)
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

json.tostring = json.encode


--
-- Encode a table as JSON and write to file
--
---@param filepath string
---@param tabl table
function json.write(filepath, tabl)
  params.assert.string(filepath, 1)
  params.assert.tabl(tabl, 2)

  filepath = paths.expand(filepath)

  if not paths.exists(paths.dirname(filepath)) then
    error(('Cannot write JSON: No direcroy [%s]'):format(paths.dirname(filepath)))
  end

  local ok, err = fs.writefile(filepath, json.tostring(tabl))

  if not ok then
    error(('JSON writefile error: %s'):format(err))
  end
end


--
-- Encode a table as JSON and write to file
--
---@param filepath string
---@return table
function json.read(filepath)
  params.assert.string(filepath)

  filepath = paths.expand(filepath)

  if not paths.exists(filepath) then
    error(('Cannot read JSON: File not found [%s]'):format(filepath))
  end

  return json.decode(fs.readfile(filepath))
end

return json