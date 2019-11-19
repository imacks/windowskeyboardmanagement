Windows Keyboard Management
===========================
This PowerShell module allows the physical keyboard to be remapped. Works on Windows only.

Inspired by [randyrants/sharpkeys](https://github.com/randyrants/sharpkeys) and [stackexchange](https://superuser.com/questions/400864/make-media-button-on-keyboard-open-winamp-instead-of-wmp).


Example
-------
I use a classic Cherry keyboard. It's nice but there is no multimedia keys (e.g. calculator, mute, etc.). I don't really mind that, but find myself wishing there is a dedicated key for launching PowerShell.

```powershell
PS C:\> ipmo WindowsKeyboardManagement
PS C:\> Get-WindowsKeyboardMap -Available
# returns a whole lot of keys that can be used...

PS C:\> Set-WindowsKeyboardMap -Online -KeyName 'Scroll Lock' -MapTo 'My Computer'

KeyName     MapTo
-------     -----
Scroll Lock My Computer

PS C:\> Get-WindowsKeyboardMap -Online

KeyName     MapTo
-------     -----
Scroll Lock My Computer

PS C:\> Get-WindowsMediaKey -Online | fl

KeyCode     : 15
Description : Mail

KeyCode     : 16
Description : Media Select

KeyCode      : 17
Description  : App1/Computer

KeyCode     : 18
Description : App2/Calculator

KeyCode     : 7
Description : Home

PS C:\> Set-WindowsMediaKey -Online -KeyCode 17 -ShellExecute 'powershell.exe'
PS C:\> Get-WindowsMediaKey -Online | where { $_.KeyCode -eq 17 } | fl

KeyCode      : 17
Description  : App1/Computer
ShellExecute : powershell.exe

PS C:\> logoff
# Changing media keys is immediate, but keyboard mappings requires you to login again

```

Now pressing "Scroll Lock" will immediately launch PowerShell. Yeah!


Installation
------------
You can install right off Powershell Gallery:

```powershell
PS C:\> Install-Package WindowsKeyboardManagement
```

To install manually, download the [latest release](./releases), unzip and copy `src/WindowsKeyboardManagement` to `%USERPROFILE%\Documents\WindowsPowerShell\Modules`.
