# Capman

Capman turns your Capslock key into a Modifier and allows you to control the Windows Desktop Environment using different modes, such as Control Mode, Find Mode and Mouse Mode.

<img src="img/capman_edited.png" width="33%">

## Installation

1. Install [AutoHotkey](https://www.autohotkey.com/) (AHK)
2. Clone this repo

## Usage

1. Start `capman.ahk` via command `. 'C:/Program Files/Autohotkey/v2/AutoHotkey64_UIA.exe' 'c:/Users/tobi/capman/capman.ahk' ` (replace the paths with your own paths)
2. Use the hotkeys listed in [keymaps.ahk](keymaps.ahk)
3. *Optional:* Create a shortcut to `capman.ahk` and place it in your startup folder (e.g. `C:\Users\Tobi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`)

## Features

### Capslock as Modifier

As soon as you start Capman, the native functionality of your `Capslock` key will be disabled. Instead, it will behave as another modifier key, like `Ctrl`, `Shift`, `Alt` or `Win`. This allows us to bind commonly used keys or key-combinations, which are hard to reach, to easy-to-reach substitutes. As of 2023-11-27, the following bindings are configured as default. To see the "100%-up-to-date" list, checkout [keymaps.ahk](capman/keymaps.ahk) directly.

```python
# Movement
["CapsLock & i", Up]
["CapsLock & j", Left]
["CapsLock & k", Down]R
["CapsLock & l", Right]
["CapsLock & o", SendEnd]
["CapsLock & u", SendHome]
["CapsLock & h", CtrlLeft]
["CapsLock & ,", SendPageDown]
["CapsLock & 8", SendPageUp]
["CapsLock & `;", CtrlRight]

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

Sometimes it's hard to continuously press CapsLock, e.g. when you move around the file. For such cases, you can switch to Control Mode by pressing `CapsLock` once, without any other keys. Your current mode is indicated by a status line at the top right of your primary monitor. By default, the status bar only shows app when you switch from the default mode into a special mode, like [control-mode](control-mode), [mouse-mode](mouse-mode) or [find-mode](#find-mode), but is hidden otherwise.

Control Mode changes your Keybindings as follows:

```python
# Movement
["*i", Up]
["*k", Down]
["*j", Left]
["*l", Right]
["*u", SendHome]
["*o", SendEnd]
["8", SendPageUp]
[",", SendPageDown]
["*h", CtrlLeft]
["*`;", CtrlRight]

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

## Configuration

The last file included by capman is `%USERPROFILE%/capman/config.ahk`. That means, this file can be used to override anything previously defined. Useful things to configure are:

1. Program options (like the starting mode). For a list of all existing options and their default values see [capman/config.ahk](capman/config.ahk).
2. Hotkeys (e.g. to use the vim motion keys `hjkl` keys instead of `jikl`). For a list of default bindings see [capman/keymaps.ahk](capman/keymaps.ahk).
3. New commands
