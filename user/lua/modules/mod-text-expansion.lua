hs.hotkey.bind({"cmd", "alt", "ctrl"}, "d", function()  
  local dateString = os.date('%m-%d-%Y')
  hs.eventtap.keyStrokes(dateString)
end) 