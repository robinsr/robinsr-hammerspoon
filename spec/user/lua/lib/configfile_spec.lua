---@diagnostic disable: redundant-parameter
local tutil  = require 'spec.util'
local say = require 'say'

local fmt = tutil.fmt
local dump = tutil.dump



-- Lua tables are not ordered, so the config lines will come out  random.
-- Switch to a different structure or write regex asserts
local expected_rcfile = [[# Enable apple scripting addition

yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
sudo yabai --load-sa
# yabai configs

yabai -m config window_opacity off
# yabai -m config normal_window_opacity 0.9
yabai -m config auto_balance off
yabai -m config window_placement second_child
yabai -m config right_padding 12
# yabai -m config active_window_opacity 1.0
yabai -m config mouse_drop_action swap
yabai -m config split_ratio 0.62
yabai -m config window_gap 10
yabai -m config top_padding 12
yabai -m config mouse_action1 move
yabai -m config mouse_action2 resize
yabai -m config layout float
yabai -m config mouse_modifier alt
yabai -m config window_animation_easing ease_in_out_quint
yabai -m config window_animation_duration 0.3
yabai -m config left_padding 12
yabai -m config debug_output off
yabai -m config bottom_padding 12
yabai -m config mouse_follows_focus off
yabai -m config external_bar all:0:40]]



insulate("user.lua.lib.configfile #wip", function()

  package.loaded[tutil.logger_mod] = tutil.mock_logger(spy)

  local rcfile = require('user.lua.lib.rcfile')

  it("produces contents of a rc file ", function()

      local test_file_config = {
        id = 'yabairc',
        path = '~/.config/yabai/yabairc',
        consts_table = {
          prefix = 'yabai -m',
        },
        vars = {
          { 'PAD_X', 10 },
          { 'PAD_Y', 10 },
          { 'GAP', 10 },
          { 'BAR_TOP', 0 },
          { 'BAR_BTM', 40 },
        },
        types = {},
        sections = {
          {
            id = 'appl-script',
            name = 'Enable apple scripting addition',
            lines = {
              'yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"',
              'sudo yabai --load-sa'
            }
          },
          {
            id = 'config',
            name = 'Yabai configs',
            pattern = '{dis+}{consts.prefix} config {key}{+val}',
            type = 'optional_prop',
            data = {
              { 'debug_output',              'off' },
              { 'layout',                    'float' },
              { 'window_placement',          'second_child' },
              { 'external_bar',              'all:$BAR_TOP:$BAR_BTM' },
              { 'auto_balance',              'off' },
              { 'split_ratio',               0.62 },
              { 'window_opacity',            'off' },
              { 'active_window_opacity',     1.0, true },
              { 'normal_window_opacity',     0.9, true },
              { 'window_animation_duration', 0.3 },
              { 'window_animation_easing',   'ease_in_out_quint' },
              { 'top_padding',               '$PAD_Y' },
              { 'bottom_padding',            '$PAD_Y' },
              { 'left_padding',              '$PAD_X' },
              { 'right_padding',             '$PAD_X' },
              { 'window_gap',                 10 },
              { 'mouse_follows_focus',        'off' },
              { 'mouse_modifier',             'alt' },
              { 'mouse_action1',              'move' },
              { 'mouse_action2',              'resize' },
              { 'mouse_drop_action',          'swap' },
            }
          },
          {
            id = 'rules',
            name = 'Yabai Rules Config',
            pattern = '{consts.prefix} rules --add {props}',
            type = 'table_prop',
            data = {
              { app = "^Alfred.*$",         manage = 'off' },
              { app = "^Boop$",             manage = 'off' },
              { app = "^Bartender 5$",      manage = 'off' },
              { app = "^Calculator$",       manage = 'off' },
              { app = "^ColorSlurp$",       manage = 'off' },
              { app = "^Home$",             manage = 'off' },
              { app = "^Karabiner-.*$",     manage = 'off' },
              { app = "^Keychron Engine$",  manage = 'off' },
              { app = "^Logi Options\\+$",  manage = 'off' },
              { app = "^Mac Mouse Fix$",    manage = 'off' },
              { app = "^Messages$",         manage = 'off' },
              { app = "^Raycast$",          manage = 'off' },
              { app = "^Screen Sharing$",   manage = 'off' },
              { app = "^Shortcuts$",        manage = 'off' },
              { app = "^Spotify$",          manage = 'on' },
              { app = "^Steer[Mm]ouse$",    manage = 'off' },
              { app = "^System Settings$",  manage = 'off', label = 'ks:systemsettings' },
              { app = "^UTM$",              manage = 'off' },

            }
          }
        }
      }


    local testfile = rcfile:new(test_file_config)

    assert.are.same('', testfile:makefile())
  end)
end)