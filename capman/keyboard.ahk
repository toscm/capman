#include commands.ahk
#include keyboard.ahk
#include keymaps.ahk
#include mouse.ahk

;; Named Commands
Backspace(Hotkey) => SendInput("{BackSpace}")
Copy(Hotkey) => SendInput("^{c}")
CtrlC(Hotkey) => SendInput("^{c}")
CtrlLeft(hotkey) => SendInput("{Blind}^{Left}")
CtrlRight(hotkey) => SendInput("{Blind}^{Right}")
Cut(Hotkey) => SendInput("^{x}")
Delete(Hotkey) => SendInput("{Delete}")
Down(hotkey) => SendInput("{Blind}{Down}")
Left(hotkey) => SendInput("{Blind}{Left}")
OpenControlPanel(Hotkey) => SendInput("^+p")
OpenCopilot(Hotkey) => SendInput("^+i")
Paste(Hotkey) => SendInput("^{v}")
Redo(Hotkey) => SendInput("^{y}")
Right(hotkey) => SendInput("{Blind}{Right}")
Save(Hotkey) => SendInput("^{s}")
Undo(Hotkey) => SendInput("^{z}")
Up(hotkey) => SendInput("{Blind}{Up}")
Word(hotkey) => SendInput("{Blind}^{Right}")
WordBack(hotkey) => SendInput("{Blind}^{Left}")
Yank(Hotkey) => SendInput("^{c}")

;; Goto Commands
GoToFileEnd(hotkey) => SendInput("^{End}")
GoToFileStart(hotkey) => SendInput("^{Home}")
GoToLineEnd(hotkey) => SendInput("{End}")
GoToLineStart(hotkey) => SendInput("{Home}")

;; Select Commands (TODO: replace with Send Commands)
SelectDown(hotkey) => SendInput("{Blind}+{Down}")
SelectEnd(hotkey) => SendInput("{Blind}+{End}")
SelectHome(hotkey) => SendInput("{Blind}+{Home}")
SelectLeft(hotkey) => SendInput("{Blind}+{Left}")
SelectRight(hotkey) => SendInput("{Blind}+{Right}")
SelectUp(hotkey) => SendInput("{Blind}+{Up}")
SelectWord(hotkey) => SendInput("{Blind}+^{Right}")
SelectWordBack(hotkey) => SendInput("{Blind}+^{Left}")

;; Send Umlaut
SendAE(hotkey) => SendInput("ä")
SendAEUpper(hotkey) => SendInput("Ä")
SendOE(hotkey) => SendInput("ö")
SendOEUpper(hotkey) => SendInput("Ö")
SendSS(hotkey) => SendInput("ß")
SendUE(hotkey) => SendInput("ü")
SendUEUpper(hotkey) => SendInput("Ü")

;; Send Special Characters
SendBackspace(hotkey) => SendInput("{Backspace}")
SendDelete(Hotkey) => Send("{Delete}")
SendEnd(Hotkey) => SendInput("{Blind}{End}")
SendEnter(Hotkey) => SendInput("{Enter}")
SendEscape(hotkey) => SendInput("{Escape}")
SendMenu(hotkey) => SendInput("{AppsKey}")
SendHome(Hotkey) => SendInput("{Blind}{Home}")
SendPageDown(Hotkey) => SendInput("{Blind}{PgDn}")
SendPageUp(Hotkey) => SendInput("{Blind}{PgUp}")
SendSpace(Hotkey) => SendInput("{Space}")

;; Send Function Key
SendF1(Hotkey) => SendInput("{F1}")
SendF2(Hotkey) => SendInput("{F2}")
SendF3(Hotkey) => SendInput("{F3}")
SendF4(Hotkey) => SendInput("{F4}")
SendF5(Hotkey) => SendInput("{F5}")
SendF6(Hotkey) => SendInput("{F6}")
SendF7(Hotkey) => SendInput("{F7}")
SendF8(Hotkey) => SendInput("{F8}")
SendF9(Hotkey) => SendInput("{F9}")
SendF10(Hotkey) => SendInput("{F10}")
SendF11(Hotkey) => SendInput("{F11}")
SendF12(Hotkey) => SendInput("{F12}")

;; Send Alt Combination
SendAltD(Hotkey) => SendInput("!d")
SendAltSemicolon(Hotkey) => SendInput("!;")

;; Send Ctrl Combination
SendCtrlAltTab(Hotkey) => SendInput("^!{Tab}")
SendCtrlBacktick(Hotkey) => SendInput("^``")
SendCtrlDown(Hotkey) => SendInput("^{Down}")
SendCtrlG(hotkey) => SendInput("^g")
SendCtrlL(hotkey) => SendInput("^l")
SendCtrlPageDown(Hotkey) => SendInput("^{PgDn}")
SendCtrlShiftPageDown(Hotkey) => SendInput("^+{PgDn}")
SendCtrlPageUp(Hotkey) => SendInput("^{PgUp}")
SendCtrlShiftPageUp(Hotkey) => SendInput("^+{PgUp}")
SendCtrlShiftAltTab(Hotkey) => SendInput("^+!{Tab}")
SendCtrlShiftTab(Hotkey) => SendInput("^+{Tab}")
SendCtrlTab(Hotkey) => SendInput("^{Tab}")
SendCtrlUp(Hotkey) => SendInput("^{Up}")
SendCtrlW(Hotkey) => SendInput("^w")

;; Send Shift Combination
SendShiftF6(Hotkey) => SendInput("+{F6}")
SendShiftUp(Hotkey) => SendInput("+{Up}")

;; Send Win Combination
SendWin1(Hotkey) => SendInput("#1")
SendWin2(Hotkey) => SendInput("#2")
SendWin3(Hotkey) => SendInput("#3")
SendWin4(Hotkey) => SendInput("#4")
SendWin5(Hotkey) => SendInput("#5")
SendWin6(Hotkey) => SendInput("#6")
SendWin7(Hotkey) => SendInput("#7")
SendWin8(Hotkey) => SendInput("#8")
SendWin9(Hotkey) => SendInput("#9")
SendWinDown(Hotkey) => SendInput("#{Down}")
SendWinEnter(Hotkey) => SendInput("#Enter")
SendWinLeft(Hotkey) => SendInput("#{Left}")
SendWinRight(Hotkey) => SendInput("#{Right}")
SendWinUp(Hotkey) => SendInput("#{Up}")

;; Complex command

TriggerHuntAndPeck(Hotkey) {
    SendInput("!;")
    SwitchToModeInsert(Hotkey)
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