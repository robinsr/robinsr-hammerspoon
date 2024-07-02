local desktop = require 'user.lua.interface.desktop'
local alert   = require 'user.lua.interface.alert'
local lists   = require 'user.lua.lib.list'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local proto   = require 'user.lua.lib.proto'
local colors  = require 'user.lua.ui.color'
local icons   = require 'user.lua.ui.icons'
local image   = require 'user.lua.ui.image'
local text    = require 'user.lua.ui.text'
local symbols = require 'user.lua.ui.symbols'


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


local log = require('user.lua.util.logger').new('menubar', 'info')


local service_state_icons = {
  onStateImage = image.from_icon('circle.fill', 12, colors.green),
  offStateImage = image.from_icon('circle.fill', 12, colors.red),
  mixedStateImage = image.from_icon('circle.fill', 12, colors.lightgrey),
}

local EVT_FILTER = '!*.(evt|event|events).*'


--
-- Creates a text-only, placeholder-like menu item
--
---@param text string
---@return HS.MenubarItem
local function text_item(text)
  return {
    title = text,
    image = image.from_icon('info'),
    disabled = true,
  }
end


--
---@param title string
---@param icon_name string
---@param menu_items HS.MenubarItem[]
---@return HS.MenubarItem
function submenu_item(title, icon_name, menu_items)
  return {
    title = title,
    menu = menu_items,
    image = image.from_icon('term'),
  }
end


--
-- Maps a set of `Command` items to `HS.MenubarItem` items.
--
---@param sections string[]
---@param cmds Command[]
---@return HS.MenubarItem[]
local function menu_section(sections, cmds)

  ---@type HS.MenubarItem[]
  return lists(sections):map(function(section)

    local section_glob = strings.glob({ section, EVT_FILTER })

    log.df("Mapping menubar section %s", section)

    return lists(cmds):map(function(cmd)
        return section_glob(cmd.id) and cmd:as_menu_item() or false
    end)
    :filter(types.is_not.False):values()
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



--
-- Returns a menuitem to invoke a no-arg function on target object
--
---@param target table
---@param fn string
---@param target_name? string
---@return HS.MenubarItem
local service_fn_menuitem = function(target, fn, target_name)

  target_name = target_name or target['name'] or 'Unknown'

  local fn_not_found = function()
    log.ef('No method "%s" on service %s', fn, target_name)
  end

  local invoke = function()
    log.f('Calling function %s on service %s', fn, target_name)
    target[fn](target)
  end

  local title = strings.titlefmt("%s %s", fn, target_name)
  local hasFn = types.isFunc(target[fn])
  
  return {
    title = title,
    disabled = not hasFn,
    fn = hasFn and invoke or fn_not_found,
  }
end


--
-- Returns a submenu with another submenu for each service in `KittySupreme.services` table
--
---@param services table[]
---@return HS.MenubarItem
local function create_service_submenu(services)
  return lists(services):map(function(service)
    local state, text = serviceMenuProps(service)

    local subitems = lists({})

    local servicecmds = menu_section({ service.name .. '.*' }, KittySupreme.commands)

    if (#servicecmds > 0) then
      subitems:concat(servicecmds)
      subitems:push(text_item'-')
    end

    subitems:push(service_fn_menuitem(service, "start"))
    subitems:push(service_fn_menuitem(service, "stop"))
    subitems:push(service_fn_menuitem(service, "restart"))


    ---@type HS.MenubarItem
    return tables.merge({}, service_state_icons, {
      title = strings.fmt("%s %s", service.name, text),
      state = state,
      menu = subitems.items,
    })
  end):values()
end





local MenuBar = {}

--
-- Adds the main KS menu to the menubar
--
function MenuBar.install()

  local cmds = KittySupreme.commands
  local services = tables.vals(KittySupreme.services)

  local service_menu = submenu_item("Services", 'term', create_service_submenu(services))


  local getItems = function(keymods)
    log.f('KS menubar clicked with modifier keys: %s', hs.inspect(keymods))

    local menuitems = lists({})
      :push(text_item("Just some text"))
      :push(text_item("-"))
      :concat(menu_section({ "spaces.space.*", "apps.*" }, cmds))
      :push(text_item("-"))
      :push(service_menu)
      :push(text_item("-"))
      :concat(menu_section({ "ks.commands.*" }, cmds))

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
  ksmbar:setIcon(image.from_icon('kitty'))

  KittySupreme.menubar = ksmbar
end

return MenuBar