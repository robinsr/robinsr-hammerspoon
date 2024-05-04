local U = require 'user.lua.util'

---@class Set<T>: { [integer]: T }
local Set = {}

---@generic T: any
---@param list Set<T> List of commands to search
function Set:new(list)
  o = list or {}
  setmetatable(o, self)
  self.__index = self
  return o
end


--
-- Return item where item.id eq passed parameter
--
---@generic T
---@param id any String to match against command's id field
---@return T|nil
function Set:findById(id)
  for k, cmd in ipairs(self) do
    if (U.path(cmd, 'id') == id) then
      return cmd
    end
  end

  return nil
end

--
-- Return first item where fn(item) eq true
--
---@generic T: any
---@param fn PredicateFn to match against
---@return T|nil
function Set:find(fn)
  for k, cmd in ipairs(self) do
    if (fn(cmd, k) == true) then
      return cmd
    end
  end

  return nil
end


--
-- Return first item where item's properties match all of tabl's properties
--
---@generic T: any
---@param tabl table Table of key/value pairs to match against
---@return T|nil
function Set:where(tabl)
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



return Set