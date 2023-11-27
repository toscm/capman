#include lib.ahk

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
    Run("notepad.exe /A keymap.ahk")
}