#include commands.ahk
#include keyboard.ahk
#include keymaps.ahk
#include mouse.ahk

Keymaps := Map()

Keymaps["Caps"] := [

    ; Hint: CapsLock can't be combined with other modifier keys

    ; Movement
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
    ["CapsLock & v", SwitchToModeVisual],
    ["CapsLock & [", SendPageUp],
    ["CapsLock & ]", SendPageDown],
    ["CapsLock & a", SendAltD],
    ["CapsLock & n", "AltTab"],
    ["CapsLock & m", SendF6],
    ["CapsLock & t", SendCtrlTab],
    ["CapsLock & ,", SendCtrlPageUp],
    ["CapsLock & .", SendCtrlPageDown],

    ; VSCode
    ["CapsLock & p", OpenControlPanel],
    ["CapsLock & o", OpenCopilot],
    ["CapsLock & ``", SendCtrlBacktick],
    ["Capslock & '", SendCtrlBacktick],
    ["CapsLock & `;", SendCtrlL],

    ; Misc
    ["CapsLock & c", ToggleCapsLock],
    ["CapsLock & q", SendEscape],
    ["CapsLock & f", TriggerHuntAndPeck],
    ["CapsLock & g", SwitchToModeGoto],
    ["CapsLock & r", ReloadCapman],
    ["CapsLock & F12", ToggleInfoBar],
    ["CapsLock & Space", SwitchToModeWindow],

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
    ["CapsLock & x", SwitchToModeMouse],
    ["CapsLock & y", DoNothing],
    ["CapsLock & z", DoNothing],
]

Keymaps["Insert"] := [
    ["CapsLock", SwitchToModeControl],
]

Keymaps["Window"] := [

    ["CapsLock", SwitchToModeLast],

    ["$a", SwitchToModeInsert],
    ["$b", DoNothing],
    ["$c", DoNothing],
    ["$d", DoNothing],
    ["$e", DoNothing],
    ["$f", DoNothing],
    ["$g", DoNothing],
    ["$h", DoNothing],
    ["$*i", SendWinUp],
    ["$*j", SendWinLeft],
    ["$*k", SendWinDown],
    ["$*l", SendWinRight],
    ["$m", DoNothing],
    ["$n", SendCtrlAltTab],
    ["$+n", SendCtrlShiftAltTab],
    ["$o", DoNothing],
    ["$p", DoNothing],
    ["$q", DoNothing],
    ["$r", DoNothing],
    ["$s", DoNothing],
    ["$t", DoNothing],
    ["$u", DoNothing],
    ["$v", DoNothing],
    ["$w", SwitchToModeLast],
    ["$x", DoNothing],
    ["$y", DoNothing],
    ["$z", DoNothing],
]

Keymaps["Mouse"] := [
    ["$a", SwitchToModeInsert],
    ["$b", DoNothing],
    ["$c", DoNothing],
    ["d", RightClick],
    ["$e", MouseRight120px],
    ["f", LeftClick],
    ["$g", DoNothing],
    ["$h", MouseLeft120px],
    ["$i", MouseUp012Px],
    ["$j", MouseLeft012Px],
    ["$k", MouseDown012Px],
    ["$l", MouseRight012Px],
    ["$m", DoNothing],
    ["$n", DoNothing],
    ["$o", ScrollDown],
    ["$p", DoNothing],
    ["$q", DoNothing],
    ["$r", DoNothing],
    ["s", MiddleClick],
    ["$t", DoNothing],
    ["$u", ScrollUp],
    ["$v", DoNothing],
    ["$w", DoNothing],
    ["$x", DoNothing],
    ["$y", DoNothing],
    ["$z", DoNothing],

    ["$^i", MouseUp001Px],
    ["$^j", MouseLeft001Px],
    ["$^k", MouseDown001Px],
    ["$^l", MouseRight001Px],

    ["CapsLock", SwitchToModeControl],
]

Keymaps["Control"] := [
    ["$a", SwitchToModeInsert],
    ["$b", WordBack],
    ["$+b", SelectWordBack],
    ["$c", Copy],
    ["$d", Delete],
    ["$+d", Backspace],
    ["$*e", SendEnd],
    ["$f", ExpandSelection],
    ["$+f", ShrinkSelection],
    ["$g", SwitchToModeGoto],
    ["$*h", SendHome],
    ["$*i", Up],
    ["$*j", Left],
    ["$*k", Down],
    ["$*l", Right],
    ["$m", SendF6],
    ["$+m", SendShiftF6],
    ["$n", SendCtrlAltTab],
    ["$+n", SendCtrlShiftAltTab],
    ["$o", DoNothing],
    ["$p", Paste],
    ["$q", SendEscape],
    ["$r", Redo],
    ["$s", Backspace],
    ["$t", SendCtrlTab],
    ["$+t", SendCtrlShiftTab],
    ["$u", Undo],
    ["$v", SwitchToModeVisual],
    ["$w", Word],
    ["$+w", SelectWord],
    ["$x", Cut],
    ["$y", Yank],
    ["$z", ToggleCapsLock],

    ["$``", SendCtrlBacktick],

    ["$*[", SendPageUp],
    ["$*]", SendPageDown],

    ["$;", SendCtrlL],
    ["$'", SendCtrlBacktick],
    ["$\", DoNothing],

    ["$,", SendCtrlPageUp],
    ["$+,", SendCtrlShiftPageUp],
    ["$.", SendCtrlPageDown],
    ["$+.", SendCtrlShiftPageDown],
    ["$/", ShowActiveHotkeys],
    ["CapsLock", SwitchToModeInsert],
]

Keymaps["Visual"] := [
    ; Movement
    ["*Up", SelectUp],
    ["$*Down", SelectDown],
    ["$*Left", SelectLeft],
    ["$*Right", SelectRight],
    ["$*i", SelectUp],
    ["$*j", SelectLeft],
    ["$*k", SelectDown],
    ["$*l", SelectRight],
    ["$*w", SelectWord],
    ["$*b", SelectWordBack],
    ["$*e", SelectEnd],
    ["$*h", SelectHome],

    ; ModeSwitches
    ["$a", SwitchToModeInsert],
    ["$CapsLock", SwitchToModeLast],
    ; ["vkDC", SwitchToModeLast],
    ["$o", SwitchToModeInsert],
    ["$v", SwitchToModeLast],

    ; Editing
    ["$q", SendEscape],
    ["$s", BackspaceAndSwitchToModeLast],
    ["$c", CopyAndSwitchToModeLast],
    ["$d", DeleteAndSwitchToModeLast],
    ["$x", CutAndSwitchToModeLast],
    ["$y", YankAndSwitchToModeLast],
    ["Enter", EnterAndSwitchToModeLast],
    ["Space", SpaceAndSwitchToModeLast],

    ; Free
    ["$.", DoNothing],
    ["$'", DoNothing],
    ["$[", DoNothing],
    ["$]", DoNothing],
    ["$/", DoNothing],
    ["$``", DoNothing],
    ["$+m", DoNothing],
    ["$+n", DoNothing],
    ["$+t", DoNothing],
    ["$f", DoNothing],
    ["$g", DoNothing],
    ["$m", DoNothing],
    ["$n", DoNothing],
    ["$p", DoNothing],
    ["$r", DoNothing],
    ["$t", DoNothing],
    ["$u", DoNothing],
    ["$z", DoNothing],
]

Keymaps["Goto"] := [
    ["$a", GoToEditorArea],
    ["$b", GoToPrimarySidebar],
    ["$c", SwitchToModeInsert],
    ["$d", GoToDefinition],
    ["$e", GoToEditorArea],
    ["$f", SwitchToModeLast],
    ["$g", SwitchToModeLast],
    ["$h", SwitchToModeLast],
    ["$i", GoToEditorAbove],
    ["$j", GoToEditorLeft],
    ["$k", GoToEditorBelow],
    ["$l", GoToEditorRight],
    ["$m", SwitchToModeLast],
    ["$n", SendCtrlAltTab],
    ["$+n", SendCtrlShiftAltTab],
    ["$o", SwitchToModeLast],
    ["$p", GoToPanel],
    ["$q", SendEscape],
    ["$r", SwitchToModeLast],
    ["$s", GoToSymbolInEditor],
    ["$t", GoToPanel],
    ["$u", SwitchToModeLast],
    ["$v", GoToSecondarySidebar],
    ["$w", SendCtrlAltTab],
    ["$x", SwitchToModeLast],
    ["$y", GoToSymbolInWorkspace],
    ["$z", SwitchToModeLast],
    ["Enter", EnterAndSwitchToModeLast],
    ["CapsLock", SwitchToModeLast],
]
