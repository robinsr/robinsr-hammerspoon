local colors  = require 'user.lua.ui.color'


local a = {}

a[#a+1] = {             -- first we start with the entire frame as being available
    action = "build", 
    type = "rectangle",
}
a[#a+1] = {             -- but we take out a circle (note the reversePath)
    type = "rectangle",
    frame = { x = "20%", y = "25%", h = "60%", w = "250%"},
    reversePath = true,
    action = "clip",
}
a[#a+1] = {             -- *NOW* we can draw our actual "visible" parts
    type = "rectangle",
    frame = { x = 0, y = 0, h = 256, w = 256},
    fillColor = colors.blue,
    action = "fill",
}
a[#a+1] = {             -- so future objects aren't clipped by the circle
    type = "resetClip"
}


return {
  -- filename = '/Users/ryan/Desktop/four-squares.png',
  debug = true,
  frame = { w = 256, h = 256 },
  elements = a
}