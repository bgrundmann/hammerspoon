-- Date inserter module
-- Types dates in ISO format into the currently focused window

local M = {}

local function typeDate(date)
    local formatted = os.date("%Y-%m-%d", date)
    hs.eventtap.keyStrokes(formatted)
end

function M.today()
    typeDate(os.time())
end

function M.yesterday()
    typeDate(os.time() - 86400)
end

function M.tomorrow()
    typeDate(os.time() + 86400)
end

function M.next_monday()
    local now = os.time()
    local wday = os.date("*t", now).wday -- 1=Sunday, 2=Monday, ...
    local days_until_monday = (9 - wday) % 7
    if days_until_monday == 0 then days_until_monday = 7 end
    typeDate(now + days_until_monday * 86400)
end

return M
