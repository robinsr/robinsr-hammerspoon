local lists  = require 'user.lua.lib.list'
local tables = require 'user.lua.lib.table'
local proto  = require 'user.lua.lib.proto'


---@class Collection : List
local Collection = {}

local ColMeta = {}
ColMeta.__index = Collection


setmetatable(Collection, { 
  __index = lists,
  __call = function(c, items)
    return setmetatable(items or {}, ColMeta)
  end 
 })


---@param c self
---@param items any[] List of commands to search
---@return Collection
function Collection.new(c, items)
  return setmetatable(items or {}, ColMeta)
end


--
-- Return first item where item's properties match all of tabl's properties
--
---@param col self
---@param tabl table Table of key/value pairs to match against
---@return any
function Collection.where(col, tabl)
  local keys = tables.keys(tabl)
  
  for k, item in ipairs(col or {}) do
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
---@param col self
---@param id string String to match against command's id field
---@return any
function Collection.findById(col, id)
  for k, cmd in ipairs(col or {}) do
    if (tables.get(cmd, 'id') == id) then
      return cmd
    end
  end

  return nil
end

__kscollection = Collection

-- return setmetatable({}, ColMeta)
return Collection