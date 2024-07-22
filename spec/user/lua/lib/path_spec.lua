---@diagnostic disable: redundant-parameter
local tutil  = require 'spec.util'
local say = require 'say'

local fmt = tutil.fmt
local dump = tutil.dump

local function spread(...)
  return table.unpack({...})
end


insulate("user.lua.lib.path", function()

  package.loaded[tutil.logger_mod] = tutil.mock_logger(spy)

  local p = require('user.lua.lib.path')

  describe("Paths.rename", function()

    local msg = '(%d) pattern: "%s" in: "%s" result: "%s"'

    local dotest = function(testcases)
      for i,t in ipairs(testcases) do
        local input, pattern, expected, vars = table.unpack(t)
        local renamed = p.rename(input, pattern, vars)
        assert.are.same(expected, renamed, msg:format(i, pattern, input, renamed))
      end
    end

    it("should return expected filepaths", function()
      dotest({
        { '/foo/bar/baz.html', '{name}',                 'baz.html' },
        { '/foo/bar/baz.html', '{ext}',                  '.html' },
        { '/foo/bar/baz.html', '{dir}',                  '/foo/bar' },
        { '/foo/bar/baz.html', '{base}',                 'baz' },
        { '/foo/bar/baz.html', '{dir}/newname{ext}',     '/foo/bar/newname.html' },
        { '/foo/bar/baz.html', '{dir}/../{name}',        '/foo/baz.html' },
        { '/foo/bar/baz.html', '{dir}/{base}/file{ext}', '/foo/bar/baz/file.html' },
        { 'baz.html',          '{name}',                 'baz.html' },
        { 'baz.html',          '{base}',                 'baz' },
        { 'baz.html',          '{ext}',                  '.html' },
        { 'baz.html',          '{dir}',                  '.' }, -- result of normpath('')
        { 'baz.html',          'newname{ext}',           'newname.html' },
        { 'baz.html',          '{base}.newext',          'baz.newext' },
      })
    end)

    it("should accept additional variables", function()
      dotest({
        { 'foo.html', '{src}/{name}', '/a/b/c/foo.html', { src = '/a/b/c' } },
        { 'foo.html', '{src}/{name}', '{src}/foo.html', { src = nil } },
      })
    end)
  end)

end)