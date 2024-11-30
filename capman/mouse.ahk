#include commands.ahk
#include keyboard.ahk
#include keymaps.ahk
#include mouse.ahk

MouseDown001Px(Hotkey) => MouseMove(0, 1, 0, "R")
MouseDown012Px(Hotkey) => MouseMove(0, 12, 0, "R")
MouseDown024Px(Hotkey) => MouseMove(0, 24, 0, "R")
MouseLeft001Px(Hotkey) => MouseMove(-1, 0, 0, "R")
MouseLeft012Px(Hotkey) => MouseMove(-12, 0, 0, "R")
MouseLeft024Px(Hotkey) => MouseMove(-24, 0, 0, "R")
MouseLeft120Px(Hotkey) => MouseMove(-120, 0, 0, "R")
MouseRight001Px(Hotkey) => MouseMove(1, 0, 0, "R")
MouseRight012Px(Hotkey) => MouseMove(12, 0, 0, "R")
MouseRight024Px(Hotkey) => MouseMove(24, 0, 0, "R")
MouseRight120Px(Hotkey) => MouseMove(120, 0, 0, "R")
MouseUp001Px(Hotkey) => MouseMove(0, -1, 0, "R")
MouseUp012Px(Hotkey) => MouseMove(0, -12, 0, "R")
MouseUp024Px(Hotkey) => MouseMove(0, -24, 0, "R")
ScrollDown(Hotkey) => Send("{WheelDown}")
ScrollUp(Hotkey) => Send("{WheelUp}")

LeftClick(Hotkey) {
    MouseClick("Left", 0, 0, 1, , "D", "R")
    KeyWait(Hotkey)
    MouseClick("Left", 0, 0, 1, , "U", "R")
}
RightClick(Hotkey) {
    MouseClick("Right", 0, 0, 1, , "D", "R")
    KeyWait(Hotkey)
    MouseClick("Right", 0, 0, 1, , "U", "R")
}
MiddleClick(Hotkey) {
    MouseClick("Middle", 0, 0, 1, , "D", "R")
    KeyWait(Hotkey)
    MouseClick("Middle", 0, 0, 1, , "U", "R")
}
