---@diagnostic disable: redundant-parameter
local assert = require 'luassert'
local pretty = require 'pl.pretty'
local tutil  = require 'spec.util'

local fmt = tutil.fmt


describe('lib/string.lua', function()
  
  local strings = require('user.lua.lib.string')
  

  describe('static', function()
    describe('String.join(tbl, sep)', function()
      it('joins some strings', function()
        assert.equal('foobarbaz', strings.join{ 'foo', 'bar', 'baz'})
        assert.equal('foo-bar-baz', strings.join({ 'foo', 'bar', 'baz'}, '-'))
      end)
    end)

    describe('String.tmpl(str)', function()
      it('compiles a template string for rendering', function()

        local tmpl = strings.tmpl('{ {{foo}} {{bar.bop}} }')

        assert.equal('{ abc xyz }', tmpl{ foo = 'abc', bar = { bop = 'xyz', } })
        assert.equal('{ 123 987 }', tmpl{ foo = '123', bar = { bop = '987', } })
        assert.equal('{ 123  }', tmpl{ foo = '123', bar = { bop = nil, } })
        assert.equal('{ 123  }', tmpl{ foo = '123', bar = {} } )
        assert.equal('{ 123  }', tmpl{ foo = '123' })
        assert.equal('{   }', tmpl{})
      end)

      it('throws an error hopefully', function()
        local tmpl

        -- valid template
        tmpl = strings.tmpl('what will this do?')
        tmpl({})

        -- valid template
        tmpl = strings.tmpl('')
        tmpl({})

        -- Invalid - nil
        assert.has_error(function()
          tmpl = strings.tmpl(nil)
        end)

        -- Invalid - table
        assert.has_error(function()
          tmpl = strings.tmpl({})
        end)
      end)
    end)
  end)
end)