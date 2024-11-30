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
    ; experiments and might be wrong, so if this feature is really needed,
    ; some research should be done!
    ["CapsLock & i", Up],
    ["CapsLock & j", Left],
    ["CapsLock & k", Down],
    ["CapsLock & l", Right],
    ["CapsLock & w", Word],
    ["CapsLock & b", WordBack],
    ["CapsLock & e", SendEnd],
    ["CapsLock & h", SendHome],

    ; Edit
    ["CapsLock & u", Undo],
    ["CapsLock & d", Delete],
    ["CapsLock & s", Backspace],

    ; Window Management
    ["CapsLock & v", SwitchToModeWindow],
    ["CapsLock & [", ScrollUp],
    ["CapsLock & ]", ScrollDown],
    ["CapsLock & a", SendAltD], ; Focus Address Bar
    ["CapsLock & m", SendF6], ; Next Pane
    ["CapsLock & n", "AltTab"], ; Next Window
    ["CapsLock & t", SendCtrlTab], ; Next Tab
    ["CapsLock & ,", SendCtrlPageUp], ; Left Tab
    ["CapsLock & .", SendCtrlPageDown], ; Right Tab

    ; VSCode
    ["CapsLock & p", OpenControlPanel],
    ["CapsLock & o", OpenCopilot],
    ["CapsLock & ``", SendCtrlBacktick],
    ["Capslock & '", SendCtrlBacktick],
    ["CapsLock & `;", SendCtrlL],

    ; Misc
    ["CapsLock & q", SendEscape],
    ["CapsLock & f", TriggerHuntAndPeck],
    ["CapsLock & g", SwitchToModeGoto],
    ["CapsLock & r", ReloadCapman],
    ["CapsLock & F12", ToggleInfoBar],
    ["CapsLock & Space", SendMenu],

    ; F Keys
    ["CapsLock & 1", SendF1],
    ["CapsLock & 2", SendF2],
    ["CapsLock & 3", SendF3],
    ["CapsLock & 4", SendF4],
    ["CapsLock & 5", SendF5],
    ["CapsLock & 6", SendF6],
    ["CapsLock & 7", SendF7],
    ["CapsLock & 8", SendF8],
    ["CapsLock & 9", SendF9],
    ["CapsLock & 0", SendF10],
    ["CapsLock & -", SendF11],
    ["CapsLock & =", SendF12],

    ; Free
    ["CapsLock & c", SendEscape],
    ["CapsLock & x", DoNothing],
    ["CapsLock & y", DoNothing],
    ["CapsLock & z", DoNothing],


    ; Treat right "\|" key (left of enter) as second capslock keys
    ;
    ; This is EXPERIMENTAL!
    ;
    ["vkDC & i", Up],
    ["vkDC & j", Left],
    ["vkDC & k", Down],
    ["vkDC & l", Right],
    ["vkDC & w", Word],
    ["vkDC & b", WordBack],
    ["vkDC & e", SendEnd],
    ["vkDC & h", SendHome],

    ; Edit
    ["vkDC & u", Undo],
    ["vkDC & d", Delete],
    ["vkDC & s", Backspace],

    ; Window Management
    ["vkDC & v", SwitchToModeWindow],
    ["vkDC & [", ScrollUp],
    ["vkDC & ]", ScrollDown],
    ["vkDC & a", SendAltD], ; Focus Address Bar
    ["vkDC & m", SendF6], ; Next Pane
    ["vkDC & n", "AltTab"], ; Next Window
    ["vkDC & t", SendCtrlTab], ; Next Tab
    ["vkDC & ,", SendCtrlPageUp], ; Left Tab
    ["vkDC & .", SendCtrlPageDown], ; Right Tab

    ; VSCode
    ["vkDC & p", OpenControlPanel],
    ["vkDC & o", OpenCopilot],
    ["vkDC & ``", SendCtrlBacktick],
    ["vkDC & '", SendCtrlBacktick],
    ["vkDC & `;", SendCtrlL],

    ; Misc
    ["vkDC & q", SendEscape],
    ["vkDC & f", TriggerHuntAndPeck],
    ["vkDC & g", SwitchToModeGoto],
    ["vkDC & r", ReloadCapman],
    ["vkDC & F12", ToggleInfoBar],
    ["vkDC & Space", SendMenu],

    ; F Keys
    ["vkDC & 1", SendF1],
    ["vkDC & 2", SendF2],
    ["vkDC & 3", SendF3],
    ["vkDC & 4", SendF4],
    ["vkDC & 5", SendF5],
    ["vkDC & 6", SendF6],
    ["vkDC & 7", SendF7],
    ["vkDC & 8", SendF8],
    ["vkDC & 9", SendF9],
    ["vkDC & 0", SendF10],
    ["vkDC & -", SendF11],
    ["vkDC & =", SendF12],

    ; Free
    ["vkDC & c", SendEscape],
    ["vkDC & x", DoNothing],
    ["vkDC & y", DoNothing],
    ["vkDC & z", DoNothing],
]

Keymaps["Insert"] := [
    ["!a", SendAE],
    ["!o", SendOE],
    ["!s", SendSS],
    ["!u", SendUE],

    ["!+o", SendOEUpper],
    ["!+a", SendAEUpper],
    ["!+u", SendUEUpper],

    ["CapsLock", SwitchToModeControl],
    ["vkDC", SwitchToModeControl],
]

Keymaps["Window"] := [

    ["CapsLock", SwitchToModeLast],
    ["vkDC", SwitchToModeLast],

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
    ["z", DoNothing],
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

    ["CapsLock", SwitchToModeControl],
    ["vkDC", SwitchToModeControl],
]

Keymaps["Control"] := [
    ["a", SwitchToModeInsert],
    ["b", WordBack],
    ["+b", SelectWordBack],
    ["c", Copy],
    ["d", Delete],
    ["+d", Backspace],
    ["*e", SendEnd],
    ["f", DoNothing],
    ["g", SwitchToModeGoto],
    ["*h", SendHome],
    ["*i", Up],
    ["*j", Left],
    ["*k", Down],
    ["*l", Right],
    ["m", SendF6],
    ["+m", SendShiftF6],
    ["n", SendCtrlAltTab],
    ["+n", SendCtrlShiftAltTab],
    ["o", DoNothing],
    ["p", Paste],
    ["q", SendEscape],
    ["r", Redo],
    ["s", Backspace],
    ["t", SendCtrlTab],
    ["+t", SendCtrlShiftTab],
    ["u", Undo],
    ["v", SwitchToModeVisual],
    ["w", Word],
    ["+w", SelectWord],
    ["x", Cut],
    ["y", Yank],
    ["z", DoNothing],

    ["``", SendCtrlBacktick],

    ["[", ScrollUp],
    ["]", ScrollDown],

    [";", SendCtrlL],
    ["'", SendCtrlBacktick],
    ["\", DoNothing],

    [",", SendCtrlPageUp],
    [".", SendCtrlPageDown],
    ["/", ShowActiveHotkeys],
    ["CapsLock", SwitchToModeInsert],
    ["vkDC", SwitchToModeInsert],
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
    ["vkDC", SwitchToModeLast],
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
    ["a", GoToEditorArea],
    ["b", GoToPrimarySidebar],
    ["c", SwitchToModeInsert],
    ["d", GoToDefinition],
    ["e", GoToEditorArea],
    ["f", SwitchToModeLast],
    ["g", SwitchToModeLast],
    ["h", SwitchToModeLast],
    ["i", GoToEditorAbove],
    ["j", GoToEditorLeft],
    ["k", GoToEditorBelow],
    ["l", GoToEditorRight],
    ["m", SwitchToModeLast],
    ["n", SendCtrlAltTab],
    ["+n", SendCtrlShiftAltTab],
    ["o", SwitchToModeLast],
    ; ["p", GoToPanel],
    ["q", SendEscape],
    ["r", SwitchToModeLast],
    ["s", GoToSymbolInEditor],
    ["t", GoToPanel],
    ["u", SwitchToModeLast],
    ["v", GoToSecondarySidebar],
    ["w", SendCtrlAltTab],
    ["x", SwitchToModeLast],
    ["y", GoToSymbolInWorkspace],
    ["z", SwitchToModeLast],
    ["Enter", EnterAndSwitchToModeLast],
    ["CapsLock", SwitchToModeLast],
    ["vkDC", SwitchToModeLast],
]
