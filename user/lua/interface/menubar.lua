local M       = require 'moses'
local desktop = require 'user.lua.interface.desktop'
local ui      = require 'user.lua.ui'
local symbols = require 'user.lua.ui.symbols'
local util    = require 'user.lua.util'

local log = util.log('iface:menubar', 'info')

local function textMenuItem(text)
  return {
    title = text,
    image = ui.icons.info,
    disabled = true,
  }
end

local function serviceMenuProps(service)
  if (service.pid) then
    return "on" , "("..service.pid..")"
  else
    return "off", "(?)"
  end
end

local function servicesSubmenu(services)
  return M.chain(services)
    :map(function(i, service)
      local state, text = serviceMenuProps(service)

      return {
        title = util.fmt("%s %s", service.name, text),
        state = state,
        onStateImage = ui.icons.running,
        offStateImage = ui.icons.stopped,
        mixedStateImage = ui.icons.unknown,
        menu = {
          { 
            title = util.fmt("Start %s", service.name),
            fn = function()
              service:start()
            end
          },
          { 
            title = util.fmt("Stop %s", service.name),
            fn = function()
              service:stop()
            end
          },
          { 
            title = util.fmt("Restart %s", service.name),
            fn = function()
              service:restart()
            end
          },
        }
      }
    end)
    :value()
end

local function mapCommands(cmds)
  return M.chain({ "desktop", "general"})
    :map(function(i, section)
      return M.filter(cmds, function(j, cmd)
        return cmd.menubar and cmd.menubar[1] == section
      end)
    end)
    :flatten(1)
    -- :tap(function(...) log.d(hs.inspect(table.unpack{...})) end)
    :map(function(i, cmd)
      log.d(i, hs.inspect(cmd))
      return {
        title = cmd.title,
        shortcut = cmd.menubar[2] or nil,
        image = cmd.menubar[3] or nil,
        fn = function()
          cmd.fn({ type = 'menuclick' })
        end
      }
    end)
    :value()
end


local MenuBar = {
  installMenuBar = function(cmds)
    local menuitems = {
      textMenuItem("Just some text"),
    }

    table.insert(menuitems, textMenuItem("-"))
    menuitems = util.concat(menuitems, mapCommands(cmds))
    
    table.insert(menuitems, textMenuItem("-"))
    table.insert(menuitems, {
      title = "Services",
      menu = servicesSubmenu(KittySupreme.services),
      image = ui.icons.term,
    })


    log.d("Menu Items:", hs.inspect(menuitems))

    local mb = hs.menubar.new(true, "kittysupreme")

    if (mb == nil) then
      return false
    end

    local windows = M.map(desktop.allWindows(), function (name)
      return { title = "Hardcoded Window" }
    end)

    mb:setMenu(menuitems):setTitle('KS'):setIcon(ui.icons.kitty)

    if (mb == nil) then
      error("Could not create menubaritem")
    end
  end

}

return MenuBar