#include commands.ahk
#include keyboard.ahk
#include keymaps.ahk
#include mouse.ahk

Keymaps := Map()

Keymaps["Caps"] := [
    ; Movement
    ["CapsLock & i", Up],
    ["CapsLock & j", (hotkey) => SendInput("{Blind}{Left}")],
    ["CapsLock & k", Down],
    ["CapsLock & l", Right],
    ["CapsLock & e", SendEnd],
    ["CapsLock & h", SendHome],
    ["CapsLock & ,", SendPageDown],
    ["CapsLock & 8", SendPageUp],

    ; Edit
    ["CapsLock & u", Undo],
    ["CapsLock & b", Backspace],
    ["CapsLock & d", Delete],

    ; Window Management
    ["CapsLock & [", ScrollUp],
    ["CapsLock & ]", ScrollDown],
    ["CapsLock & a", SendAltD],
    ["CapsLock & m", SendF6],
    ["CapsLock & +m", SendShiftF6],
    ["CapsLock & n", "AltTab"],
    ["CapsLock & t", SendCtrlTab],

    ; VSCode
    ["CapsLock & p", OpenControlPanel],
    ["CapsLock & ``", SendCtrlBacktick], ; Toggles between Terminal and Editor in VSCode
    ["Capslock & '", SendCtrlBacktick], ; Toggles between Terminal and Editor in VSCode
    ["CapsLock & .", SendCtrlL],
    ["CapsLock & y", OpenCopilot],

    ; Misc
    ["CapsLock & c", SendEscape],
    ["CapsLock & f", SendAltSemicolon],
    ["CapsLock & g", GoToAnything],
    ["CapsLock & r", ReloadCapman],
    ["CapsLock & s", ToggleShift],
    ["CapsLock & w", SwitchToModeWindow],
    ["CapsLock & Space", SwitchToModeMouse],
    ["CapsLock & F12", ToggleInfoBar],
    ; ["CapsLock & Enter", SendWinEnter], ; We can not trigger powertoys because its running with admin privileges I think. Maybe in the future we can think about giving capman admin privileges as well.

    ; Free
    ["CapsLock & o", DoNothing],
    ["CapsLock & q", DoNothing],
    ["CapsLock & v", DoNothing],
    ["CapsLock & x", DoNothing],
    ["CapsLock & z", DoNothing],
]

Keymaps["Insert"] := [
    ["!a", SendAE],
    ["!o", SendOE],
    ["!s", SendSS],
    ["!u", SendUE],

    ["!+o", SendOEUpper],
    ["!+a", SendAEUpper],
    ["!+u", SendUEUpper],

    ["CapsLock", SwitchToModeControl]
]

Keymaps["Window"] := [
    ["CapsLock", SwitchToModeLast],
    ["a", SwitchToModeInsert],
    ["*i", SendWinUp],
    ["*k", SendWinDown],
    ["*j", SendWinLeft],
    ["*l", SendWinRight],
    ["n", SendCtrlAltTab],
    ["+n", SendCtrlShiftAltTab]
]

Keymaps["Mouse"] := [
    ["a", SwitchToModeInsert],
    ["b", DoNothing],
    ["c", DoNothing],
    ["d", RightClick],
    ["e", MouseRight120px],
    ["f", LeftClick],
    ["g", DoNothing],
    ["h", MouseLeft120px],
    ["i", MouseUp012Px],
    ["j", MouseLeft012Px],
    ["k", MouseDown012Px],
    ["l", MouseRight012Px],
    ["m", DoNothing],
    ["n", DoNothing],
    ["o", ScrollDown],
    ["p", DoNothing],
    ["q", DoNothing],
    ["r", DoNothing],
    ["s", MiddleClick],
    ["t", DoNothing],
    ["u", ScrollUp],
    ["v", DoNothing],
    ["w", DoNothing],
    ["x", DoNothing],
    ["y", DoNothing],
    ["z", DoNothing],

    ["^i", MouseUp001Px],
    ["^j", MouseLeft001Px],
    ["^k", MouseDown001Px],
    ["^l", MouseRight001Px],

    ["CapsLock", SwitchToModeControl]
]

Keymaps["Control"] := [
    ; Movement
    ["*i", Up],
    ["*k", Down],
    ["*j", Left],
    ["*l", Right],
    ["*8", SendPageUp],
    ["*,", SendPageDown],
    ["*e", SendEnd],
    ["*h", SendHome],

    ; ModeSwitches
    ["CapsLock", SwitchToModeInsert],
    ["w", SwitchToModeWindow],
    ["a", SwitchToModeInsert],
    ["g", GoToAnything],
    ["s", PressShift],
    ["+s", ReleaseShift],
    ["o", SwitchToModeInsert],

    ; Editing
    ["b", Backspace],
    ["c", Copy],
    ["d", Delete],
    ["r", Redo],
    ["u", Undo],
    ["v", SwitchToModeVisual],
    ["x", Cut],
    ["y", Yank],

    ; Window
    ["n", SendCtrlAltTab],
    ["+n", SendCtrlShiftAltTab],
    ["t", SendCtrlTab],
    ["+t", SendCtrlShiftTab],
    ["m", SendF6],
    ["+m", SendShiftF6],
    ["f", SendAltSemicolon],
    ["[", ScrollUp],
    ["]", ScrollDown],

    ; Free
    ["q", DoNothing],
    ["p", DoNothing],

    ; Misc
    ["/", ShowActiveHotkeys],

    ; VSCode
    ["'", SendCtrlBacktick], ; Opens Terminal
    ["``", SendCtrlBacktick], ; Opens Terminal
    [".", SendCtrlL] ; Selects current
]

Keymaps["Visual"] := [
    ; Movement
    ["*e", SelectEnd],
    ["*h", SelectHome],
    ["*i", SelectUp],
    ["*j", SelectLeft],
    ["*k", SelectDown],
    ["*l", SelectRight],
    ["*Up", SelectUp],
    ["*Down", SelectDown],
    ["*Left", SelectLeft],
    ["*Right", SelectRight],

    ; ModeSwitches
    ["a", SwitchToModeInsert],
    ["CapsLock", SwitchToModeLast],
    ["o", SwitchToModeInsert],
    ["w", SwitchToModeWindow],
    ["v", SwitchToModeLast],

    ; Editing
    ["b", BackspaceAndSwitchToModeLast],
    ["c", CopyAndSwitchToModeLast],
    ["d", DeleteAndSwitchToModeLast],
    ["x", CutAndSwitchToModeLast],
    ["y", YankAndSwitchToModeLast],
    ["Enter", EnterAndSwitchToModeLast],
    ["Space", SpaceAndSwitchToModeLast]

    ; Free
    [".", DoNothing],
    ["'", DoNothing],
    ["[", DoNothing],
    ["]", DoNothing],
    ["/", DoNothing],
    ["``", DoNothing],
    ["+m", DoNothing],
    ["+n", DoNothing],
    ["+t", DoNothing],
    ["f", DoNothing],
    ["g", DoNothing],
    ["m", DoNothing],
    ["n", DoNothing],
    ["p", DoNothing],
    ["q", DoNothing],
    ["r", DoNothing],
    ["t", DoNothing],
    ["u", DoNothing],
    ["z", DoNothing],
]
