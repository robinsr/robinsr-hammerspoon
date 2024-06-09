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


local ICONS = {
  onStateImage = icons.menuIcon('circle.fill', colors.green),
  offStateImage = icons.menuIcon('circle.fill', colors.red),
  mixedStateImage = icons.menuIcon('circle.fill', colors.lightgrey),
}

local EVT_FILTER = '!*.(evt|event|events).*'

---@enum KS.MODS
local MODS = {
  alt = '⌥',
  cmd = '⌘',
  ctrl = '⌃',
  fn = 'fn',
  shift = '⇧',
}


---@param text string
---@return MenubarItem
local function textMenuItem(text)
  return {
    title = text,
    image = icons.menuIcon('info'),
    disabled = true,
  }
end


---@param sections string[]
---@param cmds Command[]
---@return MenubarItem[]
local function mapCommands(sections, cmds)

  ---@type MenubarItem[]
  return lists(sections):map(function(section)

    local section_glob = strings.glob({ section, EVT_FILTER })

    log.df("Mapping menubar section %s", section)

    return lists(cmds)
      :filter(function(cmd)
        return section_glob(cmd.id)
      end)
      :map(function(cmd)
        local title = cmd.title or cmd.id
        local subtext = cmd:hasHotkey() and cmd:getHotkey():label() or ''
        
        return {
          title = text.textAndHint(title, subtext),
          shortcut = cmd.menukey,
          image = cmd:getMenuIcon() or nil,
          fn = function()
            cmd:invoke('menu', {})
          end
        }
      end):values()
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


---@return MenubarItem
local function servicesSubmenu()
  local services = lists(tables.vals(KittySupreme.services))

  local menuitems = services:map(function(service)
    local state, text = serviceMenuProps(service)

    local subitems = lists()

    local servicecmds = mapCommands({ service.name .. '.*' }, KittySupreme.commands)

    if (#servicecmds > 0) then
      subitems:concat(servicecmds)
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
    return tables.merge({}, ICONS, {
      title = strings.fmt("%s %s", service.name, text),
      state = state,
      menu = subitems.items,
    })
  end)

  log.inspect(menuitems, { depth = 5 })

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
      :concat(mapCommands({ "spaces.*", "apps.*" }, cmds))
      :push(textMenuItem("-"))
      :push(servicesSubmenu())
      :push(textMenuItem("-"))
      :concat(mapCommands({ "ks.commands.*" }, cmds))

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