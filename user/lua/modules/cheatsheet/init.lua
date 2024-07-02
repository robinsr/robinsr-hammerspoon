local lists   = require 'user.lua.lib.list'
local strings = require 'user.lua.lib.string'
local appls   = require 'user.lua.model.application'
local hotkey  = require 'user.lua.model.hotkey'
local webview = require 'user.lua.ui.webview.webview'
local icons   = require 'user.lua.ui.icons'


local cheat = {}

cheat.cmds = {
  {
    id = 'ks.commands.show_ks_hotkeys',
    title = "Show hotkeys for KittySupreme",
    icon = "kitty",
    key = "\\",
    mods = "btms",
    exec = function(cmd)
      local groups = KittySupreme.commands
        :filter(function(cmd) return not cmd:has_flag('hidden') end)
        :filter(function(cmd) return cmd:hasHotkey() end)
        :groupBy(function(cmd)
            local key = (cmd.module or '')
            :gsub('user%.lua%.', '')
            :gsub('modules%.', '')
            :gsub('%.', ' → ')

          return strings.ifEmpty(key, 'Init')
        end)


      local model = {
        title = "KittySupreme Hotkeys",
        mods = hotkey.presets,
        symbols = icons.keys:toplain(),
        groups = groups,
      }

      webview.file("cheatsheet.view", model, model.title)
    end,
  },
  {
    title = "Show Hotkeys for current app",
    id = "cheatsheet.show.active",
    key = "K",
    mods = "btms",
    exec = function(cmd, ctx)

      local focusedApp= hs.window.frontmostWindow():application()
      local app = hs.application.frontmostApplication()
      local title = app:title()
      
      local menus = lists(app:getMenuItems()):map(function(m)
        local item =  appls.menuItem(m)

        local function reduce(memo, child_item)
          if child_item.has_children then
            for i,child in ipairs(child_item.children) do
              reduce(memo, child)
            end
          else
            table.insert(memo, child_item)
          end
          return memo
        end

        return { title = item.title, cmds = reduce({}, item.children) }
      end)
      -- :groupBy('title')


      print(hs.inspect(menus))

      local model = {
        title = "Hotkeys for " .. title,
        mods = hotkey.presets,
        symbols = icons.keys,
        groups = menus,
      }


      webview.page("json.view", model, model.title)
    end
  }
}

return cheat