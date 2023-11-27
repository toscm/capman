#include lib.ahk

SendOE(hotkey) {
    SendInput("ö")
}

SendAE(hotkey) {
    SendInput("ä")
}

SendUE(hotkey) {
    SendInput("ü")
}

SendOEUpper(hotkey) {
    SendInput("Ö")
}

SendAEUpper(hotkey) {
    SendInput("Ä")
}

SendUEUpper(hotkey) {
    SendInput("Ü")
}

SendSS(hotkey) {
    SendInput("ß")
}

SendCtrlL(hotkey) {
    SendInput("^l")
}

SendEscape(hotkey) {
    SendInput("{Escape}")
}

SendBackspace(hotkey) {
    SendInput("{Backspace}")
}

SendCtrlTab(Hotkey) {
    SendInput("^{Tab}")
}

SendCtrlW(Hotkey) {
    SendInput("^w")
}

SendCtrlShiftTab(Hotkey) {
    SendInput("^+{Tab}")
}


SendCtrlAltTab(Hotkey) {
    SendInput("^!{Tab}")
}

SendCtrlShiftAltTab(Hotkey) {
    SendInput("^+!{Tab}")
}

SendDelete(Hotkey) {
    Send("{Delete}")
}

SendF6(Hotkey) {
    SendInput("{F6}")
}

SendShiftF6(Hotkey) {
    SendInput("+{F6}")
}

SendAltD(Hotkey) {
    SendInput("!d")
}

SendWinEnter(Hotkey) {
    SendInput("#Enter")
}

OpenWindowMenu(Hotkey) {
    SendInput("!{Space}")
    SwitchToModeInsert("")
}

OpenControlPanel(Hotkey) {
    SendInput("^+p")
}

OpenCopilot(Hotkey) {
    SendInput("^+i")
}

SendHome(Hotkey) {
    SendInput("{Blind}{Home}")
}

SendEnd(Hotkey) {
    SendInput("{Blind}{End}")
}

SendPageUp(Hotkey) {
    SendInput("{Blind}{PgUp}")
}

SendPageDown(Hotkey) {
    SendInput("{Blind}{PgDn}")
}

SendCtrlBacktick(Hotkey) {
    SendInput("^``")
}

SendCtrlUp(Hotkey) {
    SendInput("^{Up}")
}

SendCtrlDown(Hotkey) {
    SendInput("^{Down}")
}

ToggleWin(Hotkey) {
    global WinMode
    If (WinMode = "") {
        SendInput("{LWin down}")
        WinMode := "#"
        ; try Hotkey("#l", "Off")
        OutputDebug("WinMode: " . WinMode)
        UpdateModeBar()
    } Else {
        SendInput("{LWin up}")
        WinMode := ""
        ; Hotkey("#l", LockWorkstation, "On")
        OutputDebug("WinMode: " . WinMode)
        UpdateModeBar()
    }
}

ToggleCtrl(Hotkey) {
    global CtrlMode
    If (CtrlMode = "") {
        SendInput("{LCtrl down}")
        CtrlMode := "#"
        UpdateModeBar()
    } Else {
        SendInput("{LCtrl up}")
        CtrlMode := ""
        UpdateModeBar()
    }
}

ReleaseShift(Hotkey) {
    global ShiftMode
    SendInput("{LShift up}")
    ShiftMode := ""
    UpdateModeBar()
}

PressShift(Hotkey) {
    global ShiftMode
    SendInput("{LShift down}")
    ShiftMode := "#"
    UpdateModeBar()
}

ToggleShift(Hotkey) {
    global ShiftMode
    If (ShiftMode = "") {
        SendInput("{LShift down}")
        ShiftMode := "#"
        UpdateModeBar()
    } Else {
        SendInput("{LShift up}")
        ShiftMode := ""
        UpdateModeBar()
    }
}

SendAltSemicolon(Hotkey) {
    SendInput("!;")
}
