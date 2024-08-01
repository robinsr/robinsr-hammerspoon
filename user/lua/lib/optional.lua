local inspect = require 'inspect'
local params  = require 'user.lua.lib.params'
local types   = require 'user.lua.lib.typecheck'
local logr    = require 'user.lua.util.logger'

local log = logr.new('Optional', 'info')



---@class Optional
local Optional = {}

Optional.msg = 'This cant be null'


local OptionalMeta = {
  __index = Optional
}


--
-- Returns an Optional with the specified present non-null value.
--
---@generic T
---@param self { value: T, present: boolean }
---@param val T|nil
---@param msg? string customized error msg
---@return Optional
function Optional:of(val, msg)
  log.df('Optional:of  - type(%s) msg("%s") val(%s)', type(val), (msg or '<none>'), inspect(val))

  if types.isNil(val) then
    error(msg or Optional.msg)
  end

  ---@class Optional<T>
  local this = {
    present = true,
    value   = val,
  }

  return setmetatable(this, OptionalMeta)
end


--
-- Returns an Optional describing the specified value, if non-null, otherwise
-- returns an empty Optional.
--
---@generic T
---@param self { value: T, present: boolean }
---@param val T|nil
---@param msg? string customized error msg
---@return Optional
function Optional:ofNil(val, msg)
  log.df('Optional:OfNil - type(%s) val(%s)', type(val), inspect(val))
  
  ---@class Optional<T>
  local this = {
    present = types.notNil(val),
    value   = val,
  }

  return setmetatable(this, OptionalMeta)
end


--
-- Returns true of optional's value is not nil
--
---@generic T
---@param self { value: T, present: boolean }
---@return boolean
function Optional:isPresent()
  return self.present == true
end


--
-- Returns true of optional's value is nil
--
---@generic T
---@param self { value: T, present: boolean }
---@return boolean
function Optional:isEmpty()
  return self.present == false
end


--
-- If a value is present in this Optional, returns the value, otherwise throws an error
--
---@generic T
---@param self { value: T, present: boolean }
---@return T
function Optional:get()
  if self.present == false then
    error('get called on nil optional')
  end

  return self.value
end


--
-- If a value is present, invoke the specified consumer with the value, otherwise do nothing.
--
---@generic T
---@param self { value: T, present: boolean }
---@param consumer fun(val: T)
---@return Optional
function Optional:ifPresent(consumer)
  if self.present == true then
    consumer(self.value)
  end
    
  return self
end


--
-- Returns fallback value when optional is null
--
---@generic T
---@generic F
---@param self { value: T, present: boolean }
---@param fallback F
---@return T|F
function Optional:orElse(fallback)
  if self.present == false then
    return fallback
  end

  return self.value
end


--
-- Calls fallback supplier function when optional is null
--
---@generic T
---@generic S
---@param self { value: T, present: boolean }
---@param supplier fun(): S
---@return T|S
function Optional:orElseGet(supplier)
  if self.present == false then
    return supplier()
  end
  
  return self.value
end


--
-- If a value is present, apply the provided mapping function to it, and if
-- the resultis non-null, return an Optional describing the result. Otherwise
-- return an empty Optional.
--
---@generic T
---@generic S
---@param self { value: T, present: boolean }
---@param mapper fun(val: T): S
---@return Optional
function Optional:map(mapper)
  if self.present == true then
    local ok, result = pcall(mapper, self.value)

    if ok then
      return Optional:ofNil(result)
    end
  end
  
  return Optional:ofNil(nil)
end


--
-- If a value is present, call the provided method on the value, and if
-- the resultis non-null, return an Optional describing the result. Otherwise
-- return an empty Optional.
--
---@generic T
---@param self { value: T, present: boolean }
---@param methodName string
---@param ... any Optional method arguments
---@return Optional
function Optional:mapMethod(methodName, ...)
  if self.present == true then
    local ok, result = pcall(self.value[methodName], self.value, table.unpack({...}))

    if ok then
      return Optional:ofNil(result)
    end
  end
  
  return Optional:ofNil(nil)
end


--
-- If a value is present, and the value matches the given predicate, return
-- an Optional describing the value, otherwise return an empty Optional.
--
---@generic T
---@param self { value: T, present: boolean }
---@param predicate fun(val: T): boolean
---@return Optional
function Optional:filter(predicate)
  if self.present == true and predicate(self.value) then
    return self
  end
  
  return Optional:ofNil(nil)
end


return setmetatable({}, OptionalMeta) --[[@as Optional]]