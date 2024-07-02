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

    describe("glob", function()

      describe("(basic glob patterns)", function()
        -- pending("I should finish this test later")

        local glob_ok = function(pattern, file)
          local result = strings.glob(pattern)(file)
          assert.is.True(result, fmt("Expected glob %q to match file %q", pattern, file))
        end

        local glob_no = function(pattern, file)
          local result = strings.glob(pattern)(file)
          assert.is.False(result, fmt("Expected glob %q to not match file %q", pattern, file))
        end


        it("1 should match '**' (/)", function()
          glob_ok('**', 'this/should/work')
          glob_ok('**', 'this/could/work')
        end)

        it("2 should match '**' (.)", function()
          glob_ok('**', 'this.should.work')
          glob_ok('**', 'this.could.work')
        end)


        it("3 should match 'this/should/*'", function()
          local input = 'this/should/*'
          glob_ok(input, 'this/should/work')
          glob_no(input, 'this/could/work')
        end)

        it("4 should match 'this.should.*'", function()
          local input = 'this.should.*'
          glob_ok(input, 'this.should.work')
          glob_no(input, 'this.could.work')
        end)


    	  it("5 should match 'this/should/*' and '**'", function() 
          local input = { 'this/should/*', '**' }

      	  glob_ok(input, 'this/should/work')
      	  glob_no(input, 'this/could/work')
        end)

        it("6 should match '!this/should/work'", function() 
          local input = '!this/should/*'

          glob_no(input, 'this/should/work')
          glob_ok(input, 'this/could/work')
        end)


    	  it("7 should match { 'this/should/*', 'this/could/*' }", function()
          local input = { 'this/should/*', 'this/could/*' }

      	  glob_no(input, 'this/should/work')
      	  glob_no(input, 'this/could/work')
        end)


    	  it("8 should match { 'this/should/*', '!this/could/*' }", function()
          local input = { 'this/should/*', '!this/could/*' }

      	  glob_ok(input, 'this/should/work')
      	  glob_no(input, 'this/could/work')
        end)


    	  it("9 should match { '!this/should/*', '!this/could/*' }", function()
          local input = { '!this/should/*', '!this/could/*' }

      	  glob_no(input, 'this/should/work')
      	  glob_no(input, 'this/could/work')
        end)


    	  it("10 should match 'this/*ould/*'", function()
          local input = { 'this/*ould/*' }

      	  glob_ok(input, 'this/should/work')
      	  glob_ok(input, 'this/could/work')
        end)


    	  it("11 should match '*/*ould/*'", function()
          local input = '*/*ould/*'

      	  glob_ok(input, 'this/should/work')
      	  glob_ok(input, 'this/could/work')
        end)


    	  it("12 should match { '**', '!could' }", function()
          local input = { '**', '!*could*' }

      	  glob_ok(input, 'this/should/work')
      	  glob_no(input, 'this/could/work')
        end)


    	  it("13 should match '*/(should|could)/work'", function()
          local input = '*/(should|could)/work'

      	  glob_ok(input, 'this/should/work')
      	  glob_ok(input, 'this/could/work')
        end)
    	end)

      describe("(filtering from a list)", function()

        local GLOB_STRINGS = {
          "one.red.foo",
          "one.red.bar",
          "one.red.baz",
          "one.blu.foo",
          "one.blu.bar",
          "one.blu.BAZ",
          "one.grn.foo",
          "one.GRN.bar",
          "one.grn.baz",
          "two.red.foo",
          "two.red.bar",
          "two.red.baz",
          "two.blu.foo",
          "two.blu.bar",
          "two.blu.BAZ",
          "two.grn.foo",
          "two.GRN.bar",
          "two.grn.baz",
        }

        local test_glob = function(pattern, expect, cases)
          local matcher = strings.glob(pattern)
          local matches = {}

          for i,v in ipairs(cases or GLOB_STRINGS) do
            if (matcher(v)) then
              table.insert(matches, v)
            end
          end

          local msg = strings.fmt("results for \"%s\" did not match expected", pretty.write(pattern))
          assert.are.same(expect, matches, msg)
        end

        it("should work with permissive wildcards", function()
          test_glob("*", GLOB_STRINGS)
          test_glob("*.*", GLOB_STRINGS)
          test_glob("**.*", GLOB_STRINGS)
          test_glob("**", GLOB_STRINGS)
        end)

        it("should work with trailing wildcards", function()
          test_glob("one.red.*", {
            "one.red.foo",
            "one.red.bar",
            "one.red.baz"
          })
        end)

        it("should work with leading wildcards", function()
          test_glob("*.baz", {
            "one.red.baz",
            "one.blu.BAZ",
            "one.grn.baz",
            "two.red.baz",
            "two.blu.BAZ",
            "two.grn.baz",
          })
        end)

        it("should match against multiple patterns including a negation", function()
          test_glob({ "*", "!*grn*" }, {
            "one.red.foo",
            "one.red.bar",
            "one.red.baz",
            "one.blu.foo",
            "one.blu.bar",
            "one.blu.BAZ",
            "two.red.foo",
            "two.red.bar",
            "two.red.baz",
            "two.blu.foo",
            "two.blu.bar",
            "two.blu.BAZ",
          })
        end)

        it("should work with alternation (this OR that) patterns", function()
          test_glob("*.(red|blu).foo", {
            "one.red.foo",
            "one.blu.foo",
            "two.red.foo",
            "two.blu.foo",
          })
        end)
      end)

      describe("Path matching", function()
        local test_cases = {
          { 
            pattern = '',
            test_name = 'empty string'
          },
          { 
            pattern = '/',
            test_name =  'index file'
          },
          { 
            pattern = '/some/dir/',
            test_name =  'sub-directory without file'
          },
          { 
            pattern = '/some/dir/file.txt',
            test_name =  'sub-directory with a file'
          },
          { 
            pattern = '?query=this%20string',
            test_name =  'no path query string'
          },
          { 
            pattern = '/some/dir?query=this%20string',
            test_name =  'path and query string'
          },
        }

        local fail_msg = "path matcher '%s' failed test '%s' (%s)"

        local run_test_cases = function(glob_pattern, expections)
          local globfn = strings.glob(glob_pattern)

          for i, t in ipairs(test_cases) do
            local do_assert
            
            if expections[i] == true then
              do_assert = assert.is.truthy
            elseif expections[i] == false then
              do_assert = assert.is.falsy
            else
              do_assert = assert.is_not.Nil
            end

            local msg = fail_msg:format(glob_pattern, t.pattern, t.test_name)
            
            do_assert(globfn(t.pattern), msg)
          end
        end


        it('glob pattern "*"', function()
          run_test_cases('*', { true, true, true, true, true })
        end)

        it('glob pattern "/some/dir/"', function()
          run_test_cases('/some/dir/', { false, false, true, false, false })
        end)

        it('glob pattern "/some/dir/*"', function()
          run_test_cases('/some/dir/*', { false, false, true, true, false })
        end)

        it('glob pattern "?*"', function()
          run_test_cases('?*', { nil, nil, nil, nil, true })
        end)

        it('glob pattern "/*/?*"', function()
          run_test_cases('/*/?*', { nil, nil, nil, nil, false, true })
        end)
      end)
    end)
  end)
end)



      -- it("should work with custom separtor", function ()
      --   pending("I should finish this test later")

      --   local glob_opts =  { separator = '.' }
      --   local matcher = strings.glob('**', glob_opts)

      --   glob_ok('this.should.work')
      --   glob_ok('this.could.work')

      --   matcher = strings.glob('this.should.*', glob_opts)

      --   glob_ok('this.should.work')
      --   glob_no('this.could.work')

      --   matcher = strings.glob({ 'this.should.*' }, glob_opts)

      --   glob_ok('this.should.work')
      --   glob_no('this.could.work')

      --   matcher = strings.glob({ 'this.should.*', 'this.could.*' }, glob_opts)

      --   glob_ok('this.should.work')
      --   glob_ok('this.could.work')

      --   matcher = strings.glob({ 'this.should.*', '!this.could.*' }, glob_opts)

      --   glob_ok('this.should.work')
      --   glob_no('this.could.work')

      --   matcher = strings.glob({ '!this.should.*', '!this.could.*' }, glob_opts)

      --   glob_no('this.should.work')
      --   glob_no('this.could.work')

      --   matcher = strings.glob('this.*ould.*', glob_opts)

      --   glob_ok('this.should.work')
      --   glob_ok('this.could.work')

      --   matcher = strings.glob('*.*ould.*', glob_opts)

      --   glob_ok('this.should.work')
      --   glob_ok('this.could.work')

      --   matcher = strings.glob({ '**', '!could' }, glob_opts)

      --   glob_ok('this.should.work')
      --   glob_no('this.could.work')
      -- end)