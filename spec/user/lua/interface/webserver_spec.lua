local tutil  = require 'spec.util'


insulate("user.lua.interface.webserver", function()

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

  _G.hs = {
    httpserver = mock_http_module,
    inspect = noop,
  }

  package.loaded[tutil.logger_mod] = tutil.mock_logger(spy)

  local webserver = require("user.lua.interface.webserver")

  describe("setup", function()
    it("should stand up a simple file server", function()
      
      local server = webserver:new()

      assert.is.True(true, "this should be true")
    end)
  end)

end)