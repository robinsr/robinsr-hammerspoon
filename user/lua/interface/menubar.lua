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
    image = ui.menuIcon('info'),
    disabled = true,
  }
end


---@param sections string[]
---@param cmds Command[]
---@return MenubarItem[]
local function mapCommands(sections, cmds)

  ---@type MenubarItem[]
  local mapped = lists.reduce(sections, {}, function(all, section)

    log.df("Mapping menubar section %s", section)

    local sectionCmds = lists.filter(cmds, function(cmd)
      return cmd:getMenuSection() == section
    end)

    lists.forEach(sectionCmds, function(cmd)
      table.insert(all, {
        title = cmd.title,
        shortcut = cmd.key or nil,
        image = cmd:getMenuIcon() or nil,
        fn = function()
          local result = cmd:invoke('menu', {})

          if result ~= nil then
            alert:new(result):show()
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


---@return MenubarItem
local function servicesSubmenu()
  local services = lists(tables.vals(KittySupreme.services))

  local menuitems = services:map(function(service)
    local state, text = serviceMenuProps(service)

    local subitems = lists()

    local servicecmds = mapCommands({ service.name }, KittySupreme.commands)

    if (#servicecmds > 0) then
      subitems:push(table.unpack(servicecmds))
      subitems:push(textMenuItem'-')
    end


    subitems:push({ 
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
    image = ui.menuIcon('term'),
  }
end


local MenuBar = {}

--
-- Adds the main KS menu to the menubar
--
---@param cmds Command[]
---@return nil
function MenuBar.install(cmds)

  local getItems = function(keymods)
    log.f('KS menubar clicked with modifier keys: %s', hs.inspect(keymods))

    ---@type MenubarItem[]
    local menuitems = lists({})
      :push(textMenuItem("Just some text"))
      :push(textMenuItem("-"))
      :push(table.unpack(mapCommands({ "Spaces", "Apps" }, cmds)))
      :push(textMenuItem("-"))
      :push(servicesSubmenu())
      :push(textMenuItem("-"))
      :push(table.unpack(mapCommands({ "KS" }, cmds)))

    log.inspect('KittySupreme menu items:', menuitems, { depth = 3 })

    return menuitems
  end


  ---@type hs.menubar|nil
  local ksmbar = hs.menubar.new(true, "kittysupreme")

  if (ksmbar == nil) then
    error('Could not create menubar')
  end

  ksmbar:setMenu(getItems)
  ksmbar:setTitle('KS')
  ksmbar:setIcon(ui.menuIcon('kitty'))

  KittySupreme.menubar = ksmbar
end

return MenuBar