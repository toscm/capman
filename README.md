# Capman

Capman turns your Capslock key into a Modifier Key and allows you to control
your Apps and Windows using different modes, such as Control Mode, Visual Mode
and Window Mode.

<img src="img/capman_edited.png" width="33%">

## Installation

1. Clone this repo
2. On Windows: install [AutoHotkey](https://www.autohotkey.com/) (AHK)
3. On MacOS: install [Karabiner-Elements](https://karabiner-elements.pqrs.org/)

## Usage (Windows)

1. Start `capman.ahk` via command
   `. 'C:/Program Files/Autohotkey/v2/AutoHotkey64_UIA.exe' 'c:/Users/tobi/capman/capman.ahk' `
   (replace the paths with your own paths)
2. Use the hotkeys listed in [keymaps.ahk](capman/keymaps.ahk)
3. *Optional:* Create a shortcut to `capman.ahk` and place it in your startup
   folder (e.g.
   `C:\Users\Tobi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`)

## Usage (MacOS) - Experimental

1. Start Karabiner-Elements and open the "Complex Modifications" tab
2. Copy the contents of [karabiner.json](capman/karabiner.json) into your
   Karabiner configuration file located at `~/.config/karabiner/karabiner.json`
3. If you already have other complex modifications, make sure to merge the rules
   properly

## Features

### Capslock as Modifier

As soon as you start Capman, the native functionality of your `Capslock` key
will be disabled. Instead, it will behave as another modifier key, like `Ctrl`,
`Shift`, `Alt` or `Win`. This allows us to bind commonly used keys or
key-combinations, which are hard to reach, to easy-to-reach substitutes. As of
2025-12-15, the following bindings are configured as default. To see the
"100%-up-to-date" list, checkout [keymaps.ahk](capman/keymaps.ahk) directly.

- Movement:
  - `CapsLock & i` = Up
  - `CapsLock & j` = Left
  - `CapsLock & k` = Down
  - `CapsLock & l` = Right
  - `CapsLock & w` = Next word
  - `CapsLock & b` = Previous word
  - `CapsLock & e` = End of line
  - `CapsLock & h` = Beginning of line (Home)
  - `CapsLock & [` = PageUp
  - `CapsLock & ]` = PageDown
  - `CapsLock & ,` = Ctrl+PageUp
  - `CapsLock & .` = Ctrl+PageDown
- Editing:
  - `CapsLock & u` = Undo
  - `CapsLock & d` = Delete
  - `CapsLock & s` = Backspace
- Mode changes:
  - `CapsLock & Space` = Window mode
  - `CapsLock & v` = Visual mode
- Window management:
  - `CapsLock & t` = Switch Tab (Ctrl+Tab)
  - `CapsLock & n` = Switch App (Alt+Tab)
  - `CapsLock & m` = Switch Pane (F6)
- Misc:
  - `CapsLock & c` = Toggles real CapsLock
  - `CapsLock & q` = Escape
  - `CapsLock & f` = Triggers hunt-and-peck (if installed and running)
  - `CapsLock & r` = Reloads Capman
  - `CapsLock & F12` = Show Infobar

### Control Mode

Sometimes it's hard to continuously press CapsLock, e.g. when you move around
the file. For such cases, you can switch to Control Mode by pressing `CapsLock`
once, without any other keys. Your current mode is indicated by a status line at
the top right of your primary monitor (Windows only). By default, the status bar
is only visibly in special modes, such as [control-mode](#control-mode),
[visual-mode](#visual-mode) or [window-mode](#window-mode).

Enabling Control Mode changes your Keybindings as follows:

- Movement:
  - `i`, `j`, `k`, `l` Move cursor
  - `w`, `b` Jump by word
  - `h`, `e` Go Home/End
  - `[`, `]` Page Up/Down
  - `,`, `.` Ctrl + Page Up/Down
- Editing:
  - `p`, `x`, `y` = Paste/Cut/Copy (Yank)
  - `d`, `s` = Delete/Backspace
  - `u`, `r` = Undo/Redo
  - `c` = Toggle CapsLock
  - `/` = Display available hotkeys
- Windowing:
  - `n`, `+n` = Switch App (Ctrl+Alt+Tab)
  - `t`, `+t` = Switch Tab (Ctrl+Tab)
  - `m`, `+m` = Switch Pane (F6/Shift+F6)
- Misc:
  - `v` toggles Visual mode.
  - `a` or `CapsLock` returns to Insert
  - `g` enters GoTo
  - `q` = Escape

### Visual Mode

For selecting and editing text more efficiently, Capman offers a Visual Mode
inspired by Vim's visual mode. To enter Visual Mode, press `CapsLock & v` or
switch from Control Mode by pressing `v`. In visual mode, the following
keybindings are available:

- Selection movement:
  - `i`, `j`, `k`, `l` = Shift+arrows
  - `w`, `b` = select word forward/back
  - `e`, `h` extend to End/Home
- Editing actions auto-exit:
  - `s`, `c`, `d`, `x`, `y` = backspace, copy, delete, cut, yank
  - `Enter`, `Space` = insert newline/space
- Mode exits:
  - `CapsLock`, `a`, `o`, or `v` return to the previous mode
  - `q` cancels selection

### Window Mode (Windows only)

- Enter via: `CapsLock & Space`
- Window movement:
  - `i`, `j`, `k`, `l` send Win+Arrow to snap/resize
  - `w` returns to the previous mode
- Switching:
  - `n`, `+n` cycle through Ctrl+Alt+Tab
  - `CapsLock` falls back to the last mode.
