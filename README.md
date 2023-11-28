# Capman

Capman turns your Capslock key into a Modifier and allows you do control the Windows Desktop Environment using different modes, such as Control Mode, Find Mode and Mouse Mode.

<img src="img/capman_edited.png" width="50%">

## Installation

1. Install [AutoHotkey](https://www.autohotkey.com/) (AHK)
2. Clone this repo

## Usage

1. Start `capman.ahk` via command `. 'C:/Program Files/Autohotkey/v2/AutoHotkey64.exe' /ErrorStdOut=utf-8 'c:/Users/tobi/repos/github/toscm/private/capman_v2/capman.ahk' ` (replace the paths with your own paths)
2. Use the hotkeys listed in [keymap.ahk](keymap.ahk)
3. *Optional:* Create a shortcut to `capman.ahk` and place it in your startup folder (e.g. `C:\Users\Tobi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`)

## Features

### Capslock as Modifier

As soon as you start Capman, the native functionality of your `Capslock` key will be disabled. Instead, it will behave as another modifier key, like `Ctrl`, `Shift`, `Alt` or `Win`. This allows us to bind commonly used keys or key-combinations, which are hard to reach, to easy-to-reach substitutes. As of 2023-11-27, the following bindings are configured as default. To see the "100%-up-to-date" list, checkout [keymap.ahk](keymap.ahk) directly.

```python
# Movement
["CapsLock & i", GoUp]
["CapsLock & j", GoLeft]
["CapsLock & k", GoDown]R
["CapsLock & l", GoRight]
["CapsLock & o", SendEnd]
["CapsLock & u", SendHome]
["CapsLock & h", GoWordLeft]
["CapsLock & ,", SendPageDown]
["CapsLock & 8", SendPageUp]
["CapsLock & `;", GoWordRight]

# Edit
["CapsLock & b", Backspace]
["CapsLock & d", Delete]

# Window Management
["CapsLock & [", ScrollUp]
["CapsLock & ]", ScrollDown]
["CapsLock & a", SendAltD]
["CapsLock & m", SendF6]
["CapsLock & +m", SendShiftF6]
["CapsLock & n", "AltTab"]
["CapsLock & t", SendCtrlTab]
["CapsLock & f", SendAltSemicolon], # Triggers FindMode if [hunt-and-peck](https:#github.com/zsims/hunt-and-peck) is installed

# VSCode
["CapsLock & p", OpenControlPanel]
["CapsLock & ``", SendCtrlBacktick] # Toggles between Terminal and Editor in VSCode
["Capslock & '", SendCtrlBacktick] # Toggles between Terminal and Editor in VSCode
["CapsLock & .", SendCtrlL] # Selects the current line and advances the cursor to the next line

# Misc
["CapsLock & e", SendEscape]
["CapsLock & g", GoToAnything]
["CapsLock & r", ReloadCapman]
["CapsLock & s", ReleaseShift]
["CapsLock & Space", SwitchToModeMouse]
```

### Control Mode

Sometimes it's hard to continously press CapsLock, e.g. when you move around the file. For such cases, you can switch to Control Mode by pressing `CapsLock` once, without any other keys. Your current mode is indicated by a status line at the top right of your primary monitor. By default, the status bar only shows app when you switch from the default mode into a special mode, like [control-mode](control-mode), [mouse-mode](mouse-mode) or [window-mode], but is hidden otherwise.

Control Mode changes your Keybindings as follows:

```python
# Movement
["*i", GoUp]
["*k", GoDown]
["*j", Goleft]
["*l", GoRight]
["*u", SendHome]
["*o", SendEnd]
["8", SendPageUp]
[",", SendPageDown]
["*h", GoWordLeft]
["*`;", GoWordRight]

# ModeSwitches
["a", SwitchToModeInsert]
["CapsLock", SwitchToModeInsert]
["g", GoToAnything]
["s", PressShift]
["+s", ReleaseShift]

# Editing
["b", Backspace]
["c", Copy]
["d", Delete]
["v", Paste]
["x", Cut]
["y", Redo]
["z", Undo]

# Window
["n", SendCtrlAltTab]
["+n", SendCtrlShiftAltTab]
["t", SendCtrlTab]
["+t", SendCtrlShiftTab]
["m", SendF6]
["+m", SendShiftF6]
["f", SendAltSemicolon]

# Misc
["e", SendEscape]
["/", ShowActiveHotkeys]

# VSCode
["'", SendCtrlBacktick] # Opens Terminal
["``", SendCtrlBacktick] # Opens Terminal
[".", SendCtrlL] # Selects current
```

### Find Mode

Press `Capslock-f` to select any button on screen directly via the keyboard. Like Vimium Browser extension. Requires that the superb [hunt-and-peck](https://github.com/zsims/hunt-and-peck) is running (in fact `CapsLock-f` does nothing more than send `Alt-;` to trigger `hunt-and-peck`).

### Mouse Mode

* Enter mouse mode by pressing `Capslock-Space`
* Switch back to control mode by pressing `Capslock`
* Move mouse using usual movement keys  ()
  * 24 pixels left/down/right/up by pressing `j`/`k`/`l`/`i`
  * 120 pixels left/right by pressing `h`/`;`
  * 1 pixel left/down/right/up by pressing `ctrl-j`/`ctrl-k`/`ctrl-l`/`ctrl-i`.
* Press/Release `LButton` by pressing/releasing `f`
* Press/Release `RButton` by pressing/releasing `d`
* Press/Release `MButton` by pressing/releasing `s`
