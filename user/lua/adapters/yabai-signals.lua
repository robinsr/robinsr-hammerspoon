
---@enum ks.signal.channel
local yabai_signal = {
  app_launched             = 'ks:app:launched',
  app_terminated           = 'ks:app:terminated',
  app_switched             = 'ks:app:switched',
  app_activated            = 'ks:app:activated',
  app_deactivated          = 'ks:app:deactivated',
  app_visible              = 'ks:app:visible',
  app_hidden               = 'ks:app:hidden',
  window_created           = 'ks:window:created',
  window_destroyed         = 'ks:window:destroyed',
  window_focused           = 'ks:window:focused',
  window_moved             = 'ks:window:moved',
  window_resized           = 'ks:window:resized',
  window_minimized         = 'ks:window:minimized',
  window_deminimized       = 'ks:window:deminimized',
  window_title_changed     = 'ks:window:title_changed',
  space_created            = 'ks:space:created',
  space_destroyed          = 'ks:space:destroyed',
  space_changed            = 'ks:space:changed',
  screen_added             = 'ks:screen:added',
  screen_removed           = 'ks:screen:removed',
  screen_moved             = 'ks:screen:moved',
  screen_resized           = 'ks:screen:resized',
  screen_changed           = 'ks:screen:changed',
  mission_control_enter    = 'ks:mission_control:enter',
  mission_control_exit     = 'ks:mission_control:exit',
  dock_did_change_pref     = 'ks:dock:did_change_pref',
  dock_did_restart         = 'ks:dock:did_restart',
  menu_bar_hidden_changed  = 'ks:menu_bar_hidden:changed',
  system_woke              = 'ks:system:woke',
}


---@alias yabai.signal.event
---|'application_launched'
---|'application_terminated'
---|'application_front_switched'
---|'application_activated'
---|'application_deactivated'
---|'application_visible'
---|'application_hidden'
---|'window_created'
---|'window_destroyed'
---|'window_focused'
---|'window_moved'
---|'window_resized'
---|'window_minimized'
---|'window_deminimized'
---|'window_title_changed'
---|'space_created'
---|'space_destroyed'
---|'space_changed'
---|'display_added'
---|'display_removed'
---|'display_moved'
---|'display_resized'
---|'display_changed'
---|'mission_control_enter'
---|'mission_control_exit'
---|'dock_did_change_pref'
---|'dock_did_restart'
---|'menu_bar_hidden_changed'
---|'system_woke'



-- A table of variable names populated by Yabai on a signal event. The table's
-- values should match the expected shell environment variable name, while the keys
-- can be anything
---@alias yabai.signal.variables table<string, string>


---@class yabai.signal.config
---@field channel ks.signal.channel       - The internal, namespaced identifier for a signal
---@field event   yabai.signal.event      - One of the signal types accepted by Yabai
---@field vars    yabai.signal.variables  - see `yabai.signal.variables`


---@type yabai.signal.config[]
local signal_confg = {
  -- Triggered when a new application is launched.
  -- Eligible for app filter.
  {
    channel = 'ks:app:launched',
    event = 'application_launched',
    vars = {
      id = 'YABAI_PROCESS_ID'
    }
  },

  -- Triggered when an application is terminated.
  -- Eligible for app and active filter.
  {
    channel = 'ks:app:terminated',
    event = 'application_terminated',
    vars = {
      id = 'YABAI_PROCESS_ID'
    }
  },

  -- Triggered when the front-most application changes.
  {
    channel = 'ks:app:switched',
    event = 'application_front_switched',
    vars = {
      id =  'YABAI_PROCESS_ID',
      prevId = 'YABAI_RECENT_PROCESS_ID'
    }
  },

  -- Triggered when an application is activated.
  -- Eligible for app filter.
  {
    channel = 'ks:app:activated',
    event = 'application_activated',
    vars = {
      processId = 'YABAI_PROCESS_ID'
    }
  },

  -- Triggered when an application is deactivated.
  -- Eligible for app filter.
  {
    channel = 'ks:app:deactivated',
    event = 'application_deactivated',
    vars = {
      id = 'YABAI_PROCESS_ID'
    }
  },

  -- Triggered when an application is unhidden.
  -- Eligible for app filter.
  {
    channel = 'ks:app:visible',
    event = 'application_visible',
    vars = {
      id = 'YABAI_PROCESS_ID'
    }
  },

  -- Triggered when an application is hidden.
  -- Eligible for app and active filter.
  {
    channel = 'ks:app:hidden',
    event = 'application_hidden',
    vars = {
      id = 'YABAI_PROCESS_ID'
    }
  },

  -- Triggered when a window is created.
  -- Eligible for app and title filter.
  -- Also applies to windows that are implicitly created at application launch.
  {
    channel = 'ks:window:created',
    event = 'window_created',
    vars = {
      id = 'YABAI_WINDOW_ID'
    }
  },

  -- Triggered when a window is destroyed.
  -- Eligible for app and active filter.
  -- Also applies to windows that are implicitly destroyed at application exit.
  {
    channel = 'ks:window:destroyed',
    event = 'window_destroyed',
    vars = {
      id = 'YABAI_WINDOW_ID'
    }
  },

  -- Triggered when a window becomes the key-window.
  -- Eligible for app and title filter.
  {
    channel = 'ks:window:focused',
    event = 'window_focused',
    vars = {
      id = 'YABAI_WINDOW_ID'
    }
  },

  -- Triggered when a window changes position.
  -- Eligible for app, title and active filter.
  {
    channel = 'ks:window:moved',
    event = 'window_moved',
    vars = {
      id = 'YABAI_WINDOW_ID'
    }
  },

  -- Triggered when a window changes dimensions.
  -- Eligible for app, title and active filter.
  {
    channel = 'ks:window:resized',
    event = 'window_resized',
    vars = {
      id = 'YABAI_WINDOW_ID'
    }
  },

  -- Triggered when a window has been minimized.
  -- Eligible for app, title and active filter.
  {
    channel = 'ks:window:minimized',
    event = 'window_minimized',
    vars = {
      id = 'YABAI_WINDOW_ID'
    }
  },

  -- Triggered when a window has been deminimized.
  -- Eligible for app and title filter.
  {
    channel = 'ks:window:deminimized',
    event = 'window_deminimized',
    vars = {
      id = 'YABAI_WINDOW_ID'
    }
  },

  -- Triggered when a window changes its title.
  -- Eligible for app, title and active filter.
  {
    channel = 'ks:window:title_changed',
    event = 'window_title_changed',
    vars = {
      id = 'YABAI_WINDOW_ID'
    }
  },

  -- Triggered when a space is created.
  {
    channel = 'ks:space:created',
    event = 'space_created',
    vars = {
      id = 'YABAI_SPACE_ID',
      index = 'YABAI_SPACE_INDEX'
    }
  },

  -- Triggered when a space is destroyed.
  {
    channel = 'ks:space:destroyed',
    event = 'space_destroyed',
    vars = {
      id = 'YABAI_SPACE_ID'
    }
  },

  -- Triggered when the active space has changed.
  {
    channel = 'ks:space:changed',
    event = 'space_changed',
    vars = {
      id = 'YABAI_SPACE_ID',
      index = 'YABAI_SPACE_INDEX',
      prevId = 'YABAI_RECENT_SPACE_ID',
      prevIndex = 'YABAI_RECENT_SPACE_INDEX',
    }
  },

  -- Triggered when a new display has been added.
  {
    channel = 'ks:screen:added',
    event = 'display_added',
    vars = {
      id = 'YABAI_DISPLAY_ID',
      index = 'YABAI_DISPLAY_INDEX',
    }
  },

  -- Triggered when a display has been removed.
  {
    channel = 'ks:screen:removed',
    event = 'display_removed',
    vars = {
      id = 'YABAI_DISPLAY_ID'
    }
  },

  -- Triggered when a change has been made to display arrangement.
  {
    channel = 'ks:screen:moved',
    event = 'display_moved',
    vars = {
      id = 'YABAI_DISPLAY_ID',
      index =  'YABAI_DISPLAY_INDEX',
    }
  },

  -- Triggered when a display has changed resolution.
  {
    channel = 'ks:screen:resized',
    event = 'display_resized',
    vars = {
      id = 'YABAI_DISPLAY_ID',
      index =  'YABAI_DISPLAY_INDEX',
    }
  },

  -- Triggered when the active display has changed.
  {
    channel = 'ks:screen:changed',
    event = 'display_changed',
    vars = {
      id = 'YABAI_DISPLAY_ID',
      index =  'YABAI_DISPLAY_INDEX',
      prevId =  'YABAI_RECENT_DISPLAY_ID',
      prevIndex = 'YABAI_RECENT_DISPLAY_INDEX' ,
    }
  },

  -- Triggered when mission-control activates.
  {
    channel = 'ks:mission_control:enter',
    event = 'mission_control_enter',
    vars = {
      mode = 'YABAI_MISSION_CONTROL_MODE'
    }
  },

  -- Triggered when mission-control deactivates.
  {
    channel = 'ks:mission_control:exit',
    event = 'mission_control_exit',
    vars = {
      mode = 'YABAI_MISSION_CONTROL_MODE'
    }
  },

  -- Triggered when the macOS Dock preferences changes.
  {
    channel = 'ks:dock:did_change_pref',
    event = 'dock_did_change_pref',
    vars = {}
  },

  -- Triggered when Dock.app restarts.
  {
    channel = 'ks:dock:did_restart',
    event = 'dock_did_restart',
    vars = {}
  },

  -- Triggered when the macOS menubar autohide setting changes.
  {
    channel = 'ks:menu_bar_hidden:changed',
    event = 'menu_bar_hidden_changed',
    vars = {}
  },

  -- Triggered when macOS wakes from sleep.
  {
    channel = 'ks:system:woke',
    event = 'system_woke',
    vars = {}
  }
}

return signal_confg