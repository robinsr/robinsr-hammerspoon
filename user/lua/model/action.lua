---@class ks.action
---@field type string
---@field data table

---@class ks.action
---@operator call:ks.action
local Action = {}

local ActionMeta = {
  __index = Action,
  __call = function(act, t, d)
    return Action:new(t, d)
  end
}


---@param type string
---@param data table
---@return ks.action
function Action:new(type, data)
  ---@class ks.action
  local this = {
    type = type,
    data = data,
  }
  
  return setmetatable(this, ActionMeta)
end


return setmetatable({}, ActionMeta) --[[@as ks.action]]