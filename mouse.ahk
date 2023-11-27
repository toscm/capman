#include lib.ahk

LeftClick(Hotkey) {
    ; MouseClick WhichButton, X, Y, ClickCount, Speed, DownOrUp, Relative
    MouseClick("Left", 0, 0, 1, , "D", "R")
    KeyWait(Hotkey)
    MouseClick("Left", 0, 0, 1, , "U", "R")
}

RightClick(Hotkey) {
    ; MouseClick WhichButton, X, Y, ClickCount, Speed, DownOrUp, Relative
    MouseClick("Right", 0, 0, 1, , "D", "R")
    KeyWait(Hotkey)
    MouseClick("Right", 0, 0, 1, , "U", "R")
}

MiddleClick(Hotkey) {
    ; MouseClick WhichButton, X, Y, ClickCount, Speed, DownOrUp, Relative
    MouseClick("Middle", 0, 0, 1, , "D", "R")
    KeyWait(Hotkey)
    MouseClick("Middle", 0, 0, 1, , "U", "R")
}

ScrollUp(Hotkey) {
    Send("{WheelUp}")
}

ScrollDown(Hotkey) {
    Send("{WheelDown}")
}

MouseUp1Px(Hotkey) {
    MouseMove(0, -1, 0, "R")
}

MouseDown1Px(Hotkey) {
    MouseMove(0, 1, 0, "R")
}

MouseRight1Px(Hotkey) {
    MouseMove(1, 0, 0, "R")
}

MouseLeft1Px(Hotkey) {
    MouseMove(-1, 0, 0, "R")
}

MouseUp24Px(Hotkey) {
    MouseMove(0, -24, 0, "R")
}

MouseDown24Px(Hotkey) {
    MouseMove(0, 24, 0, "R")
}

MouseRight24Px(Hotkey) {
    MouseMove(24, 0, 0, "R")
}

MouseLeft24Px(Hotkey) {
    MouseMove(-24, 0, 0, "R")
}

MouseLeft120Px(Hotkey) {
    MouseMove(-120, 0, 0, "R")
}

MouseRight120Px(Hotkey) {
    MouseMove(120, 0, 0, "R")
}
