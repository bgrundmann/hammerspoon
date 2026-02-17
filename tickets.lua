--------------------------------------------------------------------------------
-- Ticket report for upcoming shows
--
-- Fetches the shared pretix report and displays sold/available tickets
-- for the next upcoming show date.
--------------------------------------------------------------------------------

local M = {}

local BASE_URL = "https://tickets.beneunddavid.de/magic-theatre/report/shared/"
    .. "JVPFGE1auFrhiILPNtNIAcJBcOYyJBraj3xoONXqpWctt1pgO0L5ZVki8vVeDjgw/"

--- Build the report URL with subevent_from=today, subevent_until=today+4months
local function buildURL()
    local now = os.time()
    local today = os.date("%d.%m.%Y", now)
    -- 4 months ahead (approximate with 122 days)
    local future = os.date("%d.%m.%Y", now + 122 * 86400)
    return BASE_URL .. "?"
        .. "subevent_from_0=" .. today
        .. "&subevent_from_1=00%3A00"
        .. "&subevent_until_0=" .. future
        .. "&subevent_until_1=23%3A59"
        .. "&date_from_0=&date_from_1=&date_until_0=&date_until_1=&subevent="
end

--- Parse all show rows from the HTML table.
--- Returns a list of { title, date, time, size, sold, reserved, available }
local function parseRows(html)
    local rows = {}
    -- Each <tr> block contains a <small class="text-muted"> with "Title - Day, Date Time"
    -- followed by 4 numeric <td class="text-right"> values
    for tr in html:gmatch("<tr>(.-)</tr>") do
        local desc = tr:match('<small class="text%-muted">(.-)</small>')
        if desc then
            desc = desc:match("^%s*(.-)%s*$") -- trim
            -- desc looks like: "Show Title - So, 8. Februar 2026 16:30"
            local title, dateTime = desc:match("^(.-)%s+%-%s+%a+,%s+(.+)$")
            if title and dateTime then
                -- dateTime looks like: "8. Februar 2026 16:30"
                -- Split off the time (last 5 chars)
                local datePart = dateTime:match("^(.-)%s+%d%d:%d%d$")
                local timePart = dateTime:match("(%d%d:%d%d)$")
                -- Collect the 4 right-aligned numbers: size, sold, reserved, available
                local nums = {}
                for val in tr:gmatch('<td class="text%-right">%s*(%d+)%s*</td>') do
                    table.insert(nums, tonumber(val))
                end
                if datePart and timePart and #nums == 4 then
                    table.insert(rows, {
                        title = title,
                        date = datePart,
                        time = timePart,
                        size = nums[1],
                        sold = nums[2],
                        reserved = nums[3],
                        available = nums[4],
                    })
                end
            end
        end
    end
    return rows
end

--- Format the alert text for a group of shows on the same date.
local function formatAlert(shows)
    local lines = {}
    table.insert(lines, "Tickets: " .. shows[1].date)
    for _, s in ipairs(shows) do
        table.insert(lines, string.format(
            "%s %s\nVerkauft: %d", -- /%d | Verfügbar: %d",
            s.time, s.title, s.sold
        --s.size, s.available
        ))
    end
    return table.concat(lines, "\n")
end

function M.showUpcomingTickets()
    local url = buildURL()
    hs.http.asyncGet(url, nil, function(status, body, _headers)
        if status ~= 200 or not body then
            hs.alert.show("Ticket report failed: HTTP " .. tostring(status), 5)
            return
        end
        local rows = parseRows(body)
        if #rows == 0 then
            hs.alert.show("Ticket report: no upcoming shows found", 5)
            return
        end
        -- Group all rows sharing the same date as the first row
        local firstDate = rows[1].date
        local shows = {}
        for _, r in ipairs(rows) do
            if r.date == firstDate then
                table.insert(shows, r)
            else
                break
            end
        end
        hs.alert.show(formatAlert(shows), 5)
    end)
end

return M
