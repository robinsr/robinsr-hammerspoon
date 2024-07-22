---@alias TypeCheckFn fun(item: any): boolean


-- A very explicit null check for my sanity
---@param i any|nil Possibly a nil value
---@return boolean true when param nil
local function isNil(i)
  if (type(i) == 'nil') then return true else return false end
end

-- Another very explicit null check for my sanity
---@param i any|nil Possibly a nil value
---@return boolean true when param nil
local function notNil(i)
  if (type(i) ~= 'nil') then return true else return false end
end

-- Type-check is string
---@param i any|nil Possibly a nil value
---@return boolean true when param is a string
local function isString(i)
  if (type(i) == 'string') then return true else return false end
end

-- Type-check is number
---@param i any|nil Possibly a nil value
---@return boolean true when param is a string
local function isNum(i)
  if (type(i) == 'number') then return true else return false end
end

-- Type-check is table
---@param i any|nil Possibly a nil value
---@return boolean true when param is a table
local function isTable(i)
  if (type(i) == 'table') then return true else return false end
end

-- Type-check is function
---@param i any|nil Possibly a nil value
---@return boolean true when param is a table
local function isFunc(i)
  if (type(i) == 'function') then return true else return false end
end

-- Type-check is boolean true
---@param i any|nil Possibly a nil value
---@return boolean true when param is boolean true
local function isTrue(i)
  if (type(i) == 'boolean' and i == true) then return true else return false end
end

-- Type-check is boolean false
---@param i any|nil Possibly a nil value
---@return boolean true when param is boolean false
local function isFalse(i)
  if (type(i) == 'boolean' and i == false) then return true else return false end
end

-- Type-check is empty sttring
---@param i any|nil Possibly a nil value
---@return boolean true when param is boolean false
local function isEmpty(i)
  if (i == '') then return true else return false end
end

-- Type-check a "truthy" value
---@param i any|nil Possibly a nil value
---@return boolean true when `i` is "truthy"
local function truthy(i)
  if i then
    return true
  else
    return false
  end
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

local function first_not_second(fnA, fnB)
  return function(arg)
    return fnA(arg) == true and fnB(arg) == false
  end
end


---@class KS.Types
local tc = {
  isNil = isNil,
  notNil = notNil,
  isString = isString,
  isNum = isNum,
  isTable = isTable,
  isFunc = isFunc,
  isTrue = isTrue,
  isFalse = isFalse,
  isEmpty = isEmpty,
  invert = invert,
  both = both,
  first_not_second = first_not_second,
}


tc.is = {
  Nil = isNil,
  True = isTrue,
  False = isFalse,
  strng = isString,
  func = isFunc,
  tabl = isTable,
  empty = both(isString, isEmpty),
  truthy = truthy,
}

tc.is_not = {
  Nil = invert(isNil),
  True = invert(isTrue),
  False = invert(isFalse),
  strng = invert(isString),
  func = invert(isFunc),
  tabl = invert(isTable),
  empty = first_not_second(isString, isEmpty),
}

tc.no = {
  nill = notNil,
}



-- Checks if a string represents a true value (only "true" == true) (whitespace permitted)
---@param str any|nil Possibly a nil value
---@return boolean true when param is "true"
function tc.tobool(str)
  if tostring(str):match("^%s*true%s*$") then
    return true
  else
    return false
  end
end


return tc