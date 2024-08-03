---@diagnostic disable: redundant-parameter
local tutil  = require 'spec.util'
local say = require 'say'

local fmt = tutil.fmt
local dump = tutil.dump


insulate('user.lua.lib.string', function()

  package.loaded[tutil.logger_mod] = tutil.mock_logger(spy, "inspect")
  
  local strings = require('user.lua.lib.string')

  describe("String instances", function()
    it("should create a new String", function()
      local my = strings("Hello, world")

      assert.are.same("Hello, world", my)
    end)

    it("should provide String methods", function()
      local my = strings("Hello, %s")

      assert.is_function(my.fmt)
      assert.are.same("Hello, Buddy", my:fmt('Buddy'))
      assert.are.same("Hello, Guy", my:fmt('Guy'))
      assert.are.same("Hello, Friend", my:fmt('Friend'))
    end)

    it("should provide base Lua string methods", function()
      local my = strings("Hello, %s")

      assert.is_function(my.format)
      assert.are.same("Hello, Buddy", my:format('Buddy'))
      assert.are.same("Hello, Guy", my:format('Guy'))
      assert.are.same("Hello, Friend", my:format('Friend'))
    end)
  end)
  

  describe('static', function()
    describe('String.join(tbl, sep)', function()
      it('joins some strings', function()
        assert.equal('foobarbaz', strings.join{ 'foo', 'bar', 'baz'})
        assert.equal('foo-bar-baz', strings.join({ 'foo', 'bar', 'baz'}, '-'))
      end)
    end)

    describe('strings.tmpl', function()

      local consts = {
        foo = 'Lorem ipsum',
        bar = 'dolor',
      }

      local fullvars = {
        foo = 'Lorem ipsum',
        bar = 'dolor',
        baz = 0.04,
        qux = 0xFF,
        quuz = nil,
        fob = {
          qab = 'xyz'
        },
        bab = false,
      }

      it("(1) should do basic var replacement", function()
        local render = strings.tmpl('{foo} {bar} {baz}-{qux}-{quuz}-{fob}-{bab}')
        assert.are.same('Lorem ipsum dolor 0.04-255---', render(fullvars))
      end)

      it("(2) should fallback to consts table", function()
        local render = strings.tmpl('{foo} {bar} {baz}', consts)
        assert.are.same('Lorem ipsum dolor sit amet', render({ baz = 'sit amet' }))
      end)

      it("(3) should use nested fields", function()
        local render = strings.tmpl('{foo} {bar} {baz.foo}', consts)
        assert.are.same('Lorem ipsum dolor sit amet', render({ baz = { foo = 'sit amet' }}))
      end)

      it("(4A) trim front", function()
        local render = strings.tmpl('Lorem ipsum {-foo}')
        assert.are.same('Lorem ipsum', render({ foo = nil }))
        assert.are.same('Lorem ipsum dolor', render({ foo = 'dolor' }))
      end)

      it("(4B) trim front (cant trim previous token's trailing whitespace)", function()
        local render = strings.tmpl('{foo} {-bar}')
        assert.are.same('Lorem ipsum ', render({ foo = consts.foo, bar = nil }))
        assert.are.same('Lorem ipsum dolor', render({ foo = consts.foo, bar = consts.bar }))
      end)

      it("(5) trim end", function()
        local render = strings.tmpl('{foo-} {bar}')
        assert.are.same('rab', render({ foo = nil, bar = 'rab' }))
        assert.are.same('#oof rab', render({ foo = '#oof', bar = 'rab' }))
      end)

      it("(6) append space when var defined", function()
        local render = strings.tmpl('{foo+}{bar}')
        assert.are.same('rab', render({ foo = nil, bar = 'rab' }))
        assert.are.same('oof rab', render({ foo = 'oof', bar = 'rab' }))
      end)

      it("(7) prepend space when var defined", function()
        local render = strings.tmpl('{foo}{+bar}')
        assert.are.same('oof', render({ foo = 'oof', bar = nil }))
        assert.are.same('oof rab', render({ foo = 'oof', bar = 'rab' }))
      end)

      it("(8) add both leading and trailing space when var defined", function()
        local render = strings.tmpl('{foo}{+baz+}{bar}')
        assert.are.same('Lorem ipsumdolor', render(consts))
        assert.are.same('Lorem ipsum 0.04 dolor', render(fullvars))
      end)
    end)
  end)
end)