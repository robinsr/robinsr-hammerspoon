local logr = require 'user.lua.util.logger'

local log = logr.new('url-handler.lua', 'warning')

local UrlHandler = {
  ---@param cmds Command[]
  ---@return table[]
  bindall = function(cmds)
    local bound = {}

    for i, cmd in ipairs(cmds) do
      if (cmd.url ~= nil) then
        hs.urlevent.bind(cmd.url, function(name, params)
          if (log.getLogLevel() > 3) then
            log.d("URL-Event callback args:", name, hs.inspect(params))
          end

          cmd.fn({ trigger = 'url' }, params)
        end)

        table.insert(bound, { id = cmd.id, url = cmd.url })
      end
    end

    return bound
  end,
}

return UrlHandler
