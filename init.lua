-- Hammerspoon Configuration
-- ========================
--
-- This config replicates Leader Key app functionality using Hammerspoon.
--
-- Core idea: SuperKey remaps CapsLock to hyper (CMD+SHIFT+ALT+CTRL).
-- hyper + <key> either:
--   - Executes a direct action (e.g., launch an app)
--   - Enters a modal for a chorded sequence (e.g., hyper+o then n for Obsidian Notes)
--
-- Modals auto-exit after a time delay or on escape/action.

local bind = require("bind")
local utility = require("utility")
local window = require("window")
local dateinserter = require("dateinserter")
local tickets = require("tickets")

--------------------------------------------------------------------------------
-- Actions configuration
--
-- Action types (detected by which key is present):
--   app         = path to .app bundle -> launch or focus
--   folder      = path to folder -> open in Finder
--   url         = URL string -> open in default browser
--   command     = shell command -> execute via hs.execute
--   applescript = AppleScript code -> execute via hs.osascript
--   fun         = Lua function -> call directly
--   group       = nested actions table -> create modal
--------------------------------------------------------------------------------
local actions = {
    { key = "t", label = "Terminal",      app = "com.apple.Terminal" },
    { key = "s", label = "Safari",        app = "com.apple.Safari" },
    { key = "e", label = "Zed",           app = "dev.zed.Zed" },
    { key = "k", label = "Calendar",      app = "com.apple.iCal" },

    { key = "a", label = "LLM Assistant", url = "https://kagi.com/assistant" },

    -- Obsidian vaults
    -- open via open -a to make sure obsidian also get's activated
    {
        key = "o",
        label = "Obsidian",
        group = {
            { key = "n", label = "Notes",           command = "open -a obsidian -u 'obsidian://open?vault=Notes'" },
            { key = "b", label = "BeneUndDavid",    command = "open -a obsidian -u 'obsidian://open?vault=BeneUndDavid'" },
            { key = "c", label = "MagicConsultant", command = "open -a obsidian -u 'obsidian://open?vault=MagicConsultant'" },
            { key = "t", label = "test-vault",      command = "open -a obsidian -u 'obsidian://open?vault=test-vault'" },
        }
    },

    -- Finder locations
    {
        key = "f",
        label = "Finder",
        group = {
            { key = "d", label = "Desktop",                  folder = "/Users/bgrundmann/Desktop" },
            { key = "l", label = "Downloads",                folder = "/Users/bgrundmann/Downloads" },
            { key = "m", label = "Magic",                    folder = "/Users/bgrundmann/Magic" },
            { key = "b", label = "Buchhaltung Förderverein", folder = "/Users/bgrundmann/Programming/foerderverein/buchhaltung" },
        }
    },

    -- Communication
    {
        key = "c",
        label = "Communication",
        group = {
            { key = "e", label = "Email",    url = "https://app.fastmail.com" },
            { key = "m", label = "Messages", app = "com.apple.MobileSMS" },
            { key = "s", label = "Signal",   app = "org.whispersystems.signal-desktop" },
        }
    },

    -- Window management
    {
        key = "w",
        label = "Window management",
        group = {
            { key = "v", label = "Vertical split", fun = window.applyVerticalLayout },
            { key = "m", label = "Maximize",       fun = window.maximize }
        }
    },

    -- Music/Media controls
    {
        key = "m",
        label = "Music",
        group = {
            { key = "p", label = "Pause/Play", applescript = 'tell application "Music" to playpause' },
        }
    },

    -- Utilities
    {
        key = "u",
        label = "Utilities",
        group = {
            { key = "a", label = "Copy app config snippet", fun = utility.copyAppConfigSnippet },
            { key = "d", label = "Due",                     app = "com.phocusllp.duemac" },
            { key = "r", label = "Ticket report",           fun = tickets.showUpcomingTickets },
        }
    },

    -- Dates
    {
        key = "d",
        label = "Dates",
        group = {
            { key = "d", label = "Today",       fun = dateinserter.today },
            { key = "y", label = "Yesterday",   fun = dateinserter.yesterday },
            { key = "t", label = "Tomorrow",    fun = dateinserter.tomorrow },
            { key = "m", label = "Next monday", fun = dateinserter.next_monday }
        }
    },

    -- Direct window positioning
    { key = "left",  label = "Window Left 60%",  fun = window.leftSide(0.6) },
    { key = "right", label = "Window Right 40%", fun = window.rightSide(0.4) },
}

--------------------------------------------------------------------------------
-- Bind all actions
--------------------------------------------------------------------------------
bind.bind(actions)

--------------------------------------------------------------------------------
-- Notify that config loaded
--------------------------------------------------------------------------------
hs.alert.show("Hammerspoon config loaded")
