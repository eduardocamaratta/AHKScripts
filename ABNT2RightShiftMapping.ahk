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

Rshift::/
Lshift & Rshift::Send {?}
RAlt & Rshift::Send {°}
RAlt & E::Send {€}

; Override default maximize shortcut, resizing the window with a height one pixel shorter,
; otherwise the taskbar is not always shown (when it's configured to automatically hide).
#Up::WinMove, A,, 0, 0, A_ScreenWidth, A_ScreenHeight - 1

return