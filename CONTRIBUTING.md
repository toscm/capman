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
3. Use `capmake format` to format json files inside `macos/`
   - `capmake build` – compose the fragments into `macos/capman-v0.2.0.json`
     (bump the version constant in `macos/capmake` when creating a new release).
   - `capmake test` – (optional) validate the generated file with Karabiner CLI.
   - `capmake install`
     - rebuild the bundle `macos/capman-v0.2.0.json`,
     - copy bundle to  `~/.config/karabiner/assets/complex_modifications`
     - upsert rules inside `~/.config/karabiner/karabiner.json`.

## Repository Layout & Key Files

- `capman` Main codebase for Windows (AutoHotkey).
  - `capman.ahk` Entrypoint; inits GUI, loads config and imports keymaps.
  - `keymaps.ahk` Key bindings
  - `commands.ahk` Public actions (Copy, MoveWindow, etc.)
  - `keyboard.ahk` Internal helpers for enabling/disabling keymaps.
  - `mouse.ahk` Actions for mouse mode.
  - `config.ahk` Global constants and settings.
- `macos` MacOS codebase (Karabiner).
  - `capmake` Helper script to build, format, and install Karabiner rules.
  - `capman/*.json` Individual Karabiner rule fragments.
  - `macos/capman-v*.json` Bundles created by `capmake build`.

## Development Workflow

1. Create a topic branch for your change.
2. Update or add bindings in `keymaps.ahk` and, if necessary, add the matching
   helper in `commands.ahk`.
3. Reload Capman (`CapsLock + r`) and test the updated bindings.
4. If you touch macOS rules, run `capmake format && capmake build` to refresh
   `macos/capman-v0.2.0.json`, then `capmake install` to update your local
   Karabiner config before testing.
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
