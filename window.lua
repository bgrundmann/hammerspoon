local M = {}

function M.maximize()
    local focused = hs.window.focusedWindow()
    focused:maximize()
end

function M.applyVerticalLayout()
    local windows = hs.fnutils.map(hs.window.filter.new():getWindows(), function(win)
        if win ~= hs.window.focusedWindow() then
            return {
                text = win:title(),
                subText = win:application():title(),
                image = hs.image.imageFromAppBundle(win:application():bundleID()),
                id = win:id()
            }
        end
    end)

    local chooser = hs.chooser.new(function(choice)
        if choice ~= nil then
            local layout  = {}
            local focused = hs.window.focusedWindow()
            local toRead  = hs.window.find(choice.id)
            if hs.eventtap.checkKeyboardModifiers()['alt'] then
                hs.layout.apply({
                    { nil, focused, focused:screen(), hs.layout.left50,  0, 0 },
                    { nil, toRead,  focused:screen(), hs.layout.right50, 0, 0 }
                })
            else
                hs.layout.apply({
                    { nil, focused, focused:screen(), hs.layout.left70,  0, 0 },
                    { nil, toRead,  focused:screen(), hs.layout.right30, 0, 0 }
                })
            end
            toRead:raise()
        end
    end)

    chooser
        :placeholderText("Choose window for 70/30 split. Hold ⎇ for 50/50.")
        :searchSubText(true)
        :choices(windows)
        :show()
end

function M.leftSide(percent)
    return function()
        local win = hs.window.focusedWindow()
        if not win then return end
        local screen = win:screen():frame()
        win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w * percent, screen.h))
    end
end

function M.rightSide(percent)
    return function()
        local win = hs.window.focusedWindow()
        if not win then return end
        local screen = win:screen():frame()
        win:setFrame(hs.geometry.rect(screen.x + screen.w * (1 - percent), screen.y, screen.w * percent, screen.h))
    end
end

return M
