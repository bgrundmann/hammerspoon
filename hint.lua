-- hint.lua
-- Display a small hint window showing available keys in a modal

local M = {}

local canvas = nil

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------
local config = {
    padding = 16,
    lineHeight = 24,
    titleHeight = 32,
    keyWidth = 30,
    fontSize = 14,
    titleFontSize = 16,
    cornerRadius = 8,
    backgroundColor = { red = 0.15, green = 0.15, blue = 0.15, alpha = 0.95 },
    titleColor = { red = 1, green = 1, blue = 1, alpha = 1 },
    keyColor = { red = 0.4, green = 0.8, blue = 1, alpha = 1 },
    labelColor = { red = 0.9, green = 0.9, blue = 0.9, alpha = 1 },
    subtitleColor = { red = 0.6, green = 0.6, blue = 0.6, alpha = 1 },
}

--------------------------------------------------------------------------------
-- Calculate window dimensions based on content
--------------------------------------------------------------------------------
local function calculateDimensions(groupItem)
    local maxLabelWidth = 0

    for _, item in ipairs(groupItem.group) do
        -- Estimate width: ~8 pixels per character at font size 14
        local estimatedWidth = #item.label * 8
        maxLabelWidth = math.max(maxLabelWidth, estimatedWidth)
    end

    local width = config.padding * 2 + config.keyWidth + maxLabelWidth + 20
    local height = config.padding * 2 + config.titleHeight + (#groupItem.group * config.lineHeight)

    return math.max(width, 200), height
end

--------------------------------------------------------------------------------
-- Show hint window for a group
--------------------------------------------------------------------------------
function M.show(groupItem)
    M.hide()

    local width, height = calculateDimensions(groupItem)

    -- Position in center of screen
    local screen = hs.screen.mainScreen():frame()
    local x = screen.x + (screen.w - width) / 2
    local y = screen.y + (screen.h - height) / 2

    canvas = hs.canvas.new({ x = x, y = y, w = width, h = height })

    -- Background with rounded corners
    canvas:appendElements({
        type = "rectangle",
        action = "fill",
        roundedRectRadii = { xRadius = config.cornerRadius, yRadius = config.cornerRadius },
        fillColor = config.backgroundColor,
    })

    -- Title
    canvas:appendElements({
        type = "text",
        text = groupItem.label,
        textColor = config.titleColor,
        textFont = ".AppleSystemUIFont",
        textSize = config.titleFontSize,
        frame = {
            x = config.padding,
            y = config.padding,
            w = width - config.padding * 2,
            h = config.titleHeight,
        },
    })

    -- Key hints
    local yOffset = config.padding + config.titleHeight
    for _, item in ipairs(groupItem.group) do
        -- Key
        canvas:appendElements({
            type = "text",
            text = item.key,
            textColor = config.keyColor,
            textFont = ".AppleSystemUIFontBold",
            textSize = config.fontSize,
            frame = {
                x = config.padding,
                y = yOffset,
                w = config.keyWidth,
                h = config.lineHeight,
            },
        })

        -- Dash separator
        canvas:appendElements({
            type = "text",
            text = "-",
            textColor = config.labelColor,
            textFont = ".AppleSystemUIFont",
            textSize = config.fontSize,
            frame = {
                x = config.padding + config.keyWidth,
                y = yOffset,
                w = 20,
                h = config.lineHeight,
            },
        })

        -- Label
        canvas:appendElements({
            type = "text",
            text = item.label,
            textColor = config.labelColor,
            textFont = ".AppleSystemUIFont",
            textSize = config.fontSize,
            frame = {
                x = config.padding + config.keyWidth + 20,
                y = yOffset,
                w = width - config.padding * 2 - config.keyWidth - 20,
                h = config.lineHeight,
            },
        })

        yOffset = yOffset + config.lineHeight
    end

    canvas:level(hs.canvas.windowLevels.overlay)
    canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    canvas:show()
end

--------------------------------------------------------------------------------
-- Hide hint window
--------------------------------------------------------------------------------
function M.hide()
    if canvas then
        canvas:delete()
        canvas = nil
    end
end

return M
