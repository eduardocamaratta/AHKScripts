﻿; An AutoHotKey Script that maps the infamous 112h key of the ABNT2 keyboard layout to the Right Shift

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
return