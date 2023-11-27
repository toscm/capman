#include lib.ahk

Keymaps := Map()

Keymaps["Caps"] := [
    ; Movement
    ["CapsLock & i", GoUp],
    ["CapsLock & j", GoLeft],
    ["CapsLock & k", GoDown],
    ["CapsLock & l", GoRight],
    ["CapsLock & o", SendEnd],
    ["CapsLock & u", SendHome],
    ["CapsLock & h", GoWordLeft],
    ["CapsLock & ,", SendPageDown],
    ["CapsLock & 8", SendPageUp],
    ["CapsLock & `;", GoWordRight],

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

    ; Misc
    ["CapsLock & e", SendEscape],
    ["CapsLock & f", SendAltSemicolon],
    ["CapsLock & g", GoToAnything],
    ["CapsLock & r", ReloadCapman],
    ["CapsLock & s", ReleaseShift],
    ["CapsLock & Space", SwitchToModeMouse],
    ; ["CapsLock & Enter", SendWinEnter], ; We can not trigger powertoys because its running with admin privileges I think. Maybe in the future we can think about giving capman admin privileges as well.

    ; Free
    ["CapsLock & c", DoNothing],
    ["CapsLock & q", DoNothing],
    ["CapsLock & v", DoNothing],
    ["CapsLock & x", DoNothing],
    ["CapsLock & y", DoNothing],
    ["CapsLock & z", DoNothing],
    ["CapsLock & w", DoNothing],

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
    ["o", SwitchToModeInsert],
    ["a", SwitchToModeInsert]
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
    ["i", MouseUp24px],
    ["j", MouseLeft24px],
    ["k", MouseDown24px],
    ["l", MouseRight24px],
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

    ["^i", MouseUp1Px],
    ["^j", MouseLeft1Px],
    ["^k", MouseDown1Px],
    ["^l", MouseRight1Px],

    ["CapsLock", SwitchToModeControl]
]

Keymaps["Control"] := [
    ; Movement
    ["*i", GoUp],
    ["*k", GoDown],
    ["*j", Goleft],
    ["*l", GoRight],
    ["*u", SendHome],
    ["*o", SendEnd],
    ["8", SendPageUp],
    [",", SendPageDown],
    ["*h", GoWordLeft],
    ["*`;", GoWordRight],

    ; ModeSwitches
    ["a", SwitchToModeInsert],
    ["CapsLock", SwitchToModeInsert],
    ["g", GoToAnything],
    ["s", PressShift],
    ["+s", ReleaseShift],

    ; Editing
    ["b", Backspace],
    ["c", Copy],
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

    ; Free
    ["q", DoNothing],
    ["p", DoNothing],
    ["w", DoNothing],

    ; Misc
    ["e", SendEscape],
    ["/", ShowActiveHotkeys],

    ; VSCode
    ["'", SendCtrlBacktick], ; Opens Terminal
    ["``", SendCtrlBacktick], ; Opens Terminal
    [".", SendCtrlL] ; Selects current
]

EnableKeyMap(Map) {
    for Index, Row in Map {
        Hotkey(Row[1], Row[2], "On")
    }
}

DisableKeyMap(Map) {
    for Index, Row in Map {
        Hotkey(Row[1], Row[2], "Off")
    }
}

SwitchToMode(NewMode) {
    global Mode
    DisableKeyMap(Keymaps[Mode])
    EnableKeyMap(Keymaps[NewMode])
    Mode := NewMode
    UpdateModeBar()
}

SwitchToModeInsert(Hotkey) {
    SwitchToMode("Insert")
}

SwitchToModeControl(Hotkey) {
    SwitchToMode("Control")
}

SwitchToModeGoto(Hotkey) {
    SwitchToMode("Goto")
}

SwitchToModeMouse(Hotkey) {
    SwitchToMode("Mouse")
}
