# README

Every shortcut below lists the key first, followed by modifiers appended in
`shift,fn,control,opt,cmd` order; commas indicate sequential presses.

## Capman Bindings

Enabling Control Mode via tapping or holding `caps_lock` will enable the following keybindings.
Visual Mode works similarly, but every movement becomes a selection (as pressing `shift` would do).

+ Activation & Modes
  - `caps_lock (hold)`: Momentary Capman modifier (via `capslock_pressed` variable).
  - `caps_lock (tap)`: Toggle Normal Mode on/off (via `mode 1 ↔ 0`).
  - `a`: Exit any Capman mode (via `mode 0`).
  - `v`: Toggle Visual Mode so nav keys add `shift` (via `mode 1 ↔ 2`).
  - `spacebar+capslock`: Enter window mode (via `mode 3`).
  - `z`: Send a literal Caps Lock press to macOS (via `caps_lock`).
+ Arrow Navigation
  - `i`: Move up (via `up`)
  - `j`: Move left (via `left`)
  - `k`: Move down (via `down`)
  - `l`: Move right (via `right`)
+ Word Navigation
  - `b`: Word left (via `left+opt`)
  - `w`: Word right (via `right+opt`)
+ Line & Document Navigation
  - `h`: Go home, i.e. to line start (via `left+cmd`);
  - `h+cmd` Go to to document top (via `up+cmd`)
  - `e`:Jump to line end (via `right+cmd`);
  - `e+cmd` jumps to document bottom (via `down+cmd`)
+ Editing & Clipboard
  - `d`: Forward delete (via `delete_forward`); `d+shift` sends backspace (via `delete_or_backspace`).
  - `s`: Backspace (via `delete_or_backspace`).
  - `u`: Undo (via `z+cmd`).
  - `r`: Redo (via `z+shift+cmd`).
  - `c`: Copy (via `c+cmd`).
  - `x`: Cut (via `x+cmd`).
  - `y`: Copy mirror on the Y key (via `c+cmd`).
  - `p`: Paste (via `v+cmd`).
+ Search & App Control
  - `f`: Find (via `f+ctrl`); `f+shift` expands to `f+shift+ctrl`.
  - `m`: Reserved placeholder (no output).
  - `n`: macOS app switcher forward/back (via `tab+cmd` / `tab+cmd+shift`).
  - `t`: Tab switcher forward/back (via `tab+ctrl` / `tab+ctrl+shift`).
  - `q`: Escape (via `escape`).
  - `o`: Reserved placeholder (no output).

## Other Bindings

+ Win-like Redo
  - `y+cmd`: Redo (via `z+shift+cmd`).
+ Win-like Home/End Navigation
  - `home`: Jump to line start (via `left+cmd`).
  - `home+cmd`: Jump to document top (via `up+cmd`).
  - `home+shift`: Select to line start (via `left+shift+cmd`).
  - `home+shift+cmd`: Select to document top (via `up+shift+cmd`).
  - `end`: Jump to line end (via `right+cmd`).
  - `end+shift`: Select to line end (via `right+shift+cmd`).
  - `end+cmd`: Jump to document bottom (via `down+cmd`).
  - `end+shift+cmd`: Select to document bottom (via `down+shift+cmd`).
- German Umlauts
  - `a+opt`: Type a-umlaut (via `u+opt, a`).
  - `o+opt`: Type o-umlaut (via `u+opt, o`).
  - `u+opt`: Type u-umlaut (via `u+opt, u`).
  - `a+shift+opt`: Type A-umlaut (via `u+opt, a+shift`).
  - `o+shift+opt`: Type O-umlaut (via `u+opt, o+shift`).
  - `u+shift+opt`: Type U-umlaut (via `u+opt, u+shift`).
  - `s+shift+opt`: Type sharp-s (via `s+opt`).
+ Win-like Text Navigation
  - `left+cmd`: Word left (via `left+opt`).
  - `left+shift+cmd`: Select word left (via `left+shift+opt`).
  - `left+opt`: Last location (via `hyphen+ctrl` in VSCode, `open_bracket+cmd` elsewhere).
  - `right+cmd`: Word right (via `right+opt`).
  - `right+shift+cmd`: Select word right (via `right+shift+opt`).
  - `right+opt`: Next location (via `hyphen+shift+ctrl` in VSCode, `close_bracket+cmd` elsewhere).
  - `up+cmd`: Scroll document up (via `up+fn+ctrl`).
  - `up+opt`: Move line up (no change required).
  - `down+cmd`: Scroll document down (via `down+fn+ctrl`).
  - `down+opt`: Move line down (no change required).

## Capmake Tools

`capmake` is the helper script for maintaining the Capman Karabiner
configuration. Because the `macos` directory is added to your `PATH`, you can
run it from anywhere as `capmake <command>`.

### Commands

- `format` – Rewrites every fragment under `macos/capman/` with consistent JSON
  formatting so they are easy to diff.

- `build` – Loads rules from both `macos/capman/` and `macos/others/`, composes
  them into a single profile, and emits `macos/karabiner.json`.

- `test` – Validates the repo `karabiner.json`, optionally installing it
  temporarily and using `karabiner_cli` to ensure the expected profiles exist.

- `install` – Backs up the current `~/.config/karabiner/karabiner.json` and
  replaces it with the repo version.

Run `capmake --help` to see the command list at any time.

