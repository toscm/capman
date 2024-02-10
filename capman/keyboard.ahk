#include commands.ahk
#include keyboard.ahk
#include keymaps.ahk
#include mouse.ahk


Backspace(Hotkey) => SendInput("{BackSpace}")
Delete(Hotkey) => SendInput("{Delete}")
Cut(Hotkey) => SendInput("^{x}")
Copy(Hotkey) => SendInput("^{c}")
Yank(Hotkey) => SendInput("^{c}")
Paste(Hotkey) => SendInput("^{v}")

Left(hotkey) => SendInput("{Blind}{Left}")
Up(hotkey) => SendInput("{Blind}{Up}")
Down(hotkey) => SendInput("{Blind}{Down}")
Right(hotkey) => SendInput("{Blind}{Right}")

Redo(Hotkey) => SendInput("^{y}")
Undo(Hotkey) => SendInput("^{z}")

GoToFileEnd(hotkey) => SendInput("^{End}")
GoToFileStart(hotkey) => SendInput("^{Home}")
GoToLineEnd(hotkey) => SendInput("{End}")
GoToLineStart(hotkey) => SendInput("{Home}")

OpenControlPanel(Hotkey) => SendInput("^+p")
OpenCopilot(Hotkey) => SendInput("^+i")

CtrlC(Hotkey) => SendInput("^{c}")
CtrlLeft(hotkey) => SendInput("{Blind}^{Left}")
CtrlRight(hotkey) => SendInput("{Blind}^{Right}")

SelectLeft(hotkey) => SendInput("{Blind}+{Left}")
SelectDown(hotkey) => SendInput("{Blind}+{Down}")
SelectUp(hotkey) => SendInput("{Blind}+{Up}")
SelectRight(hotkey) => SendInput("{Blind}+{Right}")
SelectHome(hotkey) => SendInput("{Blind}+{Home}")
SelectEnd(hotkey) => SendInput("{Blind}+{End}")

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
SendWinUp(Hotkey) => SendInput("#{Up}")
SendWinDown(Hotkey) => SendInput("#{Down}")
SendWinLeft(Hotkey) => SendInput("#{Left}")
SendWinRight(Hotkey) => SendInput("#{Right}")
SendWin1(Hotkey) => SendInput("#1")
SendWin2(Hotkey) => SendInput("#2")
SendWin3(Hotkey) => SendInput("#3")
SendWin4(Hotkey) => SendInput("#4")
SendWin5(Hotkey) => SendInput("#5")
SendWin6(Hotkey) => SendInput("#6")
SendWin7(Hotkey) => SendInput("#7")
SendWin8(Hotkey) => SendInput("#8")
SendWin9(Hotkey) => SendInput("#9")
SendSpace(Hotkey) => SendInput("{Space}")
SendEnter(Hotkey) => SendInput("{Enter}")


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

ReleaseWin(Hotkey) {
    global WinMode
    SendInput("{LWin up}")
    WinMode := ""
    UpdateModeBar()
}

PressShift(Hotkey) {
    global ShiftMode
    SendInput("{LShift down}")
    ShiftMode := "#"
    UpdateModeBar()
}

PressWin(Hotkey) {
    global WinMode
    SendInput("{LWin down}")
    WinMode := "#"
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

ToggleWin(Hotkey) {
    global WinMode
    If (WinMode = "") {
        SendInput("{LWin down}")
        WinMode := "#"
        UpdateModeBar()
    } Else {
        SendInput("{LWin up}")
        WinMode := ""
        UpdateModeBar()
    }
}
