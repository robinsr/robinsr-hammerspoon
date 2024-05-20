local M       = require 'moses'
local desktop = require 'user.lua.interface.desktop'
local alert   = require 'user.lua.interface.alert'
local lists   = require 'user.lua.lib.list'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local ui      = require 'user.lua.ui'
local symbols = require 'user.lua.ui.symbols'
local logr    = require 'user.lua.util.logger'



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


local log = logr.new('menubar', 'info')

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
  local mapped = lists.reduce({}, sections, function(all, section)

    log.df("Mapping menubar section %s", section)

    local sectionCmds = lists.filter(cmds, function(cmd)
      return types.notNil(cmd.menubar) and cmd.menubar.section == section
    end)

    lists.forEach(sectionCmds, function(cmd)
      table.insert(all, {
        title = cmd.title,
        shortcut = cmd.menubar.key or nil,
        image = cmd.menubar.icon or nil,
        fn = function()
          local result = cmd.fn({ type = 'menuclick' }, {})

          if result ~= nil then
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
    return "on" , strings.fmt("(%s)", service.pid)
  else
    return "off", ""
  end
end


---@param services Service[]
---@return MenubarItem[]
local function servicesSubmenu(services)
  local menuitems = lists.map(services, function(service)
    local state, text = serviceMenuProps(service)

    local subitems = {}

    if (service.cmds ~= nil) then
      lists.push(subitems, table.unpack(
        mapCommands({ service.name }, service.cmds)
      ))
      lists.push(textMenuItem'-')
    end


    lists.push(subitems, { 
      title = strings.fmt("Start %s", service.name),
      fn = function() service:start() end,
    },
    { 
      title = strings.fmt("Stop %s", service.name),
      fn = function()  service:stop() end,
    },
    { 
      title = strings.fmt("Restart %s", service.name),
      fn = function() service:restart() end
    })


    ---@type MenubarItem
    return {
      title = strings.fmt("%s %s", service.name, text),
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

  lists.push(menuitems, textMenuItem("Just some text"))
  lists.push(menuitems, textMenuItem("-"))
  lists.push(menuitems, table.unpack(mapCommands({ "desktop", "windows" }, cmds)))
  lists.push(menuitems, textMenuItem("-"))
  lists.push(menuitems, servicesSubmenu(tables.vals(KittySupreme.services)))
  lists.push(menuitems, textMenuItem("-"))
  lists.push(menuitems, table.unpack(mapCommands({ "general" }, cmds)))

  log.logIf('debug', function()
    log.inspect('KittySupreme menu items:', menuitems, { depth = 3 })
  end)

  local KSmenubar = hs.menubar.new(true, "kittysupreme")

  if (KSmenubar == nil) then
    error('Could not create menubar')
  end

  KSmenubar:setMenu(menuitems):setTitle('KS'):setIcon(ui.icons.kitty)

  KittySupreme.menubar = KSmenubar
end

return MenuBar