-- help.lua
-- Display all available shortcuts in a searchable chooser

local execute = require("execute")

local M = {}

-- Module-level state (built once in init)
-- chooserItems: {text: string, subText: string, idx: integer}[]
-- actionLookup: table<integer, Action>
-- The idx field in each chooserItem is the key into actionLookup for the corresponding action.
local chooserItems = {}
local actionLookup = {}

--------------------------------------------------------------------------------
-- Build a flat list of chooser items from the actions table
-- Populates the module-level actionLookup table
--------------------------------------------------------------------------------
local function buildChooserItems(actions, prefix, groupLabel)
    local items = {}
    prefix = prefix or ""
    groupLabel = groupLabel or ""

    for _, item in ipairs(actions) do
        if item.group then
            -- Recurse into group with updated prefix
            local newPrefix = prefix == "" and item.key or (prefix .. " " .. item.key)
            local newGroupLabel = groupLabel == "" and item.label or (groupLabel .. " / " .. item.label)
            local groupItems = buildChooserItems(item.group, newPrefix, newGroupLabel)
            for _, gi in ipairs(groupItems) do
                table.insert(items, gi)
            end
        else
            -- Build display text
            local keyDisplay = prefix == "" and item.key or (prefix .. " " .. item.key)
            local labelDisplay = groupLabel == "" and item.label or (groupLabel .. " / " .. item.label)

            -- Determine the action type for subtext
            local actionType = ""
            if item.app then
                actionType = "App"
            elseif item.folder then
                actionType = "Folder"
            elseif item.url then
                actionType = "URL"
            elseif item.command then
                actionType = "Command"
            elseif item.applescript then
                actionType = "AppleScript"
            elseif item.fun then
                actionType = "Function"
            end

            -- Use index for lookup (action table can't be stored directly due to function fields)
            local idx = #items + 1
            actionLookup[idx] = item

            table.insert(items, {
                text = string.format("%-12s %s", keyDisplay, labelDisplay),
                subText = actionType,
                idx = idx,
            })
        end
    end

    return items
end

--------------------------------------------------------------------------------
-- Show the help chooser
--------------------------------------------------------------------------------
function M.show()
    local chooser = hs.chooser.new(function(selected)
        if selected and selected.idx then
            local action = actionLookup[selected.idx]
            if action then
                execute.executeAction(action)
            end
        end
    end)

    chooser:choices(chooserItems)
    chooser:placeholderText("Search shortcuts... (select to execute)")
    chooser:searchSubText(true)
    chooser:show()
end

--------------------------------------------------------------------------------
-- Initialize with actions reference
--------------------------------------------------------------------------------
function M.init(actions)
    actionLookup = {}
    chooserItems = buildChooserItems(actions)
end

return M
