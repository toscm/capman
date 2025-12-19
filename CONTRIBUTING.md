# Contributing to Capman

## Quick Overview

- **Goal:** Turn CapsLock into a modal workflow for navigation, editing, window,
  and mouse control.
- **Tech stack:** AutoHotkey v2 on Windows, Karabiner-Elements on macOS.
- **Entry points:** `capman/capman.ahk` (Windows) and the Karabiner rules under
  `macos/`.
- **How to test quickly:** run `capman.ahk`, press `CapsLock + r` to reload after
  editing, and exercise the bindings you touched.

## Environment Setup

### Windows (AutoHotkey)

1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Clone this repository and open it in your editor.
3. Launch Capman via:
   ```powershell
   . 'C:/Program Files/Autohotkey/v2/AutoHotkey64_UIA.exe' 'C:/path/to/capman/capman.ahk'
   ```
4. Use `CapsLock + r` to reload Capman without restarting AutoHotkey.

### macOS (Karabiner)

1. Install [Karabiner-Elements](https://karabiner-elements.pqrs.org/).
2. Add the repo's `macos/` directory to your `PATH` so the `capmake` helper is
   discoverable, or call it via `./macos/capmake`.
3. Use the helper commands:
   - `capmake format` – format the JSON fragments for consistent diffs.
   - `capmake build` – compose the fragments into `macos/karabiner.json`.
   - `capmake test` – (optional) validate the generated file with Karabiner CLI.
   - `capmake install` – back up and replace your `~/.config/karabiner/karabiner.json`.
4. After installing, enable the "Capman" complex modification in Karabiner.
5. Run `capmake build` whenever you touch the JSON fragments.

## Repository Layout & Key Files

- `capman/capman.ahk` – entrypoint; sets up the GUI elements, loads config, and
  imports the keymaps.
- `capman/keymaps.ahk` – declarative mapping of every mode. Update this for new
  bindings or tweaks.
- `capman/commands.ahk` – higher-level actions (Copy, MoveWindow, etc.). Add new
  behaviour here before wiring it into the keymaps.
- `capman/keyboard.ahk` – runtime helpers for enabling/disabling keymaps and
  updating the mode/infobar state.
- `capman/mouse.ahk` – mouse helpers used by Mouse mode.
- `capman/config.ahk` – version and startup configuration knobs.
- `macos/capman/*.json` – individual Karabiner rule fragments. Edit these when
  porting bindings to macOS.
- `macos/others/*.json` – optional extras (Windows navigation, umlauts, etc.).
- `macos/karabiner.json` – the generated profile (do not edit by hand; use
  `capmake build`).

## Development Workflow

1. Create a topic branch for your change.
2. Update or add bindings in `keymaps.ahk` and, if necessary, add the matching
   helper in `commands.ahk`.
3. Reload Capman (`CapsLock + r`) and test the updated bindings.
4. If you touch macOS rules, run `capmake format && capmake build` and ensure
   Karabiner loads without errors.
5. Update documentation:
   - `README.md` for user-facing behaviour changes.
   - JSON fragment comments or `CONTRIBUTING.md` if process details change.
6. Run `git status` to verify only the expected files changed.
7. Submit a pull request describing the motivation, testing approach, and any
   follow-up work.

## Coding & Style Guidelines

- Use AutoHotkey **v2** syntax everywhere (function calls, expressions, etc.).
- Keep helper commands small and composable; prefer a single responsibility per
  function and add a descriptive name before binding it.
- Add succinct comments when behaviour is surprising (e.g., why a key must send
  `Alt + F4`).
- Default to ASCII in source files and documentation unless there is a strong
  reason to do otherwise.
- When updating Karabiner fragments, keep them formatted via `capmake format`
  before committing.

## Testing Checklist

- Windows: verify the affected bindings in their relevant apps (e.g., window
  mode actions in Explorer, navigation in your editor).
- macOS: enable the updated profile, open Karabiner EventViewer, and confirm
  that each binding emits the expected modifiers/keys.
- Confirm that pressing `CapsLock + r` reloads successfully without errors in
  the AutoHotkey console.
- For documentation updates, build/preview Markdown (VS Code preview is fine) to
  ensure formatting is correct.

Thanks for contributing and happy hacking!
