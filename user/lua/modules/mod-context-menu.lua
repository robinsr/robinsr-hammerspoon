return {
  cmds = {
    {
      id = 'ks.commands.ctx-menu',
      title = 'Test context menu',
      flags = { 'no-chooser' },
      icon = 'info',
      exec = function(cmd, ctx, params)
        local ctxmenu = hs.menubar.new(false)

        if ctxmenu == nil then
          error('Error creating context menu')
        end

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

        ctxmenu:popupMenu(hs.mouse:absolutePosition())
      end,
    }
  }
}
