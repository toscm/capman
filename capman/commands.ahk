#include config.ahk
#include commands.ahk
#include keyboard.ahk
#include keymaps.ahk
#include mouse.ahk

; Global flag for letting native CapsLock behave (passthrough)
CapsPassthrough := false

DoNothing(Hotkey) {
    ; do nothing
}

; Toggle whether native CapsLock is allowed to function (turns native CapsLock on/off)
ToggleCapsLock(Hotkey) {
    global CapsPassthrough, InfoBar, InfoBarText
    if (CapsPassthrough) {
        SetCapsLockState("AlwaysOff")
        CapsPassthrough := false
    } else {
        SetCapsLockState("AlwaysOn")
        CapsPassthrough := true
    }
    UpdateModeBar()
}

BackspaceAndSwitchToModeInsert(Hotkey) {
    Backspace(Hotkey)
    SwitchToModeInsert(Hotkey)
}

CopyAndSwitchToModeInsert(Hotkey) {
    Copy(Hotkey)
    SwitchToModeInsert(Hotkey)
}

DeleteAndSwitchToModeInsert(Hotkey) {
    Delete(Hotkey)
    SwitchToModeInsert(Hotkey)
}

CutAndSwitchToModeInsert(Hotkey) {
    Cut(Hotkey)
    SwitchToModeInsert(Hotkey)
}

YankAndSwitchToModeInsert(Hotkey) {
    Yank(Hotkey)
    SwitchToModeInsert(Hotkey)
}

EnterAndSwitchToModeInsert(Hotkey) {
    SendEnter(Hotkey)
    SwitchToModeInsert(Hotkey)
}

SpaceAndSwitchToModeInsert(Hotkey) {
    SendSpace(Hotkey)
    SwitchToModeInsert(Hotkey)
}

BackspaceAndSwitchToModeLast(Hotkey) {
    Backspace(Hotkey)
    SwitchToModeLast(Hotkey)
}

CopyAndSwitchToModeLast(Hotkey) {
    Copy(Hotkey)
    SwitchToModeLast(Hotkey)
}

DeleteAndSwitchToModeLast(Hotkey) {
    Delete(Hotkey)
    SwitchToModeLast(Hotkey)
}

CutAndSwitchToModeLast(Hotkey) {
    Cut(Hotkey)
    SwitchToModeLast(Hotkey)
}

YankAndSwitchToModeLast(Hotkey) {
    Yank(Hotkey)
    SwitchToModeLast(Hotkey)
}

EnterAndSwitchToModeLast(Hotkey) {
    SendEnter(Hotkey)
    SwitchToModeLast(Hotkey)
}

SpaceAndSwitchToModeLast(Hotkey) {
    SendSpace(Hotkey)
    SwitchToModeLast(Hotkey)
}

GoogleSelection() {
    oldClipboard := ClipboardAll
    Clipboard := "" ; Clear the clipboard
    SendInput("^c")
    if ClipWait(1)
    {
        Run("http://www.google.com/search?q=" . Clipboard)
    } else {
        MsgBox("Command 'GoogleSelection()' failed. Reason: no text selected.")
    }
    Clipboard := oldClipboard
    return
}

GoToLine(Hotkey) {
    SendInput("^g")
    SwitchToModeLast(Hotkey)
    SendInput("l")
}

GoToDefinition(Hotkey) {
    SendInput("{F12}")
    SwitchToModeLast(Hotkey)
}

GoToEditorArea(Hotkey) {
    SendInput("^g")
    SwitchToModeLast(Hotkey)
    SendInput("a")
}

GoToPanel(Hotkey) {
    SendInput("^g")
    SwitchToModeLast(Hotkey)
    SendInput("p")
}

GoToPrimarySidebar(Hotkey) {
    SendInput("^g")
    SwitchToModeLast(Hotkey)
    SendInput("b")
}

GoToSecondarySidebar(Hotkey) {
    SendInput("^g")
    SwitchToModeLast(Hotkey)
    SendInput("^b")
}

GoToSymbolInEditor(Hotkey) {
    SendInput("^+{o}")
    SwitchToModeInsert(Hotkey)
}

GoToSymbolInWorkspace(Hotkey) {
    SendInput("^t")
    SwitchToModeInsert(Hotkey)
}

GoToEditorLeft(Hotkey) {
    SendInput("^k")
    SendInput("^{Left}")
}

GoToEditorRight(Hotkey) {
    SendInput("^k")
    SendInput("^{Right}")
}

GoToEditorAbove(Hotkey) {
    SendInput("^k")
    SendInput("^{Up}")
}

GoToEditorBelow(Hotkey) {
    SendInput("^k")
    SendInput("^{Down}")
}

InsertNewLine(Hotkey) {
    SendInput("{End}")
    SendInput("{Enter}")
    SwitchToModeInsert("")
}

ListWindowControls()
{
    try
    {
        Controls := WinGetControls("A")
        ControlList := ""
        for ClassNN in Controls
            ControlList .= ClassNN . "`n"
        if (ControlList = "")
            ToolTip "The active window has no controls."
        else
            ToolTip ControlList
    }
    catch TargetError
        ToolTip "No visible window is active."
}

OpenSelectionInDefaultApp() {
    clipboardOld := ClipboardAll
    Clipboard := ""
    SendInput("^c")
    ClipWait(0.5)
    if (Clipboard != "") {
        try {
            Run(Clipboard)
        } catch {
            MsgBox("Error running: " Clipboard)
        }
    }
    Clipboard := clipboardOld
    return
}

PipeSelectionThroughCommand() {
    ; CtrlC current selection
    ClipSaved := Clipboard
    Clipboard := ""
    SendInput("^c")
    Selection := Clipboard
    ClipWait()

    ; Pipe selection through `command` and into clipboard
    Command := InputBox("Run:")
    Clipboard := ""
    MsgBox(A_ComSpec "/c echo " Selection " | " Command " | clip")
    RunWait(A_ComSpec "/c echo " Selection " | " Command " | clip")
    ClipWait()

    ; Paste current clipboard content and restore old content
    SendInput("^v")
    Clipboard := ClipSaved ; Restore clipboard
    ClipSaved := "" ; Free memory
}

ResizeWindow(Hotkey) {
    ; https://superuser.com/questions/18215/is-there-a-way-to-resize-a-window-to-specific-sizes-eg-800x600-1024x768
    window := WinExist("A")
    width := InputBox("Width", "", "W140 H130")
    height := InputBox("Height", "", "W140 H130")
    WinMove("ahk_id " window, "", "", "", width, height)
    return
}

LockWorkstation(Hotkey) {
    MsgBox("Trying to lock workstation.")
    DllCall("LockWorkStation")
}

DisableWinL(Hotkey) {
    RegWrite(0, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System","DisableLockWorkstation")
}

EnableWinL(Hotkey) {
    RegWrite(1, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System","DisableLockWorkstation")
}

ExitFunc(ExitReason, ExitCode)
{
    EnableWinL("")
}

ReloadCapman(Hotkey) {
    Reload()
}

ShowActiveHotkeys(Hotkey) {
    Run("notepad.exe /A keymaps.ahk")
}

OpenWindowMenu(Hotkey) {
    SendInput("!{Space}")
    SwitchToModeInsert("")
}

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
    x := A_ScreenWidth - 820
    InfoBar := Gui()
    InfoBar.Opt("+AlwaysOnTop -Caption +ToolWindow -DPIScale +LastFound")
    InfoBar.MarginX := 5
    InfoBar.MarginY := 0
    InfoBar.SetFont("s14")
    InfoBar.BackColor := "0x448e3a"
    InfoBarText := InfoBar.Add("Text", "w400", text)
    InfoBar.Show("NoActivate x" x " y0 w400")
    if (InfoBarHideAtStartup) {
        InfoBar.Hide()
    }
    return {InfoBar: InfoBar, InfoBarText: InfoBarText}
}

ToggleInfoBar(Hotkey) {
    global InfoBar, InfoBarIsVisible
    if (InfoBarIsVisible) {
        InfoBar.Hide()
        InfoBarIsVisible := false
    } else {
        InfoBar.Show("NoActivate")
        InfoBarIsVisible := true
    }
}

UpdateModeBar() {
    global Mode, WinMode, CtrlMode, ShiftMode, AltMode, ModeBar, InfoBar, ModeBarText
    ModeBarText.Value := Mode " " WinMode CtrlMode ShiftMode AltMode
    ModeColors := Map(
        "Insert", "0x448e3a",
        "Control", "0xFF0000",
        "Goto", "0x0000FF",
        "Window", "0x00FF00",
        "Mouse", "0xFFFF00",
        "Visual", "0xFF00FF"
    )
    if (Mode == "Insert") {
        ModeBar.Hide()
    } else {
        ModeBar.Show("NoActivate")
    }
    ModeBar.BackColor := ModeColors[Mode]
    InfoBar.BackColor := ModeColors[Mode]

}

EnableKeyMap(Map) {
    for Index, Row in Map {
        Hotkey(Row[1], Row[2], "On")
    }
}

DisableKeyMap(Map) {
    for Index, Row in Map {
        Hotkey(Row[1], Row[2], "Off")
    }
}

ExpandSelection(Hotkey) {
    Send("+!{Right}")
}

ShrinkSelection(Hotkey) {
    Send("+!{Left}")
}

SwitchToMode(NewMode) {
    global Mode, LastMode
    DisableKeyMap(Keymaps[Mode])
    EnableKeyMap(Keymaps[NewMode])
    LastMode := Mode
    Mode := NewMode
    UpdateModeBar()
}

SwitchToModeInsert(Hotkey) {
    if (A_IsAdmin) {
        EnableWinL("")
    }
    SwitchToMode("Insert")
}

SwitchToModeControl(Hotkey) {
    if (A_IsAdmin) {
        DisableWinL("")
    }
    SwitchToMode("Control")
}

SwitchToModeGoto(Hotkey) {
    SwitchToMode("Goto")
}

SwitchToModeWindow(Hotkey) {
    SwitchToMode("Window")
}

SwitchToModeMouse(Hotkey) {
    SwitchToMode("Mouse")
}

SwitchToModeVisual(Hotkey) {
    SwitchToMode("Visual")
}

SwitchToModeLast(Hotkey) {
    global LastMode
    SwitchToMode(LastMode)
}
