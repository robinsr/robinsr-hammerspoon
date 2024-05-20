local tc = {}

-- A very explicit null check for my sanity
---@param i any|nil Possibly a nil value
---@return boolean true when param nil
function tc.isNil(i)
  if (type(i) == 'nil') then return true else return false end
end

-- Another very explicit null check for my sanity
---@param i any|nil Possibly a nil value
---@return boolean true when param nil
function tc.notNil(i)
  if (type(i) ~= 'nil') then return true else return false end
end

-- Type-check is string
---@param i any|nil Possibly a nil value
---@return boolean true when param is a string
function tc.isString(i)
  if (type(i) == 'string') then return true else return false end
end

-- Type-check is number
---@param i any|nil Possibly a nil value
---@return boolean true when param is a string
function tc.isNum(i)
  if (type(i) == 'number') then return true else return false end
end

-- Type-check is table
---@param i any|nil Possibly a nil value
---@return boolean true when param is a table
function tc.isTable(i)
  if (type(i) == 'table') then return true else return false end
end

-- Type-check is function
---@param i any|nil Possibly a nil value
---@return boolean true when param is a table
function tc.isFunc(i)
  if (type(i) == 'function') then return true else return false end
end

tc.is = {
  nill = tc.isNil,
  strng = tc.isString,
  func = tc.isFunc,
  tabl = tc.isTable,
}

tc.no = {
  nill = tc.notNil,
}

return tc