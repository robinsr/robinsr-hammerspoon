---@diagnostic disable: redundant-parameter
local tutil  = require 'spec.util'
local dkjson = require 'dkjson'
local plfile = require 'pl.file'
local plpath = require 'pl.path'


local pretty = require('pl.pretty')
local params = require('user.lua.lib.params')
local proto = require('user.lua.lib.proto')
local types = require('user.lua.lib.typecheck')
local list = require('user.lua.lib.list')


insulate("user.lua.interface.desktop", function()

  package.loaded[tutil.logger_mod] = tutil.mock_logger(spy, "inspect")
  
  local noop = spy.new(function() end)

  local mock_httpserver = {
    setPort = noop,
    setCallback = noop,
    setInterface = noop,
  }

  local mock_http_module = {
    new = spy.new(function(ssl, bonjour)
      return mock_httpserver
    end)
  }

  _G.hs = tutil.hs_mock(spy)

  package.loaded['pl.pretty'] = pretty
  package.loaded['user.lua.lib.params'] = params
  package.loaded['user.lua.lib.proto'] = proto
  package.loaded['user.lua.lib.typecheck'] = types
  package.loaded['user.lua.lib.list'] = list


  local desktop = require("user.lua.interface.desktop")

  describe("desktop.getMenuItems", function()
    it("shoud loaded", function()

      local jsonpath = plpath.join(plpath.currentdir(), 'spec/fixtures/menuitems.json')
      local jsonfile = plfile.read(jsonpath)
      tutil.dump(jsonpath)
      local menuitems = dkjson.decode(jsonfile)

      local app = {
        getMenuItems = spy.new(function()
          return menuitems
        end)
      }
      
      local mitems = desktop.getMenuItems(app)

      assert.is_not.Nil(mitems)
    end)
  end)

end)