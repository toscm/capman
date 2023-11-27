#include lib.ahk

ResizeWindow(Hotkey) {
    ; https://superuser.com/questions/18215/is-there-a-way-to-resize-a-window-to-specific-sizes-eg-800x600-1024x768
    window := WinExist("A")
    width := InputBox("Width", "", "W140 H130")
    height := InputBox("Height", "", "W140 H130")
    WinMove("ahk_id " window, "", "", "", width, height)
    return
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
