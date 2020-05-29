; An AutoHotKey Script that maps the Slash/Interrogation/Degree key of the ABNT2 keyboard layout to the Right Shift

; To make the script start with Windows:
; Win + R
; %appdata%\Microsoft\Windows\Start Menu\Programs\Startup
; Create a shortcut to the script
; Done! :)

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force ; Always overwrite this script if it's already running.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Previous version was sending / instead, but some apps simply don't work with it (but they work well with NumpadDiv)
Rshift::NumpadDiv
Lshift & Rshift::Send {?}
RAlt & Rshift::Send {°}
RAlt & E::Send {€}

; Although it works, the window keeps the size of the original monitor, not adapting to the new monitor's size
^#Right::
^#Left::
Send #+{Right}
return

; TODO: It works relatively well, but try to execute this only to the exceptions, and maximize the other apps normally
; Override default maximize shortcut, resizing the window with a height one pixel shorter than the current monitor,
; otherwise the taskbar is not always shown (when it's configured to automatically hide itself).
#Up::
SysGet, monitors, MonitorCount
specs := GetMonitorsSpecs(monitors)
monitor := GetActiveWindowMonitorIndex(monitors, specs)
current := specs[monitor]
WinMove, A,, current.left, current.top, current.width, current.height - 1
return

; Resize the window to fill the top half of the current monitor
^#Up::
SysGet, monitors, MonitorCount
specs := GetMonitorsSpecs(monitors)
monitor := GetActiveWindowMonitorIndex(monitors, specs)
current := specs[monitor]
WinMove, A,, current.left, current.top, current.width, Round(current.height / 2)
return

; Resize the window to fill the bottom half of the current monitor
^#Down::
SysGet, monitors, MonitorCount
specs := GetMonitorsSpecs(monitors)
monitor := GetActiveWindowMonitorIndex(monitors, specs)
current := specs[monitor]
WinMove, A,, current.left, Round(current.top + current.height / 2), current.width, Round(current.height / 2)
return

; TODO: it's not fully working, the proportions are not always kept
; Move to the window to the next monitor, keeping its proportions
; Original Windows 10 shortcut to move without keeping proportions is +#Right (Shift + Windows + Right)
; ^#Right::
; ^#Left::
; SysGet, monitors, MonitorCount
; specs := GetMonitorsSpecs(monitors)
; monitor := GetActiveWindowMonitorIndex(monitors, specs)
; next := GetNextMonitorForActiveWindow(monitors, monitor)
; WinGetPos, left, top, width, height, A
; current := specs[monitor]
; next := specs[next]
; newLeft := Round((((left - current.left) / current.width) * next.width) + next.left)
; newTop := Round((((top - current.top) / current.height) * next.height) + next.top)
; newWidth := Round((width / current.width) * next.width)
; newHeight := Round((height / current.height) * next.height)
; WinMove, A,, newLeft, newTop, newWidth, newHeight
; return

; Return an array of objects containing coordinates for the desired number of monitors
GetMonitorsSpecs(monitors) {
    monitorsSpecs := []
    Loop, %monitors%
    {
        SysGet, coords, Monitor, %A_Index%
        specs := {"left": coordsLeft, "right": coordsRight, "top": coordsTop, "bottom": coordsBottom, "width": coordsRight - coordsLeft, "height": coordsBottom - coordsTop}
        monitorsSpecs.Push(specs)
    }
    return monitorsSpecs
}

; Return the index of the monitor where the active window is located
GetActiveWindowMonitorIndex(monitors, monitorsSpecs) {
    window := WinExist("A")
    VarSetCapacity(monitorInfo, 40), NumPut(40, monitorInfo)
    monitorHandle := DllCall("MonitorFromWindow", "Ptr", window, "UInt", 0x2)
    DllCall("GetMonitorInfo", "Ptr", monitorHandle, "Ptr", &monitorInfo)
    left := NumGet(monitorInfo, 20, "Int")
    index := 0
    Loop %monitors%
    {
        specs := monitorsSpecs[A_Index]
        if (left = specs.left)
            index := A_Index
    }
    return index
}

; Based on the number of monitors and the index of the current monitor, return the index for the next monitor
GetNextMonitorForActiveWindow(monitors, current) {
    next := Mod(current + 1, monitors + 1)
    next := next = 0 ? 1 : next
    return next
}
