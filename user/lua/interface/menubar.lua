local M       = require 'moses'
local desktop = require 'user.lua.interface.desktop'
local alert   = require 'user.lua.interface.alert'
local ui      = require 'user.lua.ui'
local symbols = require 'user.lua.ui.symbols'
local U       = require 'user.lua.util'
local list    = require 'user.lua.lib.list'



---@class MenubarItem
---@field title string
---@field fn? fun(mods: table, thisItem: MenubarItem)
---@field checked? boolean
---@field state? 'on'|'off'|'mixed'
---@field disabled? boolean
---@field menu? MenubarItem[] 
---@field image? hs.image
---@field tooltip? string
---@field shortcut? string
---@field indent? integer
---@field onStateImage? hs.image
---@field offStateImage? hs.image
---@field mixedStateImage? hs.image


local log = U.log('menubar', 'info')

---@param text string
---@return MenubarItem
local function textMenuItem(text)
  return {
    title = text,
    image = ui.icons.info,
    disabled = true,
  }
end


---@param sections string[]
---@param cmds Command[]
---@return MenubarItem[]
local function mapCommands(sections, cmds)

  ---@type MenubarItem[]
  local mapped = U.reduce({}, sections, function(all, section)

      log.df("Mapping menubar section %s", section)

      local sectionCmds = U.filter(cmds, function(cmd)
        return U.notNil(cmd.menubar) and cmd.menubar.section == section
      end)

      U.forEach(sectionCmds, function(cmd)
        table.insert(all, {
          title = cmd.title,
          shortcut = cmd.menubar.key or nil,
          image = cmd.menubar.icon or nil,
          fn = function()
            local result = cmd.fn({ type = 'menuclick' }, {})

            if U.notNil(result) then
              alert.alert(result)
            end
          end
        })
      end)

      return all
  end)

  return mapped
end


---@param service Service
---@return string, string
local function serviceMenuProps(service)
  if (service.pid) then
    return "on" , U.fmt("(%s)", service.pid)
  else
    return "off", ""
  end
end


---@param services Service[]
---@return MenubarItem[]
local function servicesSubmenu(services)
  local menuitems = U.map(services, function(service)
    local state, text = serviceMenuProps(service)

    local subitems = {}

    if (service.cmds ~= nil) then
      list.push(subitems, table.unpack(
        mapCommands({ service.name }, service.cmds)
      ))
      list.push(textMenuItem'-')
    end


    list.push(subitems, { 
      title = U.fmt("Start %s", service.name),
      fn = function() service:start() end,
    },
    { 
      title = U.fmt("Stop %s", service.name),
      fn = function()  service:stop() end,
    },
    { 
      title = U.fmt("Restart %s", service.name),
      fn = function() service:restart() end
    })


    ---@type MenubarItem
    return {
      title = U.fmt("%s %s", service.name, text),
      state = state,
      onStateImage = ui.icons.running,
      offStateImage = ui.icons.stopped,
      mixedStateImage = ui.icons.unknown,
      menu = subitems,
    }
  end)

  log.inspect(menuitems, { depth = 5 })

  return {
    title = "Services",
    menu = menuitems,
    image = ui.icons.term,
  }
end


local MenuBar = {}

--
-- Adds the main KS menu to the menubar
--
---@param cmds Command[]
---@return nil
function MenuBar.install(cmds)
  local menuitems = {}

  U.insert(menuitems, textMenuItem("Just some text"))
  U.insert(menuitems, textMenuItem("-"))
  U.insert(menuitems, table.unpack(mapCommands({ "desktop", "windows" }, cmds)))
  U.insert(menuitems, textMenuItem("-"))
  U.insert(menuitems, servicesSubmenu(U.vals(KittySupreme.services)))
  U.insert(menuitems, textMenuItem("-"))
  U.insert(menuitems, table.unpack(mapCommands({ "general" }, cmds)))

  log.logIf('debug', function()
    log.inspect('KittySupreme menu items:', menuitems, U.d3)
  end)

  local KSmenubar = hs.menubar.new(true, "kittysupreme")

  if (KSmenubar == nil) then
    error('Could not create menubar')
  end

  KSmenubar:setMenu(menuitems):setTitle('KS'):setIcon(ui.icons.kitty)

  KittySupreme.menubar = KSmenubar
end

return MenuBar