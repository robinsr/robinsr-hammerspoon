local cmds = require 'user.lua.commands'
local M = require 'moses'

local log = hs.logger.new('url-handler.lua', 'warning')

local UrlHandler = {
  bindall = function(cmds)
    return M.chain(cmds)
      :filter(function(i, cmd) 
        return cmd.url ~= nil
      end)
      :map(function(i, cmd)
        return hs.urlevent.bind(cmd.url, function(name, params)
          log.d("URL-Event callback args:", name, hs.inspect(params))
          cmd.fn({ type = 'url' }, params)
        end)
      end)
      :value()
  end,
}

return UrlHandler