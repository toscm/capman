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
    ["CapsLock & o", SendEnd],
    ["CapsLock & u", SendHome],
    ["CapsLock & h", CtrlLeft],
    ["CapsLock & ,", SendPageDown],
    ["CapsLock & 8", SendPageUp],
    ["CapsLock & `;", CtrlRight],

    ; Edit
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
    ["CapsLock & e", SendEscape],
    ["CapsLock & f", SendAltSemicolon],
    ["CapsLock & g", GoToAnything],
    ["CapsLock & r", ReloadCapman],
    ["CapsLock & s", ToggleShift],
    ["CapsLock & w", SwitchToModeWindow],
    ["CapsLock & Space", SwitchToModeMouse],
    ["CapsLock & F12", ToggleInfoBar],
    ; ["CapsLock & Enter", SendWinEnter], ; We can not trigger powertoys because its running with admin privileges I think. Maybe in the future we can think about giving capman admin privileges as well.

    ; Free
    ["CapsLock & c", DoNothing],
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
    ["e", SendEscape],
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

    ["*`;", MouseRight120px],

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
    ["*u", SendHome],
    ["*o", SendEnd],
    ["*8", SendPageUp],
    ["*,", SendPageDown],
    ["*h", CtrlLeft],
    ["*`;", CtrlRight],

    ; ModeSwitches
    ["CapsLock", SwitchToModeInsert],
    ["w", SwitchToModeWindow],
    ["a", SwitchToModeInsert],
    ["g", GoToAnything],
    ["s", PressShift],
    ["+s", ReleaseShift],

    ; Editing
    ["b", Backspace],
    ["c", CtrlC],
    ["d", Delete],
    ["v", Paste],
    ["x", Cut],
    ["y", Redo],
    ["z", Undo],

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
    ["e", SendEscape],
    ["/", ShowActiveHotkeys],

    ; VSCode
    ["'", SendCtrlBacktick], ; Opens Terminal
    ["``", SendCtrlBacktick], ; Opens Terminal
    [".", SendCtrlL] ; Selects current
]
