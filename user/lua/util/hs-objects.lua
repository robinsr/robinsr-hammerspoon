--
-- Shim for creating Hammerspoon Object with proper return types
--
local hsshim = {}

hsshim.geometry = {}

---@param width integer
---@param height integer
---@return hs.geometry
function hsshim.geometry.size(width, height)
  return hs.geometry.size(width, height) --[[@as hs.geometry]]
end

function hsshim.geometry.rect( ... )
  -- body
end

function hsshim.geometry.point( ... )
  -- body
end

hsshim.urlevent = {}

function hsshim.urlevent.bind( ... )
  return hs.urlevent.bind(table.unpack{...}) --[[@as nil]]
end



hsshim.inspect = function(...)
  return hs.inspect(table.unpack{...})
end

return hsshim