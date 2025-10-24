# Copilot quick instructions for Capman

Short, actionable notes so Copilot doesn't need to scan everything on
first touch.

## Summary

- Capman turns CapsLock into a modifier key and provides multiple "modes"
  (Insert, Control, Mouse, Goto, Window, Visual) to navigate and control Windows
  and apps via AutoHotkey v2 scripts.
- Requires: AutoHotkey v2 (AutoHotkey64_UIA.exe used in README). Entrypoint:
  `capman/capman.ahk`.

## Key files (what to open first)

- `capman/capman.ahk` — entrypoint; includes other modules and initializes mode
  bars and keymaps.
- `capman/keymaps.ahk` — main mapping table (`Keymaps := Map()`): where most
  key-to-command bindings live per mode.
- `capman/commands.ahk` — high-level named commands (Copy, Paste, SendCtrlL,
  TriggerHuntAndPeck, etc.). Good place to add new application-specific
  commands.
- `capman/keyboard.ahk` — core state & helper functions: `EnableKeyMap`,
  `DisableKeyMap`, `SwitchToMode`, `UpdateModeBar`, and Info/Mode bar UI.
- `capman/mouse.ahk` — mouse movement/press helpers used by Mouse mode.
- `capman/config.ahk` — simple config (version, starting mode, InfoBar
  settings).
- `img/` — screenshots used in README.
- `reg/` — registry scripts to enable/disable Windows Win+L locking behaviour
  (auxiliary).

## How to run (quick)

- Install AutoHotkey v2.
- Run the script (example from README): . 'C:/Program
  Files/Autohotkey/v2/AutoHotkey64_UIA.exe' /ErrorStdOut=utf-8
  'c:/path/to/capman/capman.ahk'
- While running: `CapsLock & r` reloads the script.

## Where to edit common changes

- Change key bindings: edit `capman/keymaps.ahk` (modes are `Keymaps["Insert"]`,
  `Keymaps["Control"]`, etc.).
- Add/modify command implementations: edit `capman/commands.ahk` (use
  descriptive function names and then reference them from `keymaps`).
- Change UI/behaviour (mode colors, infobar): edit `UpdateModeBar()` and
  `ModeBarInit` / `InfoBarInit` in `capman/keyboard.ahk`.
- Per-user config: there's a commented include in `capman/capman.ahk`
  referencing `%A_AppData%/capman/config.ahk` — you can provide a user config
  there.

## Useful quick searches / keywords

- `Keymaps := Map()`
- `EnableKeyMap(`
- `SwitchToMode(`
- `SetCapsLockState("AlwaysOff")`
- `InfoBarInit(` / `ModeBarInit(`
- `TriggerHuntAndPeck` (integration with hunt-and-peck)
- `ReloadCapman` / `ShowActiveHotkeys`

## Small contract (inputs / outputs / success)

- Inputs: physical key presses (CapsLock combos or mode keys).
- Outputs: sent keyboard/mouse events and optional GUI Mode/Info bars.
- Success: binding triggers the corresponding action without breaking Windows
  default flows; reload works via `CapsLock & r`.

## Edge cases & notes

- AutoHotkey v2 syntax is used throughout (do not mix AHK v1 syntax).
- `CapsLock` is forced off with `SetCapsLockState("AlwaysOff")` — expect
  CapsLock LED to be unused.
- Some combos involving native modifiers may behave inconsistently (see comments
  in `keymaps.ahk` about `CapsLock & +t` etc.).
- `vkDC` key (left of Enter / backslash) is experimented as a second CapsLock —
  see `keymaps.ahk` comments.
- Admin-only behaviour: Win+L disabling uses registry writes and requires admin
  for some operations.

## If you add features

- Add a small comment header in the file you modify summarizing intent and a
  one-line usage example.
- Add any new commands to `commands.ahk` and keep them small, reusable, and
  named descriptively.

## Implementation Checklist

If you (Copilot) are asked to implement or change mappings, the checklist to
follow

1. Update `keymaps.ahk` with the mapping (follow existing array style).
2. If a new action is needed, implement in `commands.ahk` or `keyboard.ahk`
   (depending on scope).
3. Reload with `CapsLock & r` and test the mapping in the target app.

## Where to look first for bugs

- `capman/capman.ahk` (initialization and includes)
- `capman/keyboard.ahk` (mode switching, enable/disable mapping, GUI)
- `capman/keymaps.ahk` (typos in mapping entries)

## Contact points / heuristics

- If a mapping doesn't trigger: verify the string used in the mapping matches
  the Hotkey syntax and that the relevant mode is active.
- To list current mappings at runtime: use `CapsLock & /` which runs
  `ShowActiveHotkeys` (opens `keymaps.ahk` in notepad by default).
