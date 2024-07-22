---@diagnostic disable

local tags = require("aspect.tags")
local aspect_err = require("aspect.error")
local output = require("aspect.output")
local aspect_utils = require("aspect.utils")

--
-- {% raw %}
--
--- @param compiler aspect.compiler
function tags.tag_raw(compiler)
    compiler.ignore = "endraw"
    compiler:push_tag("raw", false, false)
end


--
-- {% endraw %}
--
--- @param compiler aspect.compiler
function tags.tag_endraw(compiler)
    compiler:pop_tag("raw")
    return "local z=1"
end

--- @param compiler aspect.compiler
--- @param tok aspect.tokenizer
function tags.tag_call(compiler, tok)
  if not tok:is_word() then
    aspect_err.compiler_error(tok, "syntax", "expecting a valid macro name")
  end
  
  local tag = compiler:push_tag("call")

  local id = tag.id

  tag.var = 'children'
  tag.macro = compiler:parse_macro(tok):gsub('%}%)$', ',["children"] = children })')
  tag.final = '__.concat(_' .. tag.id .. ')'

  tag.append_text = function (_, text)
    return '_' .. id .. '[#_'.. id .. ' + 1] = ' .. aspect_utils.quote_string(text)
  end

  tag.append_expr = function (_, lua)

    if lua:match('%(__,') then

      local var_content = '_c'..id
      local var_content_arr = '_c'..id..'[#_c'..id..' + 1]'
      local var_printer = '_p'..id
      local var_output = '_o'..id


      return table.concat({
        'local '.. var_content .. ' = {}',
        'local '.. var_printer .. ' = function(data) ' .. var_content_arr ..' = data end',
        'local '.. var_output .. ' = __.new(__.opts, __.ctx, { print = ' .. var_printer .. ' })',
        lua:gsub('%(__,', '('.. var_output .. ','),
        '_' .. id .. '[#_'.. id .. ' + 1] = __.concat('.. var_content .. ')'
      }, '\n')
    else
      return '_' .. id .. '[#_'.. id .. ' + 1] = ' .. lua
    end
  end
  
  return {
    "local " .. tag.var,
    "do",
    "local _" .. tag.id .. " = {}"
  }
end

--- @param compiler aspect.compiler
--- @param tok aspect.tokenizer
function tags.tag_endcall(compiler, tok)
    tok:next()
    local tag = compiler:pop_tag("call")
    compiler:push_var(tag.var)
    return {
        tag.var .. " = " .. tag.final,
        tag.macro,
        "end"
    }
end

