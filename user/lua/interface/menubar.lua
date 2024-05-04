local M       = require 'moses'
local desktop = require 'user.lua.interface.desktop'
local ui      = require 'user.lua.ui'
local symbols = require 'user.lua.ui.symbols'
local U       = require 'user.lua.util'



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


local log = U.log('menubar', 'debug')

---@param text string
---@return MenubarItem
local function textMenuItem(text)
  return {
    title = text,
    image = ui.icons.info,
    disabled = true,
  }
end

---@param service Service
---@return string, string
local function serviceMenuProps(service)
  if (service.pid) then
    return "on" , "("..service.pid..")"
  else
    return "off", "(?)"
  end
end


---@param services Service[]
---@return MenubarItem[]
local function servicesSubmenu(services)
  local menuitems = U.map(services, function(service)
    local state, text = serviceMenuProps(service)

    ---@type MenubarItem
    return {
      title = U.fmt("%s %s", service.name, text),
      state = state,
      onStateImage = ui.icons.running,
      offStateImage = ui.icons.stopped,
      mixedStateImage = ui.icons.unknown,
      menu = {
        { 
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
        },
      }
    }
  end)

  return {
    title = "Services",
    menu = menuitems,
    image = ui.icons.term,
  }
end


---@param cmds Command[]
---@return MenubarItem[]
local function mapCommands(cmds)

  ---@type MenubarItem[]
  local mapped = U.reduce({}, { "desktop", "general"}, function(all, section)

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
            cmd.fn({ type = 'menuclick' }, {})
          end
        })
      end)

      return all
  end)

  return mapped
end


local MenuBar = {

  --
  -- Installs the main KS menubar item
  --
  ---@param cmds Command[]
  ---@return nil
  installMenuBar = function(cmds)

    -- local menuitems = {
    --   textMenuItem("Just some text"),
    --   textMenuItem("-"),
    --   table.unpack(mapCommands(cmds)),
    --   textMenuItem("-"),
    --   servicesSubmenu(KittySupreme.services),
    -- }

    local menuitems = U.reduce({}, {
      textMenuItem("Just some text"),
      textMenuItem("-"),
      mapCommands(cmds),
      textMenuItem("-"),
      servicesSubmenu(KittySupreme.services),
    }, function(all, menus)
      return U.insert(all, menus)
    end)
    -- 
    -- U.insert(menuitems, )
    -- U.insert(menuitems, )
    -- U.insert(menuitems, )
    -- U.insert(menuitems, )


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

}

return MenuBar