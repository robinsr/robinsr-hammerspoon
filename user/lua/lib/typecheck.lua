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


---@param fn TypeCheckFn
---@return TypeCheckFn
local function invert(fn)
  return function(arg)
    return not fn(arg)
  end
end


---@param fnA TypeCheckFn
---@param fnB TypeCheckFn
---@return TypeCheckFn
local function both(fnA, fnB)
  return function(arg)
    return fnA(arg) and fnB(arg)
  end
end

---@param fnA TypeCheckFn
---@param fnB TypeCheckFn
---@return TypeCheckFn
local function either(fnA, fnB)
  return function(arg)
    return fnA(arg) or fnB(arg)
  end
end

---@param ... TypeCheckFn
---@return TypeCheckFn
local function any(...)
  local checkall = {...}

  return function(arg)
    for _, fn in ipairs(checkall) do
      if fn(arg) == true then
        return true
      end
    end

    return false
  end
end

---@param fnA TypeCheckFn
---@param ... TypeCheckFn
---@return TypeCheckFn
local function only(fnA, ...)
  local checkall = {...}

  return function(arg)
    for _, fn in ipairs(checkall) do
      if fn(arg) == true then
        return false
      end
    end

    return fnA(arg) == true
  end
end


---@class KS.Types
local tc = {
  isNil       = isNil,
  notNil      = notNil,
  isString    = isString,
  isNum       = isNum,
  isTable     = isTable,
  isFunc      = isFunc,
  isTrue      = isTrue,
  isFalse     = isFalse,
  isEmpty     = isEmpty,
  isCallable  = isCallable,
  invert      = invert,
  both        = both,
  either      = either,
  any         = any,
  only        = only,
}


tc.is = {
  Nil     = isNil,
  True    = isTrue,
  False   = isFalse,
  strng   = isString,
  func    = isFunc,
  tabl    = isTable,
  empty   = both(isString, isEmpty),
  truthy  = truthy,
}

tc.is_not = {
  Nil     = invert(isNil),
  True    = invert(isTrue),
  False   = invert(isFalse),
  strng   = invert(isString),
  func    = invert(isFunc),
  tabl    = invert(isTable),
  empty   = only(isString, isEmpty),
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