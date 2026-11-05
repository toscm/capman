# Capman

Capman turns your CapsLock key into a modifier key with Vim-style bindings.
Hold CapsLock for quick navigation and editing, or switch into one of several modes (Control, Visual, Window, ...) to control text, apps and windows without leaving the home row.

Capman runs on Windows (AutoHotkey) and macOS (Karabiner-Elements).
Most bindings are the same on both systems; differences are noted below.

## Installation

### Windows

1. Install [AutoHotkey v2](https://www.autohotkey.com/).

2. Clone this repo.

3. Start Capman with `. 'C:/Program Files/Autohotkey/v2/AutoHotkey64_UIA.exe' 'capman/capman.ahk'` (adjust the paths to your system).

To compile Capman into a standalone `capman.exe`, run `capman/build.ps1`.

### macOS

1. Install [Karabiner-Elements](https://karabiner-elements.pqrs.org/), start it and give it the permissions it asks for.

2. Clone this repo and run `./macos/capmake install`.
   This builds the rule bundle and adds the rule "Capman (v0.3.1)" to `~/.config/karabiner/karabiner.json`.

## Overview

- CapsLock alone sends Escape.
  The native CapsLock function is available via `CapsLock + c`.

- Holding CapsLock activates the [CapsLock layer](#capslock-layer).

- `CapsLock + n` enters [Control Mode](#control-mode), Capman's equivalent of Vim's Normal Mode.

- `CapsLock + v` enters [Visual Mode](#visual-mode) for selecting text.

- `CapsLock + Space` enters [Window Mode](#window-mode) for moving and managing windows.

- `a` or `i` returns from any mode to Insert Mode, where the keyboard behaves normally.

- The current mode is shown in a small status bar (Windows: top right of the primary monitor, macOS: bottom right).
  In Insert Mode the bar is hidden.

## CapsLock Layer

While CapsLock is held:

- `h`, `j`, `k`, `l`: Left, Down, Up, Right

- `w`, `e`: Next word, `b`: Previous word

- `i` or `0`: Start of line (Home), `o` or `4`: End of line (End)

- `[`, `]`: Page Up, Page Down

- `,`, `.`: Previous / next tab

- `u`: Undo

- `d`: Delete, `s`: Backspace

- `q`: Escape

- `c`: Toggle CapsLock

- `n`: Control Mode, `v`: Visual Mode, `Space`: Window Mode

- `m`: Window switcher (Windows: `Ctrl+Alt+Tab`, macOS: `Option+Tab` for [AltTab][alttab])

- `f`: Keyboard hints for clicking on screen elements (Windows: [Hunt and Peck][hap] via `Alt+;`, macOS: [Homerow][homerow] via `Shift+Cmd+Space`)

Bindings that differ between the systems:

- `p`: Windows: command palette (`Ctrl+Shift+P`), macOS: paste

- `r`: Windows: reload Capman, macOS: redo

- `t`: Windows: next tab (`Ctrl+Tab`), macOS: top of file

- `g`: Windows: [Goto Mode](#goto-mode-windows), macOS: top of file (`G`: bottom of file)

- `x`: Windows: [Mouse Mode](#mouse-mode-windows), macOS: cut

- `y`: macOS only: copy

- `a`: Windows only: focus the address bar (`Alt+D`)

- `/`: macOS only: find (`Cmd+F`); `?` opens this page

- Windows only: `1`-`3`, `5`-`9`, `-`, `=` send `F1`-`F12`; `` ` `` and `'` send `` Ctrl+` `` (toggle terminal), `;` sends `Ctrl+L`; `F12` toggles the info bar

## Control Mode

Enter with `CapsLock + n`.
Single keys act like Vim's Normal Mode:

- Movement:

  - `h`, `j`, `k`, `l`: Left, Down, Up, Right (the arrow keys work too)

  - `w`, `e`: Next word, `b`: Previous word[^word-end]

  - `0`, `$`: Start / end of line

  - `G`: End of file; Windows: `gg` start of file (via Goto Mode), macOS: `g` start of file

  - `[`, `]`: Page Up / Page Down

  - `,`, `.`: Previous / next tab (Windows: `<`, `>` move the tab)

- Editing:

  - `p`: Paste, `x`: Cut, `y`: Copy (yank)

  - `d`: Delete, `s`: Backspace

  - `D`, `Y`: Cut / copy the current line[^dd-yy]

  - `u`: Undo, `r`: Redo

- Back to Insert Mode:

  - `i`, `a`: At the cursor

  - `I`, `A`: At the start / end of the line

  - `o`, `O`: In a new line below / above

- Other:

  - `/`: Find (`Ctrl+F` / `Cmd+F`)

  - `?`: Show the bindings (Windows: opens `keymaps.ahk`, macOS: opens this page)

  - `n`: Next window (Windows: `N` previous window)

  - `c`: Toggle CapsLock

  - `v`: Visual Mode

  - `q`: Escape

Bindings that differ between the systems:

- `f`: Windows: expand selection (`F`: shrink), macOS: Homerow hints, then Insert Mode

- `m`: Windows: next pane (`F6`, `M`: previous pane), macOS: AltTab, then Insert Mode

- `t`: Windows: next tab (`T`: previous tab), macOS: top of file

- Windows only: `` ` `` and `'` toggle the terminal (`` Ctrl+` ``), `;` sends `Ctrl+L`

## Visual Mode

Enter with `CapsLock + v`, or with `v` from Control Mode.
Movement keys extend the selection:

- `h`, `j`, `k`, `l` and the arrow keys: Select left, down, up, right

- `w`, `e`, `b`: Select by word

- `0`, `$`: Select to the start / end of the line

- macOS only: `g`, `G`: Select to the start / end of the file

Actions:

- `y`: Copy and leave Visual Mode

- `d`, `s`, `x`: Delete, backspace, cut (Windows: then leave Visual Mode)

- `v`: Back to the previous mode (macOS: Control Mode)

- `a`, `i`: Insert Mode (Windows: also `o`)

- `q`: Escape

- Windows only: `c` copies, `Enter` and `Space` replace the selection, each followed by leaving Visual Mode

## Window Mode

Enter with `CapsLock + Space`.

- `h`, `j`, `k`, `l` and the arrow keys: Snap the window left, down, up, right[^tile-windows]

- `f`: Maximize the window[^tile-windows]

- `n`: Next window

- `a`, `i`: Insert Mode; `Space`, `Enter`: type the key and return to Insert Mode

- macOS: `CapsLock + Space` again returns to Insert Mode

- Windows only: `m` minimizes, `w` closes the window (`Ctrl+F4`), `q` quits the app (`Alt+F4`), `N` previous window

## Goto Mode (Windows)

Enter with `CapsLock + g` or `g` in Control Mode.
`g` jumps to the start of the file, `G` to the end; `a` and `i` enter Insert Mode, and any other key returns to the previous mode.

## Mouse Mode (Windows)

Enter with `CapsLock + x`.

- `h`, `j`, `k`, `l`: Move the mouse by 12 px (`H`, `L`: 120 px; `Ctrl` + `h`/`j`/`k`/`l`: 1 px)

- `f`: Left click, `d`: Right click, `s`: Middle click

- `u`, `o`: Scroll up / down

- `a`, `i`: Insert Mode

## Always-on Remappings (macOS)

These apply in every mode, to make macOS behave more like Windows and Linux:

- `Home`, `End`: Start / end of the line; `Cmd+Home`, `Cmd+End`: Start / end of the file (with `Shift` in Visual Mode)

- `Cmd+Y`: Redo

- Umlauts: `Option+a`, `Option+o`, `Option+u` type ä, ö, ü (with `Shift`: Ä, Ö, Ü), `Shift+Option+s` types ß.
  These are skipped in iTerm2, whose profile types umlauts itself.

## Contributing

Want to add a feature or port a binding? See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions, repository layout, and submission guidelines.

[alttab]: https://github.com/lwouis/alt-tab-macos
[hap]: https://github.com/zsims/hunt-and-peck
[homerow]: https://homerow.app/

[^word-end]: `e` moves to the next word like `w`; a true "end of word" motion is not available as a system shortcut.

[^dd-yy]: Vim's `dd` / `yy` chords are not detected; Capman binds the line-wise operations to `D` (Shift+d) and `Y` (Shift+y) instead.

[^tile-windows]: On Windows, Capman sends the native `Win+Arrow` snapping shortcuts.
  On macOS, it sends the default [Rectangle](https://rectangleapp.com/) shortcuts (`Ctrl+Option+Arrow`, `Ctrl+Option+Enter`), so these bindings only work while Rectangle is running.
