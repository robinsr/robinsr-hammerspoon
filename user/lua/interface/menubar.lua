local desktop = require 'user.lua.interface.desktop'
local alert   = require 'user.lua.interface.alert'
local lists   = require 'user.lua.lib.list'
local proto   = require 'user.lua.lib.proto'
local regex   = require 'user.lua.lib.regex'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local time    = require 'user.lua.lib.time'
local types   = require 'user.lua.lib.typecheck'
local colors  = require 'user.lua.ui.color'
local image   = require 'user.lua.ui.image'
local text    = require 'user.lua.ui.text'
local symbols = require 'user.lua.ui.symbols'


---@class hs.menu.item
---@field title               hs.anytext
---@field fn?                 hs.menu.callback
---@field menu?               hs.menu.item[] 
---@field image?              hs.image
---@field checked?            boolean
---@field disabled?           boolean
---@field tooltip?            string
---@field shortcut?           string
---@field indent?             integer
---@field state?              'on'|'off'|'mixed'
---@field onStateImage?       hs.image
---@field offStateImage?      hs.image
---@field mixedStateImage?    hs.image


---@alias hs.menu.callback fun(mods: table, item: hs.menu.item): nil


local log = require('user.lua.util.logger').new('menubar', 'info')


local service_state_icons = {
  onStateImage = image.fromIcon('circle.fill', 12, colors.green),
  offStateImage = image.fromIcon('circle.fill', 12, colors.red),
  mixedStateImage = image.fromIcon('circle.fill', 12, colors.lightgrey),
}

local EVT_FILTER = '!*.(evt|event|events).*'


--
-- Creates a text-only, placeholder-like menu item
--
---@param text string
---@param ... any Optional format string variables
---@return hs.menu.item
local function text_item(text, ...)
  local fmt_string_args = {...}
  local text = text or ("%q"):rep(#fmt_string_args, " - ")

  return {
    title = (text):format(table.unpack(fmt_string_args)),
    image = image.fromIcon('info'),
    disabled = true,
  }
end


--
---@param title string
---@param icon? string
---@param items hs.menu.item[]
---@return hs.menu.item
function submenu_item(title, icon, items)
  return {
    title = title,
    image = image.fromIcon(icon or 'term'),
    menu = items,
  }
end


--
-- Maps a set of `Command` items to `HS.MenubarItem` items.
--
---@param sections string[]
---@param cmds ks.command[]
---@return hs.menu.item[]
local function submenu_items(sections, cmds)

  ---@type hs.menu.item[]
  return lists(sections):map(function(section)

    local section_glob = regex.globs({ section, EVT_FILTER })

    log.df("Mapping menubar section %s", section)

    return lists(cmds):map(function(cmd)
      ---@cast cmd ks.command
      return section_glob(cmd.id) and cmd:asMenuItem() or false
    end)
    :filter(types.is_not.False):values()
  end):flatten():values()
end


---@param service ks.service
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
---@return hs.menu.item
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
---@return hs.menu.item
local function create_service_submenu(services)
  return lists(services):map(function(service)
    local state, text = serviceMenuProps(service)

    local subitems = lists({})

    local servicecmds = submenu_items({ service.name .. '.*' }, KittySupreme.commands:values())

    if (#servicecmds > 0) then
      subitems:concat(servicecmds)
      subitems:push(text_item'-')
    end

    subitems:push(service_fn_menuitem(service, "start"))
    subitems:push(service_fn_menuitem(service, "stop"))
    subitems:push(service_fn_menuitem(service, "restart"))


    --[[@as hs.menu.item]]
    return tables.merge({}, service_state_icons, {
      title = strings.fmt("%s %s", service.name, text),
      state = state,
      menu = subitems.items,

    })
  end):values()
end





local MenuBar = {}


function MenuBar.primary_items()
  local commands = KittySupreme.commands:values()
  local services = tables.vals(KittySupreme.services)


  local menuitems = lists({})
    :push(text_item("KittySupreme - uptime: %s", time.fmt_ago(_G.UpTime)))
    
    :push(text_item("-"))
    
    :concat(submenu_items({ "spaces.space.*", "apps.*" }, commands))
    
    :push(text_item("-"))
    
    :push(submenu_item(
      "Services", 'term', create_service_submenu(services)
    ))
    
    :push(text_item("-"))
    
    :push(submenu_item(
      "User", 'user', submenu_items({ "user.*" }, commands)
    ))
    :push(text_item("-"))

    :push(submenu_item(
      "KS Commands", "kitty", submenu_items({ "ks.commands.*" }, commands)
    ))

  log.inspect('KittySupreme menu items:', menuitems, { depth = 3 })

  return menuitems:values()
end


--
-- Adds the main KS menu to the menubar
--
function MenuBar.install()  
  local getItems = function(keymods)
    log.f('KS menubar clicked with modifier keys: %s', hs.inspect(keymods))

    return MenuBar.primary_items()
  end


  ---@type hs.menubar|nil
  local ksmbar = hs.menubar.new(true, "kittysupreme")

  if (ksmbar == nil) then
    error('Could not create menubar')
  end

  ksmbar:setMenu(getItems)
  ksmbar:setTitle('KS')
  ksmbar:imagePosition(1)
  ksmbar:setIcon(image.fromIcon('kitty'))

  KittySupreme.menubar = ksmbar
end

return MenuBar