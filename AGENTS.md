# Hammerspoon Configuration

Leader Key-style hotkey system using hyper (Cmd+Shift+Alt+Ctrl via SuperKey).

## File Structure

- `init.lua` - Entry point; defines actions table and calls `bind.bind(actions)`
- `bind.lua` - Modal creation and hotkey binding logic. modal is a bit of a misnomer from the end user perspective these are chorded / sequenced key shortcuts.
- `execute.lua` - Action execution by type
- `utility.lua` - Helper functions (e.g., app chooser)
- `window.lua` - window management functions

## Action Types

Actions are tables with `key`, `label`, and one of:

| Field | Effect |
|-------|--------|
| `app` | `hs.application.launchOrFocus()` - use bundle ID preferred |
| `folder` | `hs.open()` - opens in Finder |
| `url` | `hs.urlevent.openURL()` |
| `command` | `hs.execute()` |
| `applescript` | `hs.osascript.applescript()` |
| `fun` | Calls Lua function directly |
| `group` | Nested actions array; creates modal with 2s timeout |

## Adding New Actions

Use `hyper+u, a` to open app chooser and copy a config snippet to clipboard.

## Key APIs

- [hs.hotkey.modal](https://www.hammerspoon.org/docs/hs.hotkey.modal.html)
- [hs.application](https://www.hammerspoon.org/docs/hs.application.html)
- [hs.chooser](https://www.hammerspoon.org/docs/hs.chooser.html)
