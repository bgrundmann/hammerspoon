--------------------------------------------------------------------------------
-- Action execution
--
-- This module provides a function to execute different types of actions
-- based on which key is present in the action item.
--------------------------------------------------------------------------------

local M = {}

--- Execute an action item based on its type.
---
--- Action types (detected by which key is present):
---   app         = path to .app bundle -> launch or focus
---   folder      = path to folder -> open in Finder
---   url         = URL string -> open in default browser
---   command     = shell command -> execute via hs.execute
---   applescript = AppleScript code -> execute via hs.osascript
---   fun         = Lua function -> call directly
---
--- @param item table The action item to execute
function M.executeAction(item)
    if item.app then
        hs.application.launchOrFocus(item.app)
    elseif item.folder then
        hs.open(item.folder)
    elseif item.url then
        hs.urlevent.openURL(item.url)
    elseif item.command then
        hs.execute(item.command)
    elseif item.applescript then
        hs.osascript.applescript(item.applescript)
    elseif item.fun then
        item.fun()
    end
end

return M
