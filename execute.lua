--------------------------------------------------------------------------------
-- Action execution
--
-- This module provides a function to execute different types of actions
-- based on which key is present in the action item.
--------------------------------------------------------------------------------

local M = {}

--- Helper function to show an error alert
--- @param message string The error message to display
local function showError(message)
    hs.alert.show("⚠️ " .. message, 3)
    print("[execute] ERROR: " .. message)
end

--- Helper function to format item for debug output
--- @param item table The action item
--- @return string A string representation of the item
local function itemDescription(item)
    if item.title then
        return string.format('"%s"', item.title)
    end
    for _, key in ipairs({ "app", "folder", "url", "command", "applescript", "fun" }) do
        if item[key] then
            local value = item[key]
            if type(value) == "function" then
                return string.format('%s=<function>', key)
            elseif type(value) == "string" and #value > 50 then
                return string.format('%s="%s..."', key, value:sub(1, 47))
            else
                return string.format('%s="%s"', key, tostring(value))
            end
        end
    end
    return "<unknown item>"
end

--- Check if a string looks like a bundle ID (e.g., "com.apple.Safari")
--- Bundle IDs contain dots but don't end with .app and don't contain path separators
--- @param str string The string to check
--- @return boolean True if it looks like a bundle ID
local function isBundleID(str)
    return str:find("%.") ~= nil
        and not str:match("%.app$")
        and not str:find("/")
end

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
    local desc = itemDescription(item)

    if item.app then
        local ok
        -- all other things being equal we prefer to launch by bundle ID
        -- because they are more reliable and consistent across different versions of macOS
        if isBundleID(item.app) then
            ok = hs.application.launchOrFocusByBundleID(item.app)
            if not ok then
                showError(string.format("Failed to launch app by bundle ID: %s", item.app))
            end
        else
            ok = hs.application.launchOrFocus(item.app)
            if not ok then
                showError(string.format("Failed to launch app: %s", item.app))
            end
        end
        if not ok then
            showError(string.format("Failed to launch app: %s", item.app))
        end
    elseif item.folder then
        local ok = hs.open(item.folder)
        if not ok then
            showError(string.format("Failed to open folder: %s", item.folder))
        end
    elseif item.url then
        local ok = hs.urlevent.openURL(item.url)
        if not ok then
            showError(string.format("Failed to open URL: %s", item.url))
        end
    elseif item.command then
        local output, status, type, rc = hs.execute(item.command)
        if not status then
            local errMsg = string.format(
                "Command failed (%s %d): %s\nOutput: %s",
                type or "unknown",
                rc or -1,
                item.command:sub(1, 50) .. (#item.command > 50 and "..." or ""),
                (output or ""):sub(1, 200)
            )
            showError(errMsg)
        end
    elseif item.applescript then
        local ok, result, descriptor = hs.osascript.applescript(item.applescript)
        if not ok then
            local errMsg = "AppleScript failed"
            if type(descriptor) == "table" then
                errMsg = string.format(
                    "AppleScript error: %s (code %s)",
                    descriptor.NSLocalizedDescription or descriptor.NSLocalizedFailureReason or "unknown error",
                    descriptor.NSAppleScriptErrorNumber or "?"
                )
            elseif type(descriptor) == "string" then
                errMsg = string.format("AppleScript error: %s", descriptor:sub(1, 200))
            end
            showError(errMsg)
        end
    elseif item.fun then
        local ok, err = pcall(item.fun)
        if not ok then
            showError(string.format("Lua function failed: %s", tostring(err)))
        end
    else
        showError(string.format("Unknown action type for item: %s", desc))
    end
end

return M
