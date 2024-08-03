local pltypes = require 'pl.types'

---@alias TypeCheckFn fun(item: any): boolean


-- A very explicit null check for my sanity
---@type TypeCheckFn
local function isNil(i)
  if (type(i) == 'nil') then return true else return false end
end

-- Another very explicit null check for my sanity
---@type TypeCheckFn
local function notNil(i)
  if (type(i) ~= 'nil') then return true else return false end
end

-- Type-check is string
---@type TypeCheckFn
local function isString(i)
  if (type(i) == 'string') then return true else return false end
end

-- Type-check is number
---@type TypeCheckFn
local function isNum(i)
  if (type(i) == 'number') then return true else return false end
end

-- Type-check is table
---@type TypeCheckFn
local function isTable(i)
  if (type(i) == 'table') then return true else return false end
end

-- Type-check is function
---@type TypeCheckFn
local function isFunc(i)
  if (type(i) == 'function') then return true else return false end
end

-- Type-check is boolean true
---@type TypeCheckFn
local function isTrue(i)
  if (type(i) == 'boolean' and i == true) then return true else return false end
end

-- Type-check is boolean false
---@type TypeCheckFn
local function isFalse(i)
  if (type(i) == 'boolean' and i == false) then return true else return false end
end

-- Type-check is empty sttring
---@type TypeCheckFn
local function isEmpty(i)
  if (i == '') then return true else return false end
end

-- Type-check is valuable is callable (function)
---@type TypeCheckFn
local function isCallable(i)
  return pltypes.is_callable(i)
end


-- Type-check a "truthy" value
---@type TypeCheckFn
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
  isCallable = isCallable,
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
---@return boolean
function tc.tobool(str)
  if tostring(str):match("^%s*true%s*$") then
    return true
  else
    return false
  end
end


return tc