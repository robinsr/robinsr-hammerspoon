local lustache = require 'lustache'

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

  local html = [[
        <!DOCTYPE html>
        <html>
        <head>
        <style type="text/css">
            *{margin:0; padding:0;}
            html, body{
              background-color:#eee;
              font-family: arial;
              font-size: 13px;
            }
            a{
              text-decoration:none;
              color:#000;
              font-size:12px;
            }
            li.title{ text-align:center;}
            ul, li{list-style: inside none; padding: 0 0 5px;}
            footer{
              position: fixed;
              left: 0;
              right: 0;
              height: 48px;
              background-color:#eee;
            }
            header{
              position: fixed;
              top: 0;
              left: 0;
              right: 0;
              height:48px;
              background-color:#eee;
              z-index:99;
            }
            footer{ bottom: 0; }
            header hr,
            footer hr {
              border: 0;
              height: 0;
              border-top: 1px solid rgba(0, 0, 0, 0.1);
              border-bottom: 1px solid rgba(255, 255, 255, 0.3);
            }
            .title{
                padding: 15px;
            }
            li.title{padding: 0  10px 15px}
            .content{
              padding: 0 0 15px;
              font-size:12px;
              overflow:hidden;
            }
            .content.maincontent{
            position: relative;
              height: 577px;
              margin-top: 46px;
            }
            .content > .col{
              width: 23%;
              padding:10px 0 20px 20px;
            }

            li:after{
              visibility: hidden;
              display: block;
              font-size: 0;
              content: " ";
              clear: both;
              height: 0;
            }
            .cmdModifiers{
              width: 60px;
              padding-right: 15px;
              text-align: right;
              float: left;
              font-weight: bold;
            }
            .cmdtext{
              float: left;
              overflow: hidden;
              width: 165px;
            }
        </style>
        </head>
          <body>
            <header>
              <div class="title"><strong>]] .. appTitle .. [[</strong></div>
              <hr />
            </header>
            <div class="content maincontent">]] .. myMenuItems .. [[</div>

          <footer>
            <hr />
              <div class="content" >
                <div class="col">
                  by <a href="https://github.com/dharmapoudel" target="_parent">dharma poudel</a>
                </div>
              </div>
          </footer>
          <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.isotope/2.2.2/isotope.pkgd.min.js"></script>
          <script type="text/javascript">
              var elem = document.querySelector('.content');
              var iso = new Isotope( elem, {
                // options
                itemSelector: '.col',
                layoutMode: 'masonry'
              });
            </script>
          </body>
        </html>
        ]]

  return html
end

local myView = nil

local CS = {}

CS.cmds = {
  {
    title = "Cheatsheet",
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
        --myView:asHSWindow():focus()
        --myView:asHSDrawing():setAlpha(.98):bringToFront()
      else
        myView:delete()
        myView = nil
      end
    end
  }
}

return CS
