return {
  cmds = {
    {
      id = 'ks.commands.ctx-menu',
      title = 'Test context menu',
      icon = 'info',
      exec = function(cmd, ctx, params)
        local ctxmenu = hs.menubar.new(false)

        ctxmenu:setMenu({
          {
            title = "test item 1",
            fn = function() end,
          },
          {
            title = "test item 2",
            fn = function() end,
          },
          {
            title = "test item 3",
            fn = function() end,
          }
        })

        ctxmenu:popupMenu(hs.geometry.point(100, 100))
      end,
    }
  }
}
