--------------------------------------------------------------------------------
-- Utility functions for Hammerspoon configuration
--------------------------------------------------------------------------------

local M = {}

--- Opens a chooser with all installed applications.
--- When an app is selected, copies a config snippet to the clipboard:
---   { key = "", label = "<app name>", app = "<bundle ID>" },
function M.copyAppConfigSnippet()
    -- Get all applications via Spotlight
    local output, status = hs.execute("mdfind 'kMDItemKind == Application'")
    if not status then
        hs.alert.show("Failed to get application list")
        return
    end

    -- Build chooser items
    local choices = {}
    for path in output:gmatch("[^\r\n]+") do
        local info = hs.application.infoForBundlePath(path)
        if info and info.CFBundleIdentifier and info.CFBundleName then
            table.insert(choices, {
                text = info.CFBundleName,
                subText = info.CFBundleIdentifier,
                bundleID = info.CFBundleIdentifier,
                name = info.CFBundleName,
            })
        end
    end

    -- Sort alphabetically by name
    table.sort(choices, function(a, b)
        return a.text:lower() < b.text:lower()
    end)

    -- Create and show chooser
    local chooser = hs.chooser.new(function(choice)
        if choice then
            local snippet = string.format(
                '{ key = "", label = "%s", app = "%s" },',
                choice.name,
                choice.bundleID
            )
            hs.pasteboard.setContents(snippet)
            hs.alert.show("Copied to clipboard!")
        end
    end)
    chooser:choices(choices)
    chooser:searchSubText(true)
    chooser:show()
end

return M
