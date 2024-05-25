
---@class SetProtoOpts
---@field locked? boolean - sets __newindex such that new properties cannot be set


local LOCKED = function(t, k, v)
  error('Object is locked! Attempt to assign "'..tostring(v)..'" to key "'..k..'"')
end


local P = {}

--[[
Creates inheritance link between a base class and a sub class

## Usage

First, link two *Class* objects

```lua
local SuperClass = {}
local SubClass = {}

setProtoOf(SubClass, SuperClass)
```

Then link objects created by constructors

```lua
function SubClass:new()
  -- optional check to see if self refers to the class object.
  -- If so, use a new object instead
  local this = self == SubClass and {} or self

  -- Call the super class `new` method with self.
  -- SuperClass will set properties on `this`
  SuperClass.new(this)

  -- Finally call setProtoOf so that `this` uses SubClass for regular methods
  return setProtoOf(this, SubClass)
end
```
]]
---@param target table A table that derives from base
---@param base table The base table
---@param opts? SetProtoOpts 
function P.setProtoOf(target, base, opts)
  local options = opts or {}

  if type(base) ~= "table" then
    return target or base 
  end

  target = target or {}

  if target.__index == base then
    return target
  end

  target.__index = base

  if options.locked then
    target.__newindex = LOCKED
  end
  
  return setmetatable(target, target)
end


return P