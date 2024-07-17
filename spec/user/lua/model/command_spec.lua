local assert = require 'luassert'
local pretty = require 'pl.pretty'
local tutil  = require 'spec.util'

local fmt = tutil.fmt



insulate("user.lua.model.command", function()

  _G.hs = tutil.hs_mock(spy)

  package.loaded['user.lua.interface.alert'] = {}

  local Command = require("user.lua.model.command")

  describe("KS Command Class", function()
    describe("command:new", function()
      it("should construct a new Command instance without error", function()

        local setup_fn = spy.new(function() end)
        local invoke_fn = spy.new(function() end)

        local test_cmd_config = {
          id = 'spec.command.sanity_test',
          title = 'Command Sanity Test',
          -- icon = 'info',
          setup = setup_fn,
          exec = invoke_fn,
        }
        
        local test_cmd = Command:new(test_cmd_config)
      end)
    end)

    describe("command:has_flag", function()
      it("should construct a new Command instance without error", function()
        local setup_fn = spy.new(function() end)
        local invoke_fn = spy.new(function() end)

        local test_cmd_config = {
          id = 'spec.command.has_flag',
          title = 'Command Has Flag Test',
          flags = { 'spec-flag' },
          setup = setup_fn,
          exec = invoke_fn,
        }
        
        local test_cmd = Command:new(test_cmd_config)


        assert.True(test_cmd:has_flag('spec-flag'))
        assert.False(test_cmd:has_flag('not-in-spec-flag'))
      end)
    end)
  end)
end)