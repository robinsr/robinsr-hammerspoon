local class = require 'middleclass'


local Runnable = {}

function Runnable:new(...)
  self.cmds = {...}
  table.insert(self.cmds, cmd)
end


function Runnable:pipe(self, cmd)
  table.insert(self.cmds, cmd)
end


function Runnable:run()
  local pipedCmd = ""
  -- todo
end


return Runnable