#include commands.ahk
#include keyboard.ahk
#include keymaps.ahk
#include mouse.ahk

Keymaps := Map()

Keymaps["Caps"] := [

    ; Hint: CapsLock can't be combined with other modifier keys

    ; Movement (Vim-style hjkl)
    ["CapsLock & h", Left],
    ["CapsLock & j", Down],
    ["CapsLock & k", Up],
    ["CapsLock & l", Right],
    ["CapsLock & w", Word],
    ["CapsLock & b", WordBack],
    ["CapsLock & e", SendEnd],
    ["CapsLock & i", SendHome],

    ; Edit
    ["CapsLock & u", Undo],
    ["CapsLock & d", Delete],
    ["CapsLock & s", Backspace],

    ; Mode Entry
    ["CapsLock & n", SwitchToModeControl],
    ["CapsLock & v", SwitchToModeVisual],
    ["CapsLock & Space", SwitchToModeWindow],

    ; Window / Tab Management
    ["CapsLock & [", SendPageUp],
    ["CapsLock & ]", SendPageDown],
    ["CapsLock & a", SendAltD],
    ["CapsLock & m", SendF6],
    ["CapsLock & t", SendCtrlTab],
    ["CapsLock & SC033", SendCtrlPageUp], ; CapsLock+, — scancode avoids AHK's comma-parsing quirk
    ["CapsLock & SC034", SendCtrlPageDown], ; CapsLock+.

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
    ["CapsLock", SendEscape],
]

Keymaps["Window"] := [

    ["CapsLock", SendEscape],

    ["a", SwitchToModeInsert],
    ["Space", SwitchToModeInsert],
    ["b", DoNothing],
    ["c", DoNothing],
    ["d", DoNothing],
    ["e", DoNothing],
    ["f", MaximizeWindow],
    ["Enter", MaximizeWindow],
    ["g", DoNothing],
    ["h", SendWinLeft],
    ["i", SwitchToModeInsert],
    ["j", SendWinDown],
    ["k", SendWinUp],
    ["l", SendWinRight],
    ["Up", SendWinUp],
    ["Down", SendWinDown],
    ["Left", SendWinLeft],
    ["Right", SendWinRight],
    ["m", MinimizeWindow],
    ["n", SendCtrlAltTab],
    ["+n", SendCtrlShiftAltTab],
    ["o", DoNothing],
    ["p", DoNothing],
    ["q", QuitApplication],
    ["r", DoNothing],
    ["s", DoNothing],
    ["t", DoNothing],
    ["u", DoNothing],
    ["v", DoNothing],
    ["w", CloseWindow],
    ["x", DoNothing],
    ["y", DoNothing],
    ["z", DoNothing],
]

Keymaps["Mouse"] := [
    ["a", SwitchToModeInsert],
    ["b", DoNothing],
    ["c", DoNothing],
    ["d", RightClick],
    ["e", DoNothing],
    ["f", LeftClick],
    ["g", DoNothing],
    ["h", MouseLeft012Px],
    ["+h", MouseLeft120Px],
    ["i", SwitchToModeInsert],
    ["j", MouseDown012Px],
    ["k", MouseUp012Px],
    ["l", MouseRight012Px],
    ["+l", MouseRight120Px],
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

    ["^h", MouseLeft001Px],
    ["^j", MouseDown001Px],
    ["^k", MouseUp001Px],
    ["^l", MouseRight001Px],

    ["CapsLock", SendEscape],
]

Keymaps["Control"] := [
    ["a", SwitchToModeInsert],
    ["+a", InsertAtLineEnd],
    ["i", SwitchToModeInsert],
    ["+i", InsertAtLineStart],
    ["b", WordBack],
    ["+b", SelectWordBack],
    ["c", ToggleCapsLock],
    ["d", Delete],
    ["+d", DeleteLine],
    ["*e", SendEnd],
    ["f", ExpandSelection],
    ["+f", ShrinkSelection],
    ["g", SwitchToModeGoto],
    ["+g", GoToFileEnd],
    ["h", Left],
    ["+h", SelectLeft],
    ["j", Down],
    ["+j", SelectDown],
    ["k", Up],
    ["+k", SelectUp],
    ["l", Right],
    ["+l", SelectRight], ; Use separate hotkeys for select, because * is slow and we might miss key presses!
    ["m", SendF6],
    ["+m", SendShiftF6],
    ["n", SendCtrlAltTab],
    ["+n", SendCtrlShiftAltTab],
    ["o", InsertNewLine],
    ["+o", OpenLineAbove],
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
    ["+y", YankLine],
    ["z", DoNothing],

    ["0", SendHome],
    ["+4", SendEnd], ; $ — Vim-style end of line

    ["``", SendCtrlBacktick],

    ["[", SendPageUp],
    ["]", SendPageDown],

    [";", SendCtrlL],
    ["'", SendCtrlBacktick],
    ["\", DoNothing],

    [",", SendCtrlPageUp],
    ["+,", SendCtrlShiftPageUp],
    [".", SendCtrlPageDown],
    ["+.", SendCtrlShiftPageDown],
    ["/", SendCtrlF],
    ["+/", ShowActiveHotkeys], ; ? — show help
    ["CapsLock", SendEscape],
]

Keymaps["Visual"] := [
    ; Movement (Vim-style hjkl)
    ["Up", SelectUp],
    ["Down", SelectDown],
    ["Left", SelectLeft],
    ["Right", SelectRight],
    ["h", SelectLeft],
    ["^h", SelectWordBack],
    ["j", SelectDown],
    ["k", SelectUp],
    ["l", SelectRight],
    ["^l", SelectWord],
    ["w", SelectWord],
    ["b", SelectWordBack],
    ["e", SelectEnd],
    ["0", SelectHome],

    ; ModeSwitches
    ["a", SwitchToModeInsert],
    ["i", SwitchToModeInsert],
    ["CapsLock", SendEscape],
    ["o", SwitchToModeInsert],
    ["v", SwitchToModeLast],

    ; Editing
    ["q", SendEscape],
    ["s", BackspaceAndSwitchToModeLast],
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
    ["g", GoToFileStartAndSwitchToModeLast], ; gg — top of file
    ["+g", GoToFileEndAndSwitchToModeLast], ; gG — also bottom of file
    ["h", GoToEditorLeft],
    ["i", SwitchToModeInsert],
    ["j", GoToEditorBelow],
    ["k", GoToEditorAbove],
    ["l", GoToEditorRight],
    ["m", SwitchToModeLast],
    ["n", SendCtrlAltTab],
    ["+n", SendCtrlShiftAltTab],
    ["o", SwitchToModeLast],
    ["p", GoToPanel],
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
    ["CapsLock", SendEscape],
]
