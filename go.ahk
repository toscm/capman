#include lib.ahk

GoLeft(hotkey) {
    Send("{Blind}{Left}")
}

GoDown(hotkey) {
    Send("{Blind}{Down}")
}

GoUp(hotkey) {
    Send("{Blind}{Up}")
}

GoRight(hotkey) {
    Send("{Blind}{Right}")
}

GoWordRight(hotkey) {
    Send("{Blind}^{Right}")
}

GoWordLeft(hotkey) {
    Send("{Blind}^{Left}")
}
