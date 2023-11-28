#include commands.ahk
#include keyboard.ahk
#include keymaps.ahk
#include mouse.ahk

Backspace(Hotkey) => SendInput("{BackSpace}")

CtrlC(Hotkey) => SendInput("^{c}")
CtrlLeft(hotkey) => SendInput("{Blind}^{Left}")
CtrlRight(hotkey) => SendInput("{Blind}^{Right}")

Cut(Hotkey) => SendInput("^{x}")
Delete(Hotkey) => SendInput("{Delete}")
Down(hotkey) => SendInput("{Blind}{Down}")

GoToFileEnd(hotkey) => SendInput("^{Home}")
GoToFileStart(hotkey) => SendInput("^{Home}")
GoToLineEnd(hotkey) => SendInput("{Home}")
GoToLineStart(hotkey) => SendInput("{Home}")
Left(hotkey) => SendInput("{Blind}{Left}")

OpenControlPanel(Hotkey) => SendInput("^+p")
OpenCopilot(Hotkey) => SendInput("^+i")
Paste(Hotkey) => SendInput("^{v}")
Redo(Hotkey) => SendInput("^{y}")
Right(hotkey) => SendInput("{Blind}{Right}")

SelectLeft(hotkey) => SendInput("+{Left}")
SelectDown(hotkey) => SendInput("+{Down}")
SelectUp(hotkey) => SendInput("+{Up}")
SelectRight(hotkey) => SendInput("+{Right}")
SelectWordBack(hotkey) => SendInput("^+{Left}")
SelectWord(hotkey) => SendInput("^+{Right}")

SendAE(hotkey) => SendInput("ä")
SendAEUpper(hotkey) => SendInput("Ä")
SendAltD(Hotkey) => SendInput("!d")
SendAltSemicolon(Hotkey) => SendInput("!;")
SendBackspace(hotkey) => SendInput("{Backspace}")
SendCtrlAltTab(Hotkey) => SendInput("^!{Tab}")
SendCtrlBacktick(Hotkey) => SendInput("^``")
SendCtrlDown(Hotkey) => SendInput("^{Down}")
SendCtrlL(hotkey) => SendInput("^l")
SendCtrlShiftAltTab(Hotkey) => SendInput("^+!{Tab}")
SendCtrlShiftTab(Hotkey) => SendInput("^+{Tab}")
SendCtrlTab(Hotkey) => SendInput("^{Tab}")
SendCtrlUp(Hotkey) => SendInput("^{Up}")
SendCtrlW(Hotkey) => SendInput("^w")
SendDelete(Hotkey) => Send("{Delete}")
SendEnd(Hotkey) => SendInput("{Blind}{End}")
SendEscape(hotkey) => SendInput("{Escape}")
SendF6(Hotkey) => SendInput("{F6}")
SendHome(Hotkey) => SendInput("{Blind}{Home}")
SendOE(hotkey) => SendInput("ö")
SendOEUpper(hotkey) => SendInput("Ö")
SendPageDown(Hotkey) => SendInput("{Blind}{PgDn}")
SendPageUp(Hotkey) => SendInput("{Blind}{PgUp}")
SendShiftF6(Hotkey) => SendInput("+{F6}")
SendSS(hotkey) => SendInput("ß")
SendUE(hotkey) => SendInput("ü")
SendUEUpper(hotkey) => SendInput("Ü")
SendWinEnter(Hotkey) => SendInput("#Enter")

Undo(Hotkey) => SendInput("^{z}")
Up(hotkey) => SendInput("{Blind}{Up}")

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
