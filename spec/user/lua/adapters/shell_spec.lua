local assert = require 'luassert'
local pretty = require 'pl.pretty'
local tutil  = require 'spec.util'

local plapp  = require 'pl.app'
local plsip  = require 'pl.sip'

local fmt = tutil.fmt


insulate("adapters.shell", function()

  _G.hs = tutil.hs_mock(spy)

  describe("Parsing test", function()

    local test_cmd = 'yabai -m rule --add app="^Alfred.*$" manage=off'

    pending("parses args", function()
      local split = require('user.lua.lib.string').split

      local flags, params = plapp.parse_args(split(test_cmd), {
        'foo', 'bar'
      }, {
        message = "m",
        add = "add",
        app = "app",
        manage = "manage",
      })

      -- tutil.dump(flags, params)
    end)

    it("uses SIP", function()
      local do_sip, err = plsip.compile('yabai -m rule --add app=$q{app} manage=$v{managed}', { at_start = true })

      if do_sip == nil then
        error(err or 'SIP failed to compile')
      end

      local result = {}
      local match = do_sip(test_cmd, result)

      -- tutil.dump(match, result)
    end)
  end)

  describe("Shell", function()
    local shell = require('user.lua.adapters.shell')

    describe("key/value formatter", function()
      it("(1) should format a basic cli k/v format", function()
        assert.are.same('foo=bar', shell.kv('foo', 'bar'))
        assert.are.same('--foo=bar', shell.kv('--foo', 'bar'))
      end)

      it("(2) should add double-quotes if spaces present", function()
        assert.are.same('foo="b a r"', shell.kv('foo', 'b a r'))
      end)

      it("(3) should add optional value wrap characters", function()
        assert.are.same('foo="bar"', shell.kv('foo', 'bar', '""'))
        assert.are.same('foo=`bar`', shell.kv('foo', 'bar', "``"))
        assert.are.same('foo=[bar]', shell.kv('foo', 'bar', "[]"))
      end)

      it("(4) should use optional separator character", function()
        assert.are.same('foo bar', shell.kv('foo', 'bar', " "))
        -- percent-sign not supported; dont care
        assert.are.same('foo!bar', shell.kv('foo', 'bar', '%'))
        assert.are.same('foo=[bar]', shell.kv('foo', 'bar', "[]"))
      end)

      it("(5) should use optional separator character and wrap characters", function()
        assert.are.same('foo+{bar}', shell.kv('foo', 'bar', '+{}'))
        assert.are.same('foo <bar>', shell.kv('foo', 'bar', " <>"))
        assert.are.same('foo=[bar]', shell.kv('foo', 'bar', "[]"))
      end)
    end)
  end)
end)