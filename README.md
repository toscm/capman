# Capman

Capman turns your CapsLock key into a modifier key with Vim-style bindings.
Hold CapsLock for quick navigation and editing, or switch into one of several modes (Control, Visual, Window, ...) to control text, apps and windows without leaving the home row.

Capman runs on Windows (an AutoHotkey script) and macOS (a small menu-bar app).
Most bindings are the same on both systems; differences are noted below.

## Features

- CapsLock as a modifier key with Vim-style movement and editing (Windows, macOS).

- Modes: Control and Visual Mode (Windows, macOS), Window, Goto and Mouse Mode (Windows).

- A status bar showing the current mode (Windows, macOS).

- [Snippets](#snippets-windows): paste up to twelve saved strings with `CapsLock + F1` ... `CapsLock + F12` (Windows).

- Window management (macOS): Windows-like snapping with `Ctrl+Option+Arrow` (Windows has it built in as `Win+Arrow`), moving by grid tiles, and placing windows on a tile grid of each display by typing tiles or Shift-dragging.
  It replaces tools like Rectangle.

- `Home`, `End` and `Cmd+Y` behave like on Windows and Linux (macOS).

- Display switching like `Win+P`: turn displays on and off, or switch between internal only, external only, mirror and extend with `Ctrl+Option+Cmd+P` (macOS; built into Windows).

- Optional: `Option+a/o/u/s` type ä, ö, ü, ß, independent of the keyboard layout (macOS, off by default, see [Configuration](#configuration-macos)).

- Optional: your own shortcuts that run shell commands, e.g. `Cmd+Shift+6` for a script (macOS, see [Configuration](#configuration-macos)).

## Installation

### Windows

1. Install [AutoHotkey v2](https://www.autohotkey.com/).

2. Clone this repo.

3. Start Capman with `. 'C:/Program Files/Autohotkey/v2/AutoHotkey64_UIA.exe' 'capman/capman.ahk'` (adjust the paths to your system).

To compile Capman into a standalone `capman.exe`, run `capman/build.ps1`.

### macOS

You need macOS 14 or newer and the Xcode command line tools (`xcode-select --install`).

1. Clone this repo and run `macos/install.sh`.
   This builds `~/Applications/Capman.app`, starts it, and adds a LaunchAgent so that it starts at every login.

2. Give Capman the Accessibility permission when macOS asks: System Settings → Privacy & Security → Accessibility (called "Device Control and Data Access" in newer macOS versions).
   If Capman is not listed there, add `~/Applications/Capman.app` with the + button.
   Capman starts working as soon as the permission is granted.

Run `macos/install.sh` again after pulling updates, and `macos/install.sh uninstall` to remove Capman.
The app is signed with a self-made certificate ("Local Code Signing" in your login keychain), so the permission survives updates.

Capman replaces Karabiner-Elements, Rectangle and display tools such as BetterDisplay's "disconnect" for these features.
If you used the older Karabiner version of Capman, remove its "Capman" rule from Karabiner first; the rule files are still in `macos/capman/` (built with `macos/capmake`).

## Overview

- CapsLock alone sends Escape.
  The native CapsLock function is available via `CapsLock + c`.

- Holding CapsLock activates the [CapsLock layer](#capslock-layer).

- `CapsLock + n` enters [Control Mode](#control-mode), Capman's equivalent of Vim's Normal Mode.

- `CapsLock + v` enters [Visual Mode](#visual-mode) for selecting text.

- `CapsLock + Space` enters [Window Mode](#window-mode-windows) for moving and managing windows (Windows); on macOS it opens the [window grid](#window-grid-macos).

- `a` or `i` returns from any mode to Insert Mode, where the keyboard behaves normally.

- The current mode is shown in a small status bar (Windows: top right of the primary monitor, macOS: bottom left like in Vim, and in the menu bar).
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

- `n`: Control Mode, `v`: Visual Mode, `Space`: Windows: Window Mode, macOS: [window grid](#window-grid-macos)

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

- Windows only: `1`-`3`, `5`-`9`, `-`, `=` send `F1`-`F12`; `` ` `` and `'` send `` Ctrl+` `` (toggle terminal), `;` sends `Ctrl+L`; `z` toggles the info bar; `F1`-`F12` paste [snippets](#snippets-windows)

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

- `y`: Copy, then leave Visual Mode

Leaving Visual Mode returns to the previous mode (macOS: always Control Mode).

- `d`, `s`, `x`: Delete, backspace, cut, then leave Visual Mode

- macOS only: `p` pastes over the selection, then leaves Visual Mode

- `v`: Back to the previous mode (macOS: Control Mode)

- `a`, `i`: Insert Mode (Windows: also `o`)

- `q`: Escape

- Windows only: `c` copies, `Enter` and `Space` replace the selection, each followed by leaving Visual Mode

## Window Mode (Windows)

Enter with `CapsLock + Space`.

- `h`, `j`, `k`, `l` and the arrow keys: Snap the window left, down, up, right (native `Win+Arrow` snapping)

- `f`: Maximize the window

- `m`: Minimize the window

- `w`: Close the window (Windows: `Ctrl+F4`, macOS: `Cmd+W`)

- `q`: Quit the app (Windows: `Alt+F4`, macOS: `Cmd+Q`)

- `n`: Next window (Windows: `N` previous window)

- `a`, `i`: Insert Mode; `Space`, `Enter`: type the key and return to Insert Mode

On macOS, the [window management](#window-management-macos) shortcuts below replace Window Mode.

In all modes and in the CapsLock layer, letters without a binding do nothing instead of typing.

## Goto Mode (Windows)

Enter with `CapsLock + g` or `g` in Control Mode.
`g` jumps to the start of the file, `G` to the end; `a` and `i` enter Insert Mode, and any other key returns to the previous mode.

## Mouse Mode (Windows)

Enter with `CapsLock + x`.

- `h`, `j`, `k`, `l`: Move the mouse by 12 px (`H`, `L`: 120 px; `Ctrl` + `h`/`j`/`k`/`l`: 1 px)

- `f`: Left click, `d`: Right click, `s`: Middle click

- `u`, `o`: Scroll up / down

- `a`, `i`: Insert Mode

## Snippets (Windows)

Snippets are saved strings that you paste with a single shortcut.

- `CapsLock + F1` ... `CapsLock + F12`: Paste snippet F1 ... F12

- `CapsLock + Shift + F1` ... `F12`: Save the text in the clipboard as that snippet

- `CapsLock + Ctrl + F1` ... `F12`: Type that snippet into a masked input box (submit it empty to clear the snippet)

Snippets are kept in memory only and never written to disk, so they can hold sensitive strings; they are lost when Capman exits or reloads.
Snippets are pasted through the clipboard, and the previous clipboard is restored afterwards.
Neither the snippet nor the restored clipboard shows up in the `Win+V` clipboard history.

## Always-on Remappings (macOS)

These apply in every mode, to make macOS behave more like Windows and Linux:

- `Home`, `End`: Start / end of the line; `Cmd+Home`, `Cmd+End`: Start / end of the file (with `Shift`, or in Visual Mode, they select)

- `Cmd+Y`: Redo

- `Ctrl+Option+Arrow`, `Ctrl+Option+Cmd+Arrow`, `Ctrl+Option+Enter`, `Ctrl+Option+Cmd+M/H/F`: [Window management](#window-management-macos)

- `Ctrl+Option+Cmd+P`: [Display modes](#displays-macos), like `Win+P` on Windows

- `Ctrl+Option+Shift+Cmd+P`: Turn all displays back on

- Umlauts, if enabled in the [configuration](#configuration-macos): `Option+a`, `Option+o`, `Option+u`, `Option+s` type ä, ö, ü, ß (with `Shift`: Ä, Ö, Ü).
  They are typed directly, so they work with any keyboard layout.
  They are skipped in iTerm2, where Option usually acts as Meta.

## Window Management (macOS)

These shortcuts work everywhere and act on the focused window:

- `Ctrl+Option+Arrow`: [snap](#window-snapping-macos) the window, like `Win+Arrow` on Windows

- `Ctrl+Option+Cmd+Arrow`: move the window to the next grid line without resizing it; at the edge of the display it continues on the neighbouring display

- `Ctrl+Option+Enter`: maximize the window; again restores it

- `Ctrl+Option+Cmd+M`: minimize the window; again brings it back, as long as you haven't focused another window in between

- `Ctrl+Option+Cmd+H`: hide the app; again brings it back, as long as no other app came to the front in between

- `Ctrl+Option+Cmd+F`: switch the window into or out of the macOS full-screen mode

- `CapsLock + Space` or `Ctrl+Option+Cmd+Space`: place the window on the [window grid](#window-grid-macos)

- Dragging a window with `Shift` held: drop it onto the [window grid](#dragging-onto-the-grid)

Minimize, hide and full screen use `Cmd` in addition, because some editors use `Ctrl+Option+letter` themselves.

Windows are placed within the usable area of a display, which leaves out the menu bar, the Dock and the camera notch.
If the menu bar hides automatically, windows go up to the top edge; "Leave Room for Hidden Menu Bar" in the menu keeps them below it.

### Window Snapping (macOS)

`Ctrl+Option+Arrow` follows `Win+Arrow` on Windows:

- Left / Right snap the window to the left / right half.
  A window snapped to the top or bottom stays there, so Left then Up gives the top-left quarter.

- On a quarter, pressing the same side again stretches it to the full height; pressing it once more shrinks it back to the quarter it came from.

- On a half, pressing the same side again moves the window to the opposite half of the neighbouring display.

- On a display whose [grid](#window-grid-macos) has more than two columns, a side is half the columns, rounded up, and pressing the same side again cycles through one column less and its complement instead of moving to the next display.
  With the default 4×2 grid of ultrawide displays that is half, quarter, three quarters, half, ...; with 3×2 it is two thirds, one third, two thirds, ...

- Up snaps to the top half, keeping the window's horizontal position and width.
  On a window at the top, it maximizes; on a maximized window, it restores.
  On a window at the bottom, it stretches to the full height.

- Down snaps to the bottom half, keeping the window's horizontal position and width.
  On a window at the top, it stretches to the full height; on a window at the bottom, it minimizes; on a maximized window, it restores.

So from the top-left quarter, Down goes to the full left half, then to the bottom-left quarter, then minimizes.
Pressing Up right after minimizing brings the window back, as long as you haven't focused another window in between.

"Restore" returns the window to the size and position it had before it was first snapped.
If it was snapped onto another display meanwhile, it is restored on that display.
Capman remembers this per window; moving or resizing a window by hand starts over.
Snapping does not use the macOS full-screen mode.
Windows that cannot shrink to half the display (like Battle.net) get their minimum size instead, stay on the display along the snapped edge, and keep snapping through the same steps.

### Window Grid (macOS)

Each display has a grid of tiles: by default 2×2 (columns × rows), and 4×2 on ultrawide displays (wider than 2:1).
Choose another grid per display under "Window Grid" in the menu, or set it in the [configuration](#configuration-macos).
The grid sets the steps of `Ctrl+Option+Cmd+Arrow` and of snapping on wide grids, and is used by the grid picker:

- `CapsLock + Space` or `Ctrl+Option+Cmd+Space` shows the grid of the display under the mouse, with the tiles numbered `1`-`9`, then `a`-`z`, row by row.

- Type two tiles: the focused window moves to the smallest rectangle covering both.
  On a 4×2 grid, `1` `4` is the top row, `1` `5` the first column, `1` `7` the first three columns, and `5` `7` three quarters of the bottom row.
  For a single tile, type it twice (`2` `2`) or type it and press `Enter`.

- With "Confirm Window Grid with Enter" in the menu, the tiles are only highlighted in blue, and `Enter` moves the window.

- `Backspace` removes the last tile; `Esc`, CapsLock or `Space` closes the grid.

#### Dragging onto the Grid

Hold `Shift` while dragging a window (by its title bar, as usual) to show the grid of the display under the mouse:

- With the pointer near the centre of a tile, that tile is highlighted; near the edge between two tiles, both; near a point where four tiles meet, all four.
  The edge zones are 15% of a tile at each side.

- `Space` fixes the highlighted tiles, so dragging on stretches the highlight from them to the tiles under the pointer, for areas of any size.
  `Space` again lets go of them.

- Releasing the mouse with `Shift` held places the window on the highlighted tiles.
  Releasing `Shift` first hides the grid (pressing it again brings it back); `Esc` cancels for the rest of the drag.

Capman notices a window drag by the window following the mouse at the same size, so it works with any app that macOS can move via Accessibility.
If macOS's own tiling ("Drag windows to screen edges to tile" in System Settings) gets in the way, turn it off.

## Displays (macOS)

The Capman menu lists all displays; click one to turn it off or back on (the last active display can't be turned off).
The built-in display is always listed, even when macOS no longer reports it.
macOS treats a display that is turned off as disconnected and moves its windows to the other displays.

`Ctrl+Option+Cmd+P` opens a list of display modes in the middle of the screen, like `Win+P` on Windows:

- Internal display only, External displays only, Mirror displays, Extend displays

- Each further `Ctrl+Option+Cmd+P` (or `↓`, `↑`, `Tab`) moves the selection, `Enter` applies it, `Esc` closes the list.

Displays stay off only while Capman runs, and there are several ways to get them back:

- `Ctrl+Option+Shift+Cmd+P` or "Turn All Displays On" in the menu turns on every display Capman knows of, always including the built-in one.

- If no usable display is left, for example because the monitor was unplugged while the built-in display was off, Capman turns all displays back on within a second.

- Quitting Capman, and every start of Capman (at login, after a restart of the Mac or after a crash), turns all displays back on.

- `~/Applications/Capman.app/Contents/MacOS/Capman --enable-displays` in a terminal turns all displays on, even if the running Capman is stuck.

Capman keeps asking macOS to turn a display back on for about 20 seconds, until macOS reports it again.

Turning displays off uses the private CoreGraphics function `CGSConfigureDisplayEnabled`, so a future macOS update may break it.

## Configuration (macOS)

The menu-bar icon (the filled CapsLock symbol, coloured like the mode indicator outside Insert Mode: blue for Control, orange for Visual) opens Capman's menu.
Its first part holds Capman's own settings (the umlaut and menu-bar switches, the config file, help), then come the window grid of each display, the displays and the display modes.

Capman reads `~/.config/capman/capman.conf` at startup and on "Reload Config" in its menu.
"Edit Config…" in the menu creates the file if it doesn't exist, and the menu items for umlauts, the hidden menu bar and the window grids change the file directly (a symlinked file stays a symlink).
Example:

```
# Option+a/o/u/s type ä/ö/ü/ß (default: false)
umlauts = true

# Window grid: wait for Enter after the tiles (default: false)
grid_confirm = true

# Keep windows below a menu bar that hides automatically (default: false)
reserve_menubar = true

# Window grid (columns x rows) of a display, by its name as shown in the menu
# (default: 2x2, ultrawide displays 4x2; at most 35 tiles)
grid.LG HDR 4K = 3x2

# Run a shell command on a shortcut, everywhere (none by default)
run.cmd+shift+6 = ~/.local/bin/shotsync edit
```

A `run.<shortcut> = <command>` line binds a shortcut to a shell command, run in the background by zsh with `~/.local/bin` and Homebrew on `PATH`.
The shortcut is any of the modifiers `cmd`, `shift`, `ctrl` and `opt` (or `alt`) plus one key, joined by `+`.
Keys are `a`–`z`, `0`–`9`, `f1`–`f17`, `space`, `return`, `tab`, `escape`, `delete`, `home`, `end`, `pageup`, `pagedown`, the arrows `left`, `right`, `up`, `down`, and `minus`, `equal`, `comma`, `period`, `slash`, `backslash`, `semicolon`, `quote`, `grave`, `leftbracket`, `rightbracket`; letters, digits and punctuation mean the key at that position on a US keyboard.
Such a shortcut wins over a built-in Capman shortcut with the same keys, and the app in front no longer sees it.
The command's output is discarded; a command that fails is logged to the system log ("Capman:" in Console.app).
Since `#` starts a comment, a command cannot contain `#`; put longer commands into a script.

## Contributing

Want to add a feature or port a binding? See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions, repository layout, and submission guidelines.

[alttab]: https://github.com/lwouis/alt-tab-macos
[hap]: https://github.com/zsims/hunt-and-peck
[homerow]: https://homerow.app/

[^word-end]: `e` moves to the next word like `w`; a true "end of word" motion is not available as a system shortcut.

[^dd-yy]: Vim's `dd` / `yy` chords are not detected; Capman binds the line-wise operations to `D` (Shift+d) and `Y` (Shift+y) instead.

