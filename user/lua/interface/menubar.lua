local desktop = require 'user.lua.interface.desktop'
local alert   = require 'user.lua.interface.alert'
local lists   = require 'user.lua.lib.list'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local colors  = require 'user.lua.ui.color'
local icons   = require 'user.lua.ui.icons'
local text    = require 'user.lua.ui.text'
local symbols = require 'user.lua.ui.symbols'
local logr    = require 'user.lua.util.logger'



---@class HS.MenubarItem
---@field title string
---@field fn? fun(mods: table, thisItem: HS.MenubarItem)
---@field checked? boolean
---@field state? 'on'|'off'|'mixed'
---@field disabled? boolean
---@field menu? HS.MenubarItem[] 
---@field image? hs.image
---@field tooltip? string
---@field shortcut? string
---@field indent? integer
---@field onStateImage? hs.image
---@field offStateImage? hs.image
---@field mixedStateImage? hs.image


local log = logr.new('menubar', 'info')


local service_state_icons = {
  onStateImage = icons.menuIcon('circle.fill', colors.green),
  offStateImage = icons.menuIcon('circle.fill', colors.red),
  mixedStateImage = icons.menuIcon('circle.fill', colors.lightgrey),
}

local EVT_FILTER = '!*.(evt|event|events).*'


--
-- Creates a text-only, placeholder-like menu item
--
---@param text string
---@return HS.MenubarItem
local function textMenuItem(text)
  return {
    title = text,
    image = icons.menuIcon('info'),
    disabled = true,
  }
end



--
-- Creates a HS.MenubarItem for a Command
--
---@param cmd Command
---@return HS.MenubarItem
local function mapCommand(cmd)
  local title = cmd.title or cmd.id
  local subtext = cmd:hasHotkey() and cmd:getHotkey():label() or ''

  ---@type HS.MenubarItem
  local menuitem = {
    title = text.textAndHint(title, subtext),
    shortcut = cmd.menukey,
    image = cmd:getMenuIcon() or nil,
    fn = function()
      cmd:invoke('menu', {})
    end
  }
  
  return menuitem
end



--
-- Maps a set of `Command` items to `HS.MenubarItem` items.
--
---@param sections string[]
---@param cmds Command[]
---@return HS.MenubarItem[]
local function getMenuitemsForSection(sections, cmds)

  ---@type HS.MenubarItem[]
  return lists(sections):map(function(section)

    local section_glob = strings.glob({ section, EVT_FILTER })

    log.df("Mapping menubar section %s", section)

    return lists(cmds)
      :filter(function(cmd) return section_glob(cmd.id) end)
      :map(mapCommand):values()
  end):flatten():values()
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


---@return HS.MenubarItem
local function servicesSubmenu()
  local services = lists(tables.vals(KittySupreme.services))

  local menuitems = services:map(function(service)
    local state, text = serviceMenuProps(service)

    local subitems = lists({})

    local servicecmds = getMenuitemsForSection({ service.name .. '.*' }, KittySupreme.commands)

    if (#servicecmds > 0) then
      subitems:concat(servicecmds)
      subitems:push(textMenuItem'-')
    end

    local add_menuitem_for = function(service_fn, fn_name)
      local menuitem = {}

      menuitem.title = strings.tfmt("%s %s", fn_name, service.name)
      menuitem.disabled = true
      menuitem.fn = function() 
        log.ef('No method "%s" on service %s', fn_name, service.name)
      end

      if types.isFunc(service_fn) then
        menuitem.disabled = false
        menuitem.fn = function() 
          log.f('Calling function %s on service %s', fn_name, service.name)
          service_fn(service)
        end
      end

      return menuitem
    end

    subitems:push(add_menuitem_for(service.start, "start"))
    subitems:push(add_menuitem_for(service.stop, "stop"))
    subitems:push(add_menuitem_for(service.restart, "restart"))


    ---@type HS.MenubarItem
    return tables.merge({}, service_state_icons, {
      title = strings.fmt("%s %s", service.name, text),
      state = state,
      menu = subitems.items,
    })
  end)

  return {
    title = "Services",
    menu = menuitems:values(),
    image = icons.menuIcon('term'),
  }
end


local MenuBar = {}

--
-- Adds the main KS menu to the menubar
--
function MenuBar.install()

  local cmds = KittySupreme.commands

  local getItems = function(keymods)
    log.f('KS menubar clicked with modifier keys: %s', hs.inspect(keymods))

    local menuitems = lists({})
      :push(textMenuItem("Just some text"))
      :push(textMenuItem("-"))
      :concat(getMenuitemsForSection({ "spaces.space.*", "apps.*" }, cmds))
      :push(textMenuItem("-"))
      :push(servicesSubmenu())
      :push(textMenuItem("-"))
      :concat(getMenuitemsForSection({ "ks.commands.*" }, cmds))

    log.inspect('KittySupreme menu items:', menuitems, { depth = 3 })

    return menuitems:values()
  end


  ---@type hs.menubar|nil
  local ksmbar = hs.menubar.new(true, "kittysupreme")

  if (ksmbar == nil) then
    error('Could not create menubar')
  end

  ksmbar:setMenu(getItems)
  ksmbar:setTitle('KS')
  ksmbar:imagePosition(1)
  ksmbar:setIcon(icons.menuIcon('kitty'))

  KittySupreme.menubar = ksmbar
end

return MenuBar