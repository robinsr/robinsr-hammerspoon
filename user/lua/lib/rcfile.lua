local lists   = require 'user.lua.lib.list'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local shell   = require 'user.lua.adapters.shell'



---@class ks.rc_file
---@field id              string
---@field path            string
---@field consts_table    table
---@field vars            table
---@field types           { [string]: ks.rc_file.type_formatter }
---@field comment_pattern string
---@field sections        ks.rc_file.section


---@class ks.rc_file.section
---@field id          string
---@field name        string
---@field lines?      string[]
---@field pattern?    string
---@field type?       string
---@field data?       table


---@alias ks.rc_file.type_formatter fun(file: ks.rc_file, item: table): table




local SECTION_HEAD = strings.tmpl('[{id}] {name}')
local BASH_VAR = '%s=%q'

local formatters = {
  optional_prop = function(conf, item)
    return { 
      key = item[1], 
      val = item[2], 
      dis = item[3] and '#' or '',
    }
  end,
  table_prop = function(conf, item)
    return {
      props = lists(tables.keys(item)):reduce('', function(m, k)
        if k == 'app' then
          return m .. ' ' .. shell.kv(k, item[k], '=""')
        else
          return m .. ' ' .. shell.kv(k, item[k], '=')
        end
      end)
    }
  end
}



---@class ks.rc_file
local rcfile = {}

rcfile.formatters = formatters


--
-- Creates a new RC_File writer
--
---@param config ks.rc_file
---@return ks.rc_file
function rcfile:new(config)

  local defaults = {
    id = 'NO_ID',
    path = '~',
    consts_table = {},
    comment_pattern = '# %s',
    sections = {},
    vars = {},
  }

  local this = tables.merge(defaults, config)

  return setmetatable(this, { __index = rcfile }) --[[@as ks.rc_file]]
end


--
-- Adds a section
--
---@param section ks.rc_file.section
function rcfile:add_section(section)
  table.insert(self.sections, section)

  return self
end


--
--
--
function rcfile.update_val(section_id, match_fn, new_val)
  
end


--
-- Format section to string
--
---@param section ks.rc_file.section
---@return string
function rcfile:format_section(section)
  local consts = self.consts_table
  local comment = self.comment_pattern

  local output = strings.linewriter()

  output:add(''):addf(comment, SECTION_HEAD({ 
    id = strings.join({ self.id, section.id }, '.'),
    name = section.name
  }))

  if section.lines then
    for i,l in ipairs(section.lines) do
      output:add(l)
    end
  end

  if section.data and section.type then
    local tmpl = strings.tmpl(section.pattern, { consts = consts })
    local line_mapper = self.types[section.type] or formatters[section.type]

    for _,item in ipairs(section.data) do
      output:add(tmpl(line_mapper(self, item)))
    end
  end

  return output:value()
end



--
-- Produces rc file content
--
function rcfile:makefile()
  local consts = self.consts_table
  local comment = self.comment_pattern

  local output = strings.linewriter()

  output:addf(comment, ('@ks.rc_file - %s'):format(self.id)):cr()

  lists(self.vars)
    :map(function(v) return BASH_VAR:format(v[1], v[2]) end)
    :forEach(function(out) output:add(out) end)
  
  lists(self.sections)
    :map(function(section)return self:format_section(section) end)
    :forEach(function(out) output:add(out) end)

  return output:value()
end


return rcfile