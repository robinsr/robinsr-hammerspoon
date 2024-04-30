local util = require 'user.lua.util'

---@generic T: any
---@alias PredicateFn fun(i: T): boolean

---@class List
local List = {}

---@generic T: any
---@param list T[] List of commands to search
function List:new(list)
  o = list or {}
  setmetatable(o, self)
  self.__index = self
  return o
end


--
-- Return item where item.id eq passed parameter
--
---@generic T: HasId
---@param id any String to match against command's id field
---@return T|nil
function List:findById(id)
  for k, cmd in ipairs(self) do
    if (cmd.id == id) then
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
function List:find(fn)
  for k, cmd in ipairs(self) do
    if (fn(cmd) == true) then
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
function List:where(tabl)
  local keys = util.keys(tabl)
  
  for k, item in ipairs(self) do
    for j, key in ipairs(keys) do
      if (util.path(item, key) == tabl[key]) then
        return item
      end
    end
  end

  return nil
end



return List