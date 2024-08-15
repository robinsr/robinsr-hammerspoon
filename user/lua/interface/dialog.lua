

---@alias ks.prompt.result [ boolean, string|nil ]

local ACCEPT = "OK"
local DECLINE = "Cancel"

---@class ks.prompt
local dialog = {}


---@param title        string
---@param info?        string
---@param placeholder? string
---@return boolean, string
function dialog.prompt(title, info, placeholder)

  -- Close the HS Console before showing the text prompt or macos will automatically
  -- focus the console not the prompt dialog
  hs.closeConsole()

  local result = table.pack(
    hs.dialog.textPrompt(title, info, placeholder, ACCEPT, DECLINE)) --[[@as ks.prompt.result]]

  return result[1] == ACCEPT, result[2] or ''
end


return dialog