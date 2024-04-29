-- Decodes JSON string to a table
---@param rawjson string
---@return table
function parseJSON (rawjson)
  local tabl = hs.json.decode(rawjson)
  
  if (type(table) ~= "nil") then
    return tabl --[[@as table]]
  end

  error('JSON parsing nil with input: '..rawjson)
end

return parseJSON