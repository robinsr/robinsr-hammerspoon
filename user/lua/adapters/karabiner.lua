local shell = require 'user.lua.adapters.shell'
local isCli = require 'user.lua.adapters.base.cli-utility'
local proto = require 'user.lua.lib.proto'

--[[
karabiner_cli [OPTION...] positional parameters

  --select-profile arg      Select a profile by name.
  --show-current-profile-name
                            Show current profile name
  --list-profile-names      Show all profile names
  --set-variables arg       Json string: {[key: string]:
                            number|boolean|string}
  --copy-current-profile-to-system-default-profile
                            Copy the current profile to system default
                            profile.
  --remove-system-default-profile
                            Remove the system default profile.
  --lint-complex-modifications glob-patterns
                            Check complex_modifications.json
  --format-json glob-patterns
                            Format json files
  --eval-js glob-patterns   Run javascript files using Duktape
]]


---@class KarabinerCLI: CliUtility
local Kcli = {}

Kcli._path = "karabiner_cli"

function Kcli:initialize()
  -- todo...
end


function Kcli:getCurrentProfile()
  return shell.run('karabiner_cli --show-current-profile-name')
end

function Kcli:setCurrentProfile()
  return shell.run('karabiner_cli --select-profile arg')
end

return proto.setProtoOf(Kcli, isCli)