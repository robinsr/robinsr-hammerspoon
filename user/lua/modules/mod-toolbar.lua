-- local toolbar = require("hs.webview.toolbar")

-- local toolbar_items = {
--   {
--     id = "select1",
--     selectable = true, image = hs.image.imageFromName("NSStatusAvailable")
--   },
--   {
--     id = "NSToolbarSpaceItem"
--   },
--   {
--     id = "select2",
--     selectable = true, image = hs.image.imageFromName("NSStatusUnavailable")
--   },
--   {
--     id = "notShown",
--     default = false, image = hs.image.imageFromName("NSBonjour")
--   },
--   {
--     id = "NSToolbarFlexibleSpaceItem"
--   },
--   {
--     id = "navGroup",
--     label = "Navigation", groupMembers = { "navLeft", "navRight" }
--   },
--   {
--     id = "navLeft",
--     image = hs.image.imageFromName("NSGoLeftTemplate"),
--     allowedAlone = false
--   },
--   {
--     id = "navRight",
--     image = hs.image.imageFromName("NSGoRightTemplate"),
--     allowedAlone = false
--   },
--   {
--     id = "NSToolbarFlexibleSpaceItem",
--   },
--   {
--     id = "cust",
--     label = "customize",
--     image = hs.image.imageFromName("NSAdvanced"),
--     fn = function(t, w, i)
--       t:customizePanel()
--     end,
--   }
-- }

-- local my_toolbar = toolbar.new("myConsole", toolbar_items)

-- my_toolbar:canCustomize(true)
-- my_toolbar:autosaves(true)
-- my_toolbar:selectedItem("select2")
-- my_toolbar:setCallback(function(...)
--   print("a", hs.inspect(table.pack(...)))
-- end)

-- toolbar.attachToolbar(my_toolbar)