#include lib.ahk

ModeBarInit(text) {
    x := A_ScreenWidth - 420
    ModeBar := Gui()
    ModeBar.Opt("+AlwaysOnTop -Caption +ToolWindow -DPIScale +LastFound")
    ModeBar.MarginX := 5
    ModeBar.MarginY := 0
    ModeBar.SetFont("s14")
    ModeBar.BackColor := "0x448e3a"
    ModeBarText := ModeBar.Add("Text", "w200", text)
    ModeBar.Show("NoActivate x" x " y0 w200")
    ModeBar.Hide()
    return {ModeBar: ModeBar, ModeBarText: ModeBarText}
}

InfoBarInit(text) {
    x := A_ScreenWidth
    InfoBar := Gui()
    InfoBar.Opt("+AlwaysOnTop -Caption +ToolWindow -DPIScale +LastFound")
    InfoBar.MarginX := 5
    InfoBar.MarginY := 0
    InfoBar.SetFont("s14")
    InfoBar.BackColor := "0x448e3a"
    InfoBarText := InfoBar.Add("Text", "w" x, text)
    InfoBar.Show("NoActivate x0 y0 w" x)
    InfoBar.Hide()
    return {InfoBar: InfoBar, InfoBarText: InfoBarText}
}

UpdateModeBar() {
    global Mode, WinMode, CtrlMode, ShiftMode, AltMode, ModeBar, ModeBarText
    ModeBarText.Value := Mode " " WinMode CtrlMode ShiftMode AltMode
    if (Mode = "Insert") {
        ModeBar.Hide()
        ModeBar.BackColor := "0x448e3a"
    } else {
        ModeBar.BackColor := "0xFF0000"
        ModeBar.Show("NoActivate")
    }
}

; DrawBordersAndWait() {
;     activeHwnd := WinGet("ID", "A")  ; Get the active window handle
;     controls := WinGetControlList("ahk_id" . activeHwnd)  ; Get a list of controls in the active window
;     borderWindows := []  ; An array to store the border window handles

;     ; Iterate through controls and draw borders
;     for index, control in StrSplit(controls, "`n", "`r") {
;         pos := WinGetPos("ahk_id" . activeHwnd . " ahk_class " . control)  ; Get position and size of control

;         ; Create a border window
;         Gui := GuiCreate("-Caption +AlwaysOnTop +LastFound +ToolWindow +Border")
;         Gui.BackgroundColor("Blue")
;         Gui.Show("x" . pos.x . " y" . pos.y . " w" . pos.w . " h" . pos.h . " NoActivate")
;         hwnd := Gui.ID  ; Get the handle of the border window
;         borderWindows.Push(hwnd)  ; Store the handle in the array
;     }

;     ; Remove the borders
;     for hwnd in borderWindows {
;         WinClose("ahk_id" . hwnd)
;     }
; }

; DisplayNotification(msg) {
;     note := msg
;     Gui.Show("NoActivate x100 y0 w200")
;     GuiControl("InfoBar:", "InfoBartext", note)
;     SetTimer("HideInfoBar", 3000)
; }