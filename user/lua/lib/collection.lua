local L = require 'user.lua.lib.list'
local U = require 'user.lua.util'

---@generic T
---@class Collection<T> : { [integer]: T }
local Collection = {}

---@generic T
---@param items T[] List of commands to search
function Collection:new(items)
  ---@type Collection
  local o = items

  -- todo: can I just pass the List module to setmetatable to get all List methods?
  setmetatable(o, self)
  self.__index = self
  return o
end


--
-- Return first item where item's properties match all of tabl's properties
--
---@generic T
---@param tabl table Table of key/value pairs to match against
---@return T|nil
function Collection:where(tabl)
  local keys = U.keys(tabl)
  
  for k, item in ipairs(self) do
    for j, key in ipairs(keys) do
      if (item[key] == tabl[key]) then
        return item
      end
    end
  end

  return nil
end


--
-- Return item where item.id eq passed parameter
--
---@generic T
---@param id any String to match against command's id field
---@return T|nil
function Collection:findById(id)
  for k, cmd in ipairs(self) do
    if (U.path(cmd, 'id') == id) then
      return cmd
    end
  end

  return nil
end

--
-- See `List.first`
--
---@see List.first
---@generic T: any
---@param fn PredicateFn to match against
---@return T|nil
function Collection:first(fn)
  return L.first(self, fn)
end


--
-- See `List.filter`
--
---@see List.filter
---@generic T: any
---@param self Collection<T>
---@param fn PredicateFn to match against
---@return T[]
function Collection:filter(fn)
  return L.filter(self, fn)
end


--
-- See `List.every'
--
---@generic T : any
---@param fn PredicateFn The test function
---@return boolean
function Collection:every(fn)
  return L.every(self, fn)
end


--
-- See `List.any`
--
---@see List.any
---@generic T : any
---@param fn PredicateFn The test function
---@return boolean
function Collection:any(fn)
  return L.any(self.items, fn)
end


return Collection