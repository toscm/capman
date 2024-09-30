#include commands.ahk
#include keyboard.ahk
#include keymaps.ahk
#include mouse.ahk

Keymaps := Map()

Keymaps["Caps"] := [

    ; IMPORTANT: CapsLock seems to be not combinable with other modifier keys,
    ; so e.g.
    ;
    ; >>> ["CapsLock & t", SendCtrlTab],       ; Next Tab
    ; >>> ["CapsLock & +t", SendCtrlShiftTab], ; Previous Tab
    ;
    ; doesn't work. However, this is just an observation from interactive
    ; experiments and might be wrong, so if ; this feature is really needed,
    ; some research should be done!

    ; Movement
    ["CapsLock & i", Up],
    ["CapsLock & j", Left],
    ["CapsLock & k", Down],
    ["CapsLock & l", Right],
    ["CapsLock & e", SendEnd],
    ["CapsLock & h", SendHome],

    ; Edit
    ["CapsLock & u", Undo],
    ["CapsLock & d", Delete],

    ; Window Management
    ["CapsLock & w", SwitchToModeWindow],
    ["CapsLock & v", SwitchToModeWindow],
    ["CapsLock & [", ScrollUp],
    ["CapsLock & ]", ScrollDown],
    ["CapsLock & a", SendAltD], ; Focus Address Bar
    ["CapsLock & m", SendF6], ; Next Pane
    ["CapsLock & n", GoToSymbolInEditor], ; Next Window
    ["CapsLock & t", SendCtrlTab], ; Next Tab
    ["CapsLock & y", SendCtrlPageDown], ; Right Tab

    ; VSCode
    ["CapsLock & p", OpenControlPanel],
    ["CapsLock & o", OpenCopilot],
    ["CapsLock & ``", SendCtrlBacktick],
    ["Capslock & '", SendCtrlBacktick],
    ["CapsLock & .", SendCtrlL],

    ; Misc
    ["CapsLock & c", SendEscape],
    ["CapsLock & f", SendAltSemicolon],
    ["CapsLock & g", SwitchToModeGoto],
    ["CapsLock & r", ReloadCapman],
    ["CapsLock & F12", ToggleInfoBar],

    ; Free
    ["CapsLock & b", DoNothing],
    ["CapsLock & q", DoNothing],
    ["CapsLock & s", DoNothing],
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
    ["b", DoNothing],
    ["c", DoNothing],
    ["d", DoNothing],
    ["e", DoNothing],
    ["f", DoNothing],
    ["g", DoNothing],
    ["h", DoNothing],
    ["*i", SendWinUp],
    ["*j", SendWinLeft],
    ["*k", SendWinDown],
    ["*l", SendWinRight],
    ["m", DoNothing],
    ["n", SendCtrlAltTab],
    ["+n", SendCtrlShiftAltTab],
    ["o", DoNothing],
    ["p", DoNothing],
    ["q", DoNothing],
    ["r", DoNothing],
    ["s", DoNothing],
    ["t", DoNothing],
    ["u", DoNothing],
    ["v", DoNothing],
    ["w", SwitchToModeLast],
    ["x", DoNothing],
    ["y", DoNothing],
    ["z", DoNothing]
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
    ["a", SwitchToModeInsert],
    ["*b", WordBack],
    ["c", Copy],
    ["d", Delete],
    ["+d", Backspace],
    ["*e", SendEnd],
    ; ["f", DoNothing],
    ["g", SwitchToModeGoto],
    ["*h", SendHome],
    ["*i", Up],
    ["*j", Left],
    ["*k", Down],
    ["*l", Right],
    ; ["m", DoNothing],
    ; ["n", DoNothing],
    ; ["o", DoNothing],
    ["p", Paste],
    ["q", SendEscape],
    ["r", Redo],
    ; ["s", DoNothing],
    ; ["t", DoNothing],
    ["u", Undo],
    ["v", SwitchToModeVisual],
    ["*w", Word],
    ["x", Cut],
    ["y", Yank],
    ; ["z", DoNothing],

    ["``", SendCtrlBacktick],

    ["[", ScrollUp],
    ["]", ScrollDown],

    [";", DoNothing],
    ["'", SendCtrlBacktick],
    ["\", DoNothing],

    ; [",", DoNothing],
    [".", SendCtrlL],
    ["/", ShowActiveHotkeys],
    ["CapsLock", SwitchToModeInsert],
]

Keymaps["Visual"] := [
    ; Movement
    ["*Up", SelectUp],
    ["*Down", SelectDown],
    ["*Left", SelectLeft],
    ["*Right", SelectRight],
    ["*i", SelectUp],
    ["*j", SelectLeft],
    ["*k", SelectDown],
    ["*l", SelectRight],
    ["*w", SelectWord],
    ["*b", SelectWordBack],
    ["*e", SelectEnd],
    ["*h", SelectHome],

    ; ModeSwitches
    ["a", SwitchToModeInsert],
    ["CapsLock", SwitchToModeLast],
    ["o", SwitchToModeInsert],
    ["v", SwitchToModeLast],

    ; Editing
    ["q", SendEscape],
    ["b", BackspaceAndSwitchToModeLast],
    ["c", CopyAndSwitchToModeLast],
    ["d", DeleteAndSwitchToModeLast],
    ["x", CutAndSwitchToModeLast],
    ["y", YankAndSwitchToModeLast],
    ["Enter", EnterAndSwitchToModeLast],
    ["Space", SpaceAndSwitchToModeLast],

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
    ["r", DoNothing],
    ["t", DoNothing],
    ["u", DoNothing],
    ["z", DoNothing],
]

Keymaps["Goto"] := [
    ["a", GoToSymbolInWorkspace],
    ["b", SwitchToModeLast],
    ["c", SwitchToModeLast],
    ["d", GoToDefinition],
    ["e", SwitchToModeLast],
    ["f", SwitchToModeLast],
    ["g", SwitchToModeLast],
    ["h", SwitchToModeLast],
    ["i", SwitchToModeLast],
    ["j", SwitchToModeLast],
    ["k", SwitchToModeLast],
    ["l", GoToLine],
    ["m", SwitchToModeLast],
    ["n", SwitchToModeLast],
    ["o", SwitchToModeLast],
    ["p", SwitchToModeLast],
    ["q", SwitchToModeLast],
    ["r", SwitchToModeLast],
    ["s", GoToSymbolInEditor],
    ["t", SwitchToModeLast],
    ["u", SwitchToModeLast],
    ["v", SwitchToModeLast],
    ["w", SendCtrlAltTab],
    ["x", SwitchToModeLast],
    ["y", SwitchToModeLast],
    ["z", SwitchToModeLast]
]
