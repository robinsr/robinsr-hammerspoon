local _rounded = function(xRadius, yRadius)
  xRadius = xRadius or 0.0
  yRadius = yRadius or xRadius

  return { 
    roundedRectRadii = {
      xRadius = xRadius,
      yRadius = yRadius,
    }
  }
end

local rounded = {
  none = _rounded(0.0, 0.0),
  sm   = _rounded(4.0, 4.0),
  md   = _rounded(10.0, 10.0),
  lg   = _rounded(16.0, 16.0),
}

setmetatable(rounded, {
  __call = hs.fnutils.partial(_rounded, nil)
})

return rounded