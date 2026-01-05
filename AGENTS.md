# Hammerspoon Configuration

Leader Key-style hotkey system using hyper (Cmd+Shift+Alt+Ctrl via SuperKey).

# Guidelines for the LLM

I strongly prefer to agree on a design before writing any code. 
So unless explicitely asked to write the code, do not touch the source code, 
just talk about the design, provide SMALL code snippets in the chat (but only
if that is a shorter way to get the idea across than describing it in words
-- don't do both! I can read code and understand it quickly), and or 
create/modify the design documents.

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
