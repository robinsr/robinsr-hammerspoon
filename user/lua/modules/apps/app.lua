

local module = {}


function module:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end


function module:tojson()

end


return module