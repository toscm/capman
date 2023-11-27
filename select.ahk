#include lib.ahk

SelectLeft(hotkey) {
    SendInput("+{Left}")
}

SelectDown(hotkey) {
    SendInput("+{Down}")
}

SelectUp(hotkey) {
    SendInput("+{Up}")
}

SelectRight(hotkey) {
    SendInput("+{Right}")
}

SelectWordBack(hotkey) {
    SendInput("^+{Left}")
}

SelectWord(hotkey) {
    SendInput("^+{Right}")
}
