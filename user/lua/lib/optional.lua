local check  = require 'user.lua.lib.typecheck'
local logger = require 'user.lua.util.logger'

local log = logger.new('Optional', 'verbose')

local is, notNil = check.is, check.notNil


---@class Optional<T>: { value: T, present: boolean }
local optional = {}

--
-- Creates a new optional
--
---@generic T
---@param val T|nil
---@param msg? string customized error msg
---@return Optional<T>
function optional:new(val, msg)
  log.df('Optional:New  - type(%s) msg("%s") val(%s)', type(val), (msg or 'none'), hs.inspect(val))

  local o = {
    present = notNil(val),
    value   = val,
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

--
-- Returns true of optional's value is not nil
--
---@generic T
---@param self { value: T, present: boolean }
---@return boolean
function optional:ispresent()
  return self.present
end

--
-- Returns the optional's non-nil value or throws an error
--
---@generic T
---@param self { value: T, present: boolean }
function optional:get()
  if self.present == false then
    error('Cannot get nil optional')
  end

  return self.value
end


--
-- Returns fallback value when optional is null
--
---@generic T
---@param self { value: T, present: boolean }
---@param fallback T
---@return T
function optional:orElse(fallback)
  if self.present == false then
    return fallback
  end

  return self.value
end


--
-- Calls fallback supplier function when optional is null
--
---@generic T
---@param self { value: T, present: boolean }
---@param supplier fun(): T
---@return T
function optional:orElseGet(supplier)
  if self.present == false then
    return supplier()
  end
  
  return self.value
end



--
-- Will throw an error if value provided is nil
--
---@generic T
---@param val T|nil
---@param msg? string customized error msg
---@return T
local function optionalOf(val, msg)
  log.df('Optional:Of - type(%s) msg("%s") val(%s)', type(val), (msg or 'none'), hs.inspect(val))

  local onNilMsg = msg or 'This cant be nil'
  
  if is.nill(val) then
    error(onNilMsg)
  end

  return val
end


return {
  ---@generic T
  ---@param val T|nil
  ---@param msg? string customized error msg
  ---@return T
  of = function(val, msg) 
    return optionalOf(val, msg)
  end,

  ---@generic T
  ---@param val T|nil
  ---@param msg? string customized error msg
  ---@return Optional
  ofNil = function(val, msg) 
    return optional:new(val, msg)
  end,
}