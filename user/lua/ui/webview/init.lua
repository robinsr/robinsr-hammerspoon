local webview = require 'user.lua.ui.webview.webview'


local webinit = {}

webinit.cmds = {
  {
    id = 'ks.commands.showHotkeys',
    title = "Show Hotkeys for KittySupreme",
    key = "F",
    mods = "bar",
    exec = function(cmd)
      local model = {
        title = "KittySupreme Hotkeys",
        groups = KittySupreme.commands:groupBy('module')
      }

      webview.page("status", model, model.title)
    end,
  },
}


return webinit
