-- bind.lua
-- Modal creation and hotkey binding logic

local execute = require("execute")
local help = require("help")
local hint = require("hint")

local hyper = { "cmd", "alt", "shift", "ctrl" }

--------------------------------------------------------------------------------
-- Modal creation for groups
--------------------------------------------------------------------------------
local function createModal(groupItem)
    local modal = hs.hotkey.modal.new()
    local timer = nil

    local function exitModal()
        if timer then
            timer:stop()
            timer = nil
        end
        hint.hide()
        modal:exit()
    end

    function modal:entered()
        -- Show hint window with available keys
        hint.show(groupItem)
        -- Auto-exit after 3 seconds of inactivity
        timer = hs.timer.doAfter(3, exitModal)
    end

    function modal:exited()
        if timer then
            timer:stop()
            timer = nil
        end
        hint.hide()
    end

    -- Bind escape to exit without action
    modal:bind('', 'escape', exitModal)

    -- Bind each action in the group
    for _, item in ipairs(groupItem.group) do
        modal:bind('', item.key, function()
            exitModal()
            execute.executeAction(item)
        end)
    end

    return modal
end

--------------------------------------------------------------------------------
-- Bind all actions to hotkeys
--------------------------------------------------------------------------------
local function bind(actions)
    -- Initialize help with actions reference and bind hyper+/ to show help
    help.init(actions)
    hs.hotkey.bind(hyper, "/", help.show)

    for _, item in ipairs(actions) do
        if item.group then
            -- Create modal for group and bind hyper+key to enter it
            local modal = createModal(item)
            hs.hotkey.bind(hyper, item.key, function()
                modal:enter()
            end)
        else
            -- Direct action bound to hyper+key
            hs.hotkey.bind(hyper, item.key, function()
                execute.executeAction(item)
            end)
        end
    end
end

return {
    bind = bind,
}
