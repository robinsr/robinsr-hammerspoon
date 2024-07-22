local _padding = function(value)
  value = value or 0.0

  return { 
    padding = 0.0
  }
end

local padding = {
  none  = _padding(0.0),
  sm    = _padding(20.0),
}

setmetatable(padding, {
  __call = hs.fnutils.partial(_padding, nil)
})

return padding