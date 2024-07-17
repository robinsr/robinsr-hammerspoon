local assert = require 'luassert'
local pretty = require 'pl.pretty'
local tutil  = require 'spec.util'
local say = require 'say'

local fmt = tutil.fmt
local dump = tutil.dump


insulate("user.lua.lib.regex", function()

  local regex = require('user.lua.lib.regex')

  local function new_glob(pattern)
    local glob

    if type(pattern) == "string" then
      glob = regex.glob(pattern)
    else
      glob = regex.globs(pattern)
    end
    
    -- dump(glob)
    
    return glob
  end


  describe("(basic glob patterns)", function()
    -- pending("I should finish this test later")

    local glob_ok = function(pattern, file)
      local result = new_glob(pattern)(file)
      local errMsg = fmt("Expected glob %q to match file %q", pattern, file)
      ---@diagnostic disable-next-line: redundant-parameter
      assert.is_true(result, errMsg)
    end

    local glob_no = function(pattern, file)
      local result = new_glob(pattern)(file)
      ---@diagnostic disable-next-line: redundant-parameter
      assert.is.False(result, fmt("Expected glob %q to not match file %q", pattern, file))
    end


    it("(1) should match '**' (/)", function()
      glob_ok('**', 'this/should/work')
      glob_ok('**', 'this/could/work')
    end)

    it("(2) should match '**' (.)", function()
      glob_ok('**', 'this.should.work')
      glob_ok('**', 'this.could.work')
    end)


    it("(3) should match 'this/should/*'", function()
      local input = 'this/should/*'
      glob_ok(input, 'this/should/work')
      glob_no(input, 'this/could/work')
    end)

    it("(4) should match 'this.should.*'", function()
      local input = 'this.should.*'
      glob_ok(input, 'this.should.work')
      glob_no(input, 'this.could.work')
    end)


    it("(5) should match 'this/should/*' and '**'", function() 
      local input = { 'this/should/*', '**' }

      glob_ok(input, 'this/should/work')
      glob_no(input, 'this/could/work')
    end)

    it("(6) should match '!this/should/work'", function() 
      local input = '!this/should/*'

      glob_no(input, 'this/should/work')
      glob_ok(input, 'this/could/work')
    end)


    it("(7) should match { 'this/should/*', 'this/could/*' }", function()
      local input = { 'this/should/*', 'this/could/*' }

      glob_no(input, 'this/should/work')
      glob_no(input, 'this/could/work')
    end)


    it("(8) should match { 'this/should/*', '!this/could/*' }", function()
      local input = { 'this/should/*', '!this/could/*' }

      glob_ok(input, 'this/should/work')
      glob_no(input, 'this/could/work')
    end)


    it("(9) should match { '!this/should/*', '!this/could/*' }", function()
      local input = { '!this/should/*', '!this/could/*' }

      glob_no(input, 'this/should/work')
      glob_no(input, 'this/could/work')
    end)


    it("(10) should match 'this/*ould/*'", function()
      local input = { 'this/*ould/*' }

      glob_ok(input, 'this/should/work')
      glob_ok(input, 'this/could/work')
    end)


    it("(11) should match '*/*ould/*'", function()
      local input = '*/*ould/*'

      glob_ok(input, 'this/should/work')
      glob_ok(input, 'this/could/work')
    end)


    it("(12) should match { '**', '!could' }", function()
      local input = { '**', '!*could*' }

      glob_ok(input, 'this/should/work')
      glob_no(input, 'this/could/work')
    end)


    it("(13) should match '*/(should|could)/work'", function()
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
      local matcher = new_glob(pattern)
      local matches = {}

      for i,v in ipairs(cases or GLOB_STRINGS) do
        if (matcher(v)) then
          table.insert(matches, v)
        end
      end

      local msg = fmt("results for \"%s\" did not match expected", pretty.write(pattern))
      assert.are.same(expect, matches, msg)
    end

    it("(1) should work with permissive wildcards", function()
      test_glob("*", GLOB_STRINGS)
      test_glob("*.*", GLOB_STRINGS)
      test_glob("**.*", GLOB_STRINGS)
      test_glob("**", GLOB_STRINGS)
    end)

    it("(2) should work with trailing wildcards", function()
      test_glob("one.red.*", {
        "one.red.foo",
        "one.red.bar",
        "one.red.baz"
      })
    end)

    it("(3) should work with leading wildcards", function()
      test_glob("*.baz", {
        "one.red.baz",
        "one.blu.BAZ",
        "one.grn.baz",
        "two.red.baz",
        "two.blu.BAZ",
        "two.grn.baz",
      })
    end)

    it("(4) should match against multiple patterns including a negation", function()
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

    it("(5) should work with alternation (this OR that) patterns", function()
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

    local run_test_cases = function(pattern, expections)
      local globfn = new_glob(pattern)

      for i, t in ipairs(test_cases) do
        local do_assert
        
        if expections[i] == true then
          do_assert = assert.is.truthy
        elseif expections[i] == false then
          do_assert = assert.is.falsy
        else
          do_assert = assert.is_not.Nil
        end

        local msg = fail_msg:format(pattern, t.pattern, t.test_name)
        
        ---@diagnostic disable-next-line: redundant-parameter
        do_assert(globfn(t.pattern), msg)
      end
    end


    it('(1) glob pattern "*"', function()
      run_test_cases('*', { true, true, true, true, true })
    end)

    it('(2) glob pattern "/some/dir/"', function()
      run_test_cases('/some/dir/', { false, false, true, false, false })
    end)

    it('(3) glob pattern "/some/dir/*"', function()
      run_test_cases('/some/dir/*', { false, false, true, true, false })
    end)

    it('(4) glob pattern "?*"', function()
      run_test_cases('?*', { nil, nil, nil, nil, true })
    end)

    it('(5) glob pattern "/*/?*"', function()
      run_test_cases('/*/?*', { nil, nil, nil, nil, false, true })
    end)
  end)
end)