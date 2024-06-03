local tc = {}


---@alias TypeCheckFn fun(i any|nil): boolean


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

-- Type-check is boolean true
---@param i any|nil Possibly a nil value
---@return boolean true when param is boolean true
function tc.isTrue(i)
  if (type(i) == 'boolean' and i == true) then return true else return false end
end

-- Type-check is boolean false
---@param i any|nil Possibly a nil value
---@return boolean true when param is boolean false
function tc.isFalse(i)
  if (type(i) == 'boolean' and i == false) then return true else return false end
end

-- Type-check is empty sttring
---@param i any|nil Possibly a nil value
---@return boolean true when param is boolean false
function tc.isEmpty(i)
  if (i == '') then return true else return false end
end


local function invert(fn)
  return function(arg)
    return (not fn(arg))
  end
end

local function both(fnA, fnB)
return function(arg)
    return fnA(arg) == true and fnB(arg) == true
  end
end

local function onlyFirst(fnA, fnB)
  return function(arg)
    return fnA(arg) == true and fnB(arg) == false
  end
end


tc.is = {
  Nil = tc.isNil,
  True = tc.isTrue,
  False = tc.isFalse,
  strng = tc.isString,
  func = tc.isFunc,
  tabl = tc.isTable,
  empty = both(tc.isString, tc.isEmpty),
}

tc.is_not = {
  Nil = invert(tc.isNil),
  True = tc.isTrue,
  False = tc.isFalse,
  strng = invert(tc.isString),
  func = invert(tc.isFunc),
  tabl = invert(tc.isTable),
  empty = onlyFirst(tc.isString, tc.isEmpty)

}

tc.no = {
  nill = tc.notNil,
}

return tc