---@diagnostic disable: redundant-parameter
local pretty = require 'pl.pretty'
local tutil  = require 'spec.util'
local say = require 'say'

local fmt = tutil.fmt
local dump = tutil.dump


insulate("user.lua.lib.regex", function()

  package.loaded[tutil.logger_mod] = tutil.mock_logger(spy, "inspect")

  local regex = require('user.lua.lib.regex')

  describe("Regex.uri (RFC 6570)", function()

    local l1_allowed = { "@", ".", "!", "$", "&", "'", "(", ")",  "*", "+", ";", "=", '{', '}' }
    local l2_allowed = { '.jpg' }


    describe("simple matching", function()
      it("should match an identical string", function()
        local matcher = regex.uri('index.html')

        assert.is_not.Nil(matcher('index.html'))
        assert.are.same('index.html', matcher('index.html'))
        assert.is.Nil(matcher('ondex.html'))
        assert.is.Nil(matcher('INDEX.html'))
        assert.is.Nil(matcher('  index.html  '))

        local matcher = regex.uri('/')
        assert.are.same('/', matcher('/'))
      end)

      
    end)


    describe("{var} simple string exansion", function()
      
      -- The default expression type is simple string expansion,
      -- wherein a single named variable is replaced by its value as a string
      -- after pct-encoding any characters not in the set of unreserved URI
      -- characters

      it("should match a path partial", function()
        local matcher = regex.uri('/foo/{var}')
        local match_foobar = matcher('/foo/bar')

        assert.is_not.Nil(match_foobar)
        assert.are.same({ var = 'bar' }, match_foobar)
        assert.are.same('bar', match_foobar.var)

      end)

      it("should allow expanded strings with certain characers", function()
        local matcher = regex.uri('/foo/{var}')

        for i,char in ipairs(l1_allowed) do
          local match_char = matcher('/foo/bar'..char..'baz')
          assert.is_not.Nil(match_char, ('expected char "%s" to be allowed in string expansion'):format(char))
          assert.are.same('bar'..char..'baz', match_char.var)
        end
      end)

      it("should not expand strings with disallowed characters", function()
        local matcher = regex.uri('/foo/{var}')

        -- Non-matches:
        assert.is.Nil(matcher('/foo/bar/baz'), 'should not match continuation of path')
        assert.is.Nil(matcher('/foo/bar?baz'), 'should not match undeclared querystring')
        assert.is.Nil(matcher('/foo/bar#baz'), 'should not match undeclared anchor')
      end)
    end)

    describe("{+var} reserved character string expansion", function()
      it("should match ", function()
        local matcher = regex.uri('/foo/{+filename}')

        for i,char in ipairs(l1_allowed) do
          local match_char = matcher('/foo/bar'..char..'baz')
          assert.is_not.Nil(match_char, ('expected char "%s" to be allowed in string expansion'):format(char))
          assert.are.same('bar'..char..'baz', match_char.filename)
        end

        local match_file = matcher('/foo/bar/baz/quz.png')
        assert.is_not.Nil(match_file)
        assert.are.same('bar/baz/quz.png', match_file.filename)

        local match_path_and_file = regex.uri('/foo/{+paths}/{+file}')
        local path_and_file = match_path_and_file('/foo/bar/baz/quz/kitty.webm')
        assert.is_not.Nil(path_and_file)
        assert.are.same('bar/baz/quz', path_and_file.paths)
        assert.are.same('kitty.webm', path_and_file.file)
      end)
    end)

    describe("{#var} fragment expansion, crosshatch-prefixed", function()
      it("should match URI fragments (anchor?)", function()
        local matcher = regex.uri('/foo/{+filename}{#hash}')

        local match_file = matcher('/foo/somefile.txt')
        assert.is_not.Nil(match_file)
        assert.are.same('somefile.txt', match_file.filename)
        assert.is.Nil(match_file.hash)

        local match_filehash = matcher('/foo/somefile.txt#heading-1')
        assert.is_not.Nil(match_filehash)
        assert.are.same('somefile.txt', match_filehash.filename)
        assert.are.same('heading-1', match_filehash.hash)
      end)
    end)

    describe("{.var} label expansion, dot-prefixed", function()
      it("should match label values", function()
        local matcher = regex.uri('/foo/{.animals}/{.names}')

        local matched = matcher('/foo/.dog,cat/.fido,frisky')
        assert.is_not.Nil(matched)
        assert.are.same('dog,cat', matched.animals)
        assert.are.same('fido,frisky', matched.names)
      end)
    end)

    -- describe("{/var} path segments, slash-prefixed", function()
    --   pending("should match", function()
    --     local matcher = regex.uri('/foo/{/paths}/kitty')

    --     local matched = matcher('/foo/wefwefwef/kitty')
    --     assert.is_not.Nil(matched)
    --     dump(matched)
    --   end)
    -- end)

    describe("{;var} path-style parameters, semicolon-prefixed", function()
      it("should match ", function()
        local matcher = regex.uri('/foo/{;x,y,z}/kitty')

        local matchedx = matcher('/foo/;x=123/kitty')
        assert.is_not.Nil(matchedx)
        assert.are.same('123', matchedx.x)
        

        local matchedy = matcher('/foo/;y=abc/kitty')
        assert.is_not.Nil(matchedy)
        assert.are.same('abc', matchedy.y)
        

        local matchedxyz = matcher('/foo/;x=123;y=abc;z=bar/kitty')
        assert.is_not.Nil(matchedxyz)
        assert.are.same('123', matchedxyz.x)
        assert.are.same('abc', matchedxyz.y)
        assert.are.same('bar', matchedxyz.z)
      end)
    end)

    describe("{?var} form-style query, ampersand-separated", function()
      it("should match", function()
        local matcher = regex.uri('/foo/{+path}{?query,number}')

        local matched = matcher('/foo/red/green/blue?number=101&query=purple%20penguins')

        assert.is_not.Nil(matched)
        assert.are.same("101", matched.number)
        assert.are.same("red/green/blue", matched.path)
        assert.are.same("purple penguins", matched.query)
      end)
    end)


    describe("{&var} form-style query continuation", function()
      it("should match", function()
        local matcher = regex.uri('/foo/{+path}{&query,number}{?x,*}')

        local matched = matcher('/foo/red/green/blue?number=101&query=pp')

        assert.is_not.Nil(matched)
        assert.are.same("101", matched.number)
        assert.are.same("red/green/blue", matched.path)
        assert.are.same("pp", matched.query)

        local matched = matcher('/foo/red/green/blue?number=101&query=pp&x=123')

        assert.is_not.Nil(matched)
        assert.are.same("101", matched.number)
        assert.are.same("red/green/blue", matched.path)
        assert.are.same("pp", matched.query)
        assert.are.same("123", matched.x)
      end)
    end)
        
        
  end)

  describe("Regex.glob/Regex.globs", function()
    
    local function new_glob(pattern)
      local glob

      if type(pattern) == "string" then
        glob = regex.glob(pattern)
      else
        glob = regex.globs(pattern)
      end
      
      return glob
    end
    
    describe("(basic glob patterns)", function()
      -- pending("I should finish this test later")

      local glob_hit = function(pattern, file)
        local result = new_glob(pattern)(file)
        local errMsg = fmt("Expected glob %q to match file %q", pattern, file)
        ---@diagnostic disable-next-line: redundant-parameter
        assert.is_true(result, errMsg)
      end

      local glob_mis = function(pattern, file)
        local result = new_glob(pattern)(file)
        ---@diagnostic disable-next-line: redundant-parameter
        assert.is.False(result, fmt("Expected glob %q to not match file %q", pattern, file))
      end

      it("(0) should match simple strings", function()
        glob_hit('/foo', '/foo')
        glob_mis('/foo', 'foo')
        glob_mis('/foo', 'foooo')
        glob_mis('/foo', ' / foo ')
        glob_mis('/foo', '/foobarbaz')
      end)


      it("(1) should match '**' (/)", function()
        glob_hit('**', 'this/should/work')
        glob_hit('**', 'this/could/work')
      end)

      it("(2) should match '**' (.)", function()
        glob_hit('**', 'this.should.work')
        glob_hit('**', 'this.could.work')
      end)


      it("(3) should match 'this/should/*'", function()
        local input = 'this/should/*'
        glob_hit(input, 'this/should/work')
        glob_mis(input, 'this/could/work')
      end)

      it("(4) should match 'this.should.*'", function()
        local input = 'this.should.*'
        glob_hit(input, 'this.should.work')
        glob_mis(input, 'this.could.work')
      end)


      it("(5) should match 'this/should/*' and '**'", function() 
        local input = { 'this/should/*', '**' }

        glob_hit(input, 'this/should/work')
        glob_mis(input, 'this/could/work')
      end)

      it("(6) should match '!this/should/work'", function() 
        local input = '!this/should/*'

        glob_mis(input, 'this/should/work')
        glob_hit(input, 'this/could/work')
      end)


      it("(7) should match { 'this/should/*', 'this/could/*' }", function()
        local input = { 'this/should/*', 'this/could/*' }

        glob_mis(input, 'this/should/work')
        glob_mis(input, 'this/could/work')
      end)


      it("(8) should match { 'this/should/*', '!this/could/*' }", function()
        local input = { 'this/should/*', '!this/could/*' }

        glob_hit(input, 'this/should/work')
        glob_mis(input, 'this/could/work')
      end)


      it("(9) should match { '!this/should/*', '!this/could/*' }", function()
        local input = { '!this/should/*', '!this/could/*' }

        glob_mis(input, 'this/should/work')
        glob_mis(input, 'this/could/work')
      end)


      it("(10) should match 'this/*ould/*'", function()
        local input = { 'this/*ould/*' }

        glob_hit(input, 'this/should/work')
        glob_hit(input, 'this/could/work')
      end)


      it("(11) should match '*/*ould/*'", function()
        local input = '*/*ould/*'

        glob_hit(input, 'this/should/work')
        glob_hit(input, 'this/could/work')
      end)


      it("(12) should match { '**', '!could' }", function()
        local input = { '**', '!*could*' }

        glob_hit(input, 'this/should/work')
        glob_mis(input, 'this/could/work')
      end)


      it("(13) should match '*/(should|could)/work'", function()
        local input = '*/(should|could)/work'

        glob_hit(input, 'this/should/work')
        glob_hit(input, 'this/could/work')
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
end)