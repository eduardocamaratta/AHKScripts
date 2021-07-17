; An AutoHotKey Script that maps the Slash/Interrogation/Degree key of the ABNT2 keyboard layout to the Right Shift
; It also introduces shortcuts to manage windows in multi monitor environments

; To make the script start with Windows:
; Win + R
; %appdata%\Microsoft\Windows\Start Menu\Programs\Startup
; Create a shortcut to the script
; Done! :)


; ****************************************************************************************************
; ** Script setup **
; ****************************************************************************************************

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force ; Always overwrite this script if it's already running.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; ****************************************************************************************************
; ** Shortcuts **
; ****************************************************************************************************

; Previous version was sending / instead, but some apps simply don't work with it (but they work well with NumpadDiv)
Rshift::NumpadDiv
Lshift & Rshift::Send {?}
RAlt & Rshift::Send {°}
RAlt & E::Send {€}

; Deutsch
!A::Send {ä} ; ae, a + Umlaut
!O::Send {ö} ; oe, o + Umlaut
!U::Send {ü} ; ue, u + Umlaut
!S::Send {ß} ; Eszett
+!A::Send {Ä} ; AE, A + Umlaut
+!O::Send {Ö} ; OE, O + Umlaut
+!U::Send {Ü} ; UE, U + Umlaut
+!S::Send {ẞ} ; Große Eszett

; Default windows shortcut to maximize. However, it resizes to height - 1 for some windows instead of maximizing,
; to avoid hiding the Taskbar
#Up::
WinGetTitle, title, A
if (title in Telegram,Steam,Geforce Experience,Epic Games Launcher) or InStr(title, "GOG Galaxy")
{
    specs := GetCurrentMonitorSpecs()
    WinMove, A,, specs.left, specs.top, specs.width, specs.height - 1
}
else
{
    WinMaximize, A
}
return

; Resize the window to fill the top half of the current monitor
^#Up::
specs := GetCurrentMonitorSpecs()
RestoreIfMaximized()
WinMove, A,, specs.left, specs.top, specs.width, Round(specs.height / 2)
return

; Resize the window to fill the bottom half of the current monitor
^#Down::
specs := GetCurrentMonitorSpecs()
RestoreIfMaximized()
WinMove, A,, specs.left, Round(specs.top + specs.height / 2), specs.width, Round(specs.height / 2)
return

; Move to the window to the next monitor, keeping its proportions
; Original Windows 10 shortcut to move without keeping proportions is +#Right (Shift + Windows + Right)
^#Right::
^#Left::
SysGet, monitors, MonitorCount
specs := GetMonitorsSpecs(monitors)
monitor := GetActiveWindowMonitorIndex(monitors, specs)
next := GetNextMonitorForActiveWindow(monitors, monitor)
WinGetPos, left, top, width, height, A
current := specs[monitor]
next := specs[next]
newLeft := Round((((left - current.left) / current.width) * next.width) + next.left)
newTop := Round((((top - current.top) / current.height) * next.height) + next.top)
newWidth := Round((width / current.width) * next.width)
newHeight := Round((height / current.height) * next.height)
WinMove, A,, newLeft, newTop, newWidth, newHeight
; Although it would be nice to move the window only once... Windows doesn't know how to ´properly
; move between monitors when the scaling is different between them. The window dimensions are scaled
; before moving, but this is not desired. However, when the screen was already moved to another
; monitor, the scaling is working as intended again. So this is why we have a second WinMove, to adjust
; the size that was messed by Windows
WinMove, A,, newLeft, newTop, newWidth, newHeight
return


; ****************************************************************************************************
; ** Helper functions **
; ****************************************************************************************************

; If the active window is maximized, restore it
RestoreIfMaximized() {
    WinGet, maximized, MinMax, A
    if maximized = 1
    {
        WinRestore, A
    }
}

; Returns the specs of the monitor where the active window is located
GetCurrentMonitorSpecs() {
    SysGet, monitors, MonitorCount
    specs := GetMonitorsSpecs(monitors)
    monitor := GetActiveWindowMonitorIndex(monitors, specs)
    current := specs[monitor]
    return current
}

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
