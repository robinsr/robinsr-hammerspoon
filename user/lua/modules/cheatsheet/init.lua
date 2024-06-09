local webview = require 'user.lua.ui.webview'

------------------------------------------------------------------------
--/ Cheatsheet Copycat /--
------------------------------------------------------------------------

local commandEnum = {
  [0] = '⌘',
  [1] = '⇧ ⌘',
  [2] = '⌥ ⌘',
  [3] = '⌥ ⇧ ⌘',
  [4] = '⌃ ⌘',
  [5] = '⇧ ⌃ ⌘',
  [6] = '⌃ ⌥ ⌘',
  [7] = '',
  [8] = '⌦',
  [9] = '',
  [10] = '⌥',
  [11] = '⌥ ⇧',
  [12] = '⌃',
  [13] = '⌃ ⇧',
  [14] = '⌃ ⌥',
}

function getAllMenuItemsTable(t)
  local menu = {}
  for pos, val in pairs(t) do
    if (type(val) == "table") then
      if (val['AXRole'] == "AXMenuBarItem" and type(val['AXChildren']) == "table") then
        menu[pos] = {}
        menu[pos]['AXTitle'] = val['AXTitle']
        menu[pos][1] = getAllMenuItems(val['AXChildren'][1])
      elseif (val['AXRole'] == "AXMenuItem" and not val['AXChildren']) then
        if (val['AXMenuItemCmdModifiers'] ~= '0' and val['AXMenuItemCmdChar'] ~= '') then
          menu[pos] = {}
          menu[pos]['AXTitle'] = val['AXTitle']
          menu[pos]['AXMenuItemCmdChar'] = val['AXMenuItemCmdChar']
          menu[pos]['AXMenuItemCmdModifiers'] = val['AXMenuItemCmdModifiers']
        end
      elseif (val['AXRole'] == "AXMenuItem" and type(val['AXChildren']) == "table") then
        menu[pos] = {}
        menu[pos][1] = getAllMenuItems(val['AXChildren'][1])
      end
    end
  end
  return menu
end


local list_partial = [==[
  {{#has_children}}
    <ul class='col col {{pos}}>
      <li class='title'><strong>{{title}}</strong></li>
      {{>list_partial}}
    </ul>
  {{/has_children}}
  {{^has_children}}
    <li>
      <div class='cmdModifiers'>{{mods}}</div></div>{{title}}<div class='cmdtext'>
    </li>
  {{/has_children}}
]==]

function getAllMenuItems(t)

  local template = lustache:render([[
    <div>
      {{#items}
        {{>list_partial}}
      {{/item}}
    </div>
  ]], {}, { list_partial = list_partial })

end

function generateHtml()
  --local focusedApp= hs.window.frontmostWindow():application()
  local focusedApp = hs.application.frontmostApplication()
  local appTitle = focusedApp:title()
  local allMenuItems = focusedApp:getMenuItems();
  local myMenuItems = getAllMenuItems(allMenuItems)

  local html = webview.show('Cheatsheet', 'cheatsheet', {})
end

local myView = nil

local CS = {}

CS.cmds = {
  {
    title = "Show Cheatsheet",
    id = "cheatsheet.show.active",
    key = "b",
    mods = "bar",
    exec = function(cmd, ctx)
      if not myView then
        myView = hs.webview.new({ x = 100, y = 100, w = 1080, h = 600 }, { developerExtrasEnabled = true })
            :windowStyle("utility")
            :closeOnEscape(true)
            :html(generateHtml())
            :allowGestures(true)
            :windowTitle("CheatSheets")
            :show()
      else
        myView:delete()
        myView = nil
      end
    end
  }
}

return CS
