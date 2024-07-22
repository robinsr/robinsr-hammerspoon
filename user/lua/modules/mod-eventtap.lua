


local log = require('user.lua.util.logger').new('mod-eventtap', 'info')

local evt_types = hs.eventtap.event.types

local tap_other_mouse_down = hs.eventtap.new({ evt_types.otherMouseDown }, function(evt)
  ---@cast evt hs.eventtap.event

  log.f("otherMouseDown Event: %s", hs.inspect(evt))

  -- Block other event listeners (system-wide) from receiving event
  local prevent_default = false

  if prevent_default then
    return true
  end

  return false
end)


local start_dev_server = {
  id = 'ks.eventtap.start',
  title = 'Starts HS event listener and logs events',
  icon = 'info',
  setup = function(cmd) end,
  exec = function(cmd, ctx, params)
    tap_other_mouse_down:start()
  end,
}

local stop_dev_server = {
  id = 'ks.eventtap.stop',
  title = 'Stops the HS server',
  icon = 'info',
  setup = function(cmd) end,
  exec = function(cmd, ctx, params)
    tap_other_mouse_down:stop()
  end,
}

return {
  cmds = {
    start_dev_server,
    stop_dev_server
  }
}

--[[

{ -- appKitDefined      


 0 otherMouseDown     
 1 leftMouseDragged  
 2 magnify            
 3 rightMouseDragged 
 4 rotate             
 5 nullEvent         
 6 leftMouseUp       
 7 rightMouseUp      
 8 mouseExited       
 9 mouseMoved        
10 keyUp              
11 leftMouseDown     
12 gesture            
13 applicationDefined 
14 tabletPointer      
15 changeMode         
16 pressure           
17 directTouch        
18 scrollWheel        
22 smartMagnify       
23 tabletProximity    
24 (nil?)
25 otherMouseDragged  
26 periodic           
27 otherMouseUp       
29 keyDown            
30 mouseEntered      
31 systemDefined      
32 swipe              
33 rightMouseDown    
34 quickLook          
37 flagsChanged       
38 cursorUpdate       


  appKitDefined = 13,
  applicationDefined = 15,
  changeMode = 38,
  cursorUpdate = 17,
  directTouch = 37,
  flagsChanged = 12,
  gesture = 29,
  keyDown = 10,
  keyUp = 11,
  leftMouseDown = 1,
  leftMouseDragged = 6,
  leftMouseUp = 2,
  magnify = 30,
  mouseEntered = 8,
  mouseExited = 9,
  mouseMoved = 5,
  nullEvent = 0,
  otherMouseDown = 25,
  otherMouseDragged = 27,
  otherMouseUp = 26,
  periodic = 16,
  pressure = 34,
  quickLook = 33,
  rightMouseDown = 3,
  rightMouseDragged = 7,
  rightMouseUp = 4,
  rotate = 18,
  scrollWheel = 22,
  smartMagnify = 32,
  swipe = 31,
  systemDefined = 14,
  tabletPointer = 23,
  tabletProximity = 24
}
]]