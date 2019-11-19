function Get-WindowsKeyboardMap
{
    <#
        .SYNOPSIS
            Shows all effective Windows keyboard mappings, or returns a list of available key mappings.

        .DESCRIPTION
            Windows allows you to redefine keys on your keyboard. This is done by changing the virtual key code associated with a keyboard key.

            Features:
            (1) map one key to another (e.g. caps lock -> shift)
            (2) map multiple keys to one key (e.g. caps lock OR F12 -> F1)
            (3) swap 2 keys (e.g. a -> b && b -> a)

            Limitations: 
            (1) you cannot map a keystroke sequence (e.g. alt-tab) to a single key
            (2) some proprietary keyboard buttons may not work (e.g. Logitech)
            (3) you cannot map mouse buttons to the keyboard

            Administrative privileges are required to modify keyboard mappings. Changes affect all users.

        .PARAMETER Online
            Read configuration from the Windows registry path 'HKEY_LOCAL_MACHINE\\System\CurrentControlSet\Control\Keyboard Layout'. The property 'Scancode Map' will be parsed.

        .PARAMETER Available
            Lists the keys that are supported. No escalated privileges are required to execute with this flag. Windows will not be modified.

        .PARAMETER SystemHiveMountPath
            Registry mount point to "HKEY_LOCAL_MACHINE\System". You should mount the registry hive file "%SystemRoot%\System32\Config\System" to your online registry.
    #>

    [CmdletBinding(DefaultParameterSetName = 'OnlineSet')]
    Param(
        [Parameter(Mandatory, ParameterSetName = 'OnlineSet')]
        [switch]$Online,

        [Parameter(Mandatory, ParameterSetName = 'OfflineServiceSet')]
        [string]$SystemHiveMountPath,

        [Parameter(Mandatory, ParameterSetName = 'GetAvailableSet')]
        [switch]$Available
    )

    #
    # Inspired by <randy/sharpkeys>
    # - https://github.com/randyrants/sharpkeys
    #

    $keyDataJson = @'
[{"code":"00_01","desc":"Escape","category":"Special"},{"code":"00_02","desc":"1 !","category":"Key"},{"code":"00_03","desc":"2 @","category":"Key"},{"code":"00_04","desc":"3 #","category":"Key"},{"code":"00_05","desc":"4 $","category":"Key"},{"code":"00_06","desc":"5 %","category":"Key"},{"code":"00_07","desc":"6 ^","category":"Key"},{"code":"00_08","desc":"7 \u0026","category":"Key"},{"code":"00_09","desc":"8 *","category":"Key"},{"code":"00_0A","desc":"9 (","category":"Key"},{"code":"00_0B","desc":"0 )","category":"Key"},{"code":"00_0C","desc":"- _","category":"Key"},{"code":"00_0D","desc":"= +","category":"Key"},{"code":"00_0E","desc":"Backspace","category":"Special"},{"code":"00_0F","desc":"Tab","category":"Special"},{"code":"00_10","desc":"Q","category":"Key"},{"code":"00_11","desc":"W","category":"Key"},{"code":"00_12","desc":"E","category":"Key"},{"code":"00_13","desc":"R","category":"Key"},{"code":"00_14","desc":"T","category":"Key"},{"code":"00_15","desc":"Y","category":"Key"},{"code":"00_16","desc":"U","category":"Key"},{"code":"00_17","desc":"I","category":"Key"},{"code":"00_18","desc":"O","category":"Key"},{"code":"00_19","desc":"P","category":"Key"},{"code":"00_1A","desc":"[ {","category":"Key"},{"code":"00_1B","desc":"] }","category":"Key"},{"code":"00_1C","desc":"Enter","category":"Special"},{"code":"00_1D","desc":"Left Ctrl","category":"Special"},{"code":"00_1E","desc":"A","category":"Key"},{"code":"00_1F","desc":"S","category":"Key"},{"code":"00_20","desc":"D","category":"Key"},{"code":"00_21","desc":"F","category":"Key"},{"code":"00_22","desc":"G","category":"Key"},{"code":"00_23","desc":"H","category":"Key"},{"code":"00_24","desc":"J","category":"Key"},{"code":"00_25","desc":"K","category":"Key"},{"code":"00_26","desc":"L","category":"Key"},{"code":"00_27","desc":"; :","category":"Key"},{"code":"00_28","desc":"\u0027 \\","category":"Key"},{"code":"00_29","desc":"` ~","category":"Key"},{"code":"00_2A","desc":"Left Shift","category":"Special"},{"code":"00_2B","desc":"\\\\ |","category":"Key"},{"code":"00_2C","desc":"Z","category":"Key"},{"code":"00_2D","desc":"X","category":"Key"},{"code":"00_2E","desc":"C","category":"Key"},{"code":"00_2F","desc":"V","category":"Key"},{"code":"00_30","desc":"B","category":"Key"},{"code":"00_31","desc":"N","category":"Key"},{"code":"00_32","desc":"M","category":"Key"},{"code":"00_33","desc":", \u003c","category":"Key"},{"code":"00_34","desc":". \u003e","category":"Key"},{"code":"00_35","desc":"/ ?","category":"Key"},{"code":"00_36","desc":"Right Shift","category":"Special"},{"code":"00_37","desc":"*","category":"Num"},{"code":"00_38","desc":"Left Alt","category":"Special"},{"code":"00_39","desc":"Space","category":"Special"},{"code":"00_3A","desc":"Caps Lock","category":"Special"},{"code":"00_3B","desc":"F1","category":"Function"},{"code":"00_3C","desc":"F2","category":"Function"},{"code":"00_3D","desc":"F3","category":"Function"},{"code":"00_3E","desc":"F4","category":"Function"},{"code":"00_3F","desc":"F5","category":"Function"},{"code":"00_40","desc":"F6","category":"Function"},{"code":"00_41","desc":"F7","category":"Function"},{"code":"00_42","desc":"F8","category":"Function"},{"code":"00_43","desc":"F9","category":"Function"},{"code":"00_44","desc":"F10","category":"Function"},{"code":"00_45","desc":"Num Lock","category":"Special"},{"code":"00_46","desc":"Scroll Lock","category":"Special"},{"code":"00_47","desc":"7","category":"Num"},{"code":"00_48","desc":"8","category":"Num"},{"code":"00_49","desc":"9","category":"Num"},{"code":"00_4A","desc":"-","category":"Num"},{"code":"00_4B","desc":"4","category":"Num"},{"code":"00_4C","desc":"5","category":"Num"},{"code":"00_4D","desc":"6","category":"Num"},{"code":"00_4E","desc":"+","category":"Num"},{"code":"00_4F","desc":"1","category":"Num"},{"code":"00_50","desc":"2","category":"Num"},{"code":"00_51","desc":"3","category":"Num"},{"code":"00_52","desc":"0","category":"Num"},{"code":"00_53","desc":".","category":"Num"},{"code":"00_54","desc":"0x0054","category":"Unknown"},{"code":"00_55","desc":"0x0055","category":"Unknown"},{"code":"00_56","desc":"ISO extra key","category":"Special"},{"code":"00_57","desc":"F11","category":"Function"},{"code":"00_58","desc":"F12","category":"Function"},{"code":"00_59","desc":"0x0059","category":"Unknown"},{"code":"00_5A","desc":"0x005A","category":"Unknown"},{"code":"00_5B","desc":"0x005B","category":"Unknown"},{"code":"00_5C","desc":"0x005C","category":"Unknown"},{"code":"00_5D","desc":"0x005D","category":"Unknown"},{"code":"00_5E","desc":"0x005E","category":"Unknown"},{"code":"00_5F","desc":"0x005F","category":"Unknown"},{"code":"00_60","desc":"0x0060","category":"Unknown"},{"code":"00_61","desc":"0x0061","category":"Unknown"},{"code":"00_62","desc":"0x0062","category":"Unknown"},{"code":"00_63","desc":"0x0063","category":"Unknown"},{"code":"00_64","desc":"F13","category":"Function"},{"code":"00_65","desc":"F14","category":"Function"},{"code":"00_66","desc":"F15","category":"Function"},{"code":"00_67","desc":"F16","category":"Function"},{"code":"00_68","desc":"F17","category":"Function"},{"code":"00_69","desc":"F18","category":"Function"},{"code":"00_6A","desc":"F19","category":"Function"},{"code":"00_6B","desc":"F20","category":"Function"},{"code":"00_6C","desc":"F21","category":"Function"},{"code":"00_6D","desc":"F22","category":"Function"},{"code":"00_6E","desc":"F23","category":"Function"},{"code":"00_6F","desc":"F24","category":"Function"},{"code":"00_70","desc":"0x0070","category":"Unknown"},{"code":"00_71","desc":"0x0071","category":"Unknown"},{"code":"00_72","desc":"0x0072","category":"Unknown"},{"code":"00_73","desc":"0x0073","category":"Unknown"},{"code":"00_74","desc":"0x0074","category":"Unknown"},{"code":"00_75","desc":"0x0075","category":"Unknown"},{"code":"00_76","desc":"0x0076","category":"Unknown"},{"code":"00_77","desc":"0x0077","category":"Unknown"},{"code":"00_78","desc":"0x0078","category":"Unknown"},{"code":"00_79","desc":"0x0079","category":"Unknown"},{"code":"00_7A","desc":"0x007A","category":"Unknown"},{"code":"00_7B","desc":"0x007B","category":"Unknown"},{"code":"00_7C","desc":"0x007C","category":"Unknown"},{"code":"00_7D","desc":"¥ -","category":"Special"},{"code":"00_7E","desc":"0x007E","category":"Unknown"},{"code":"00_7F","desc":"0x007F","category":"Unknown"},{"code":"E0_01","desc":"0xE001","category":"Unknown"},{"code":"E0_02","desc":"0xE002","category":"Unknown"},{"code":"E0_03","desc":"0xE003","category":"Unknown"},{"code":"E0_04","desc":"0xE004","category":"Unknown"},{"code":"E0_05","desc":"0xE005","category":"Unknown"},{"code":"E0_06","desc":"0xE006","category":"Unknown"},{"code":"E0_07","desc":"Redo","category":"F-Lock"},{"code":"E0_08","desc":"Undo","category":"F-Lock"},{"code":"E0_09","desc":"0xE009","category":"Unknown"},{"code":"E0_0A","desc":"0xE00A","category":"Unknown"},{"code":"E0_0B","desc":"0xE00B","category":"Unknown"},{"code":"E0_0C","desc":"0xE00C","category":"Unknown"},{"code":"E0_0D","desc":"0xE00D","category":"Unknown"},{"code":"E0_0E","desc":"0xE00E","category":"Unknown"},{"code":"E0_0F","desc":"0xE00F","category":"Unknown"},{"code":"E0_10","desc":"Prev Track","category":"Media"},{"code":"E0_11","desc":"Messenger","category":"App"},{"code":"E0_12","desc":"Webcam","category":"Logitech"},{"code":"E0_13","desc":"iTouch","category":"Logitech"},{"code":"E0_14","desc":"Shopping","category":"Logitech"},{"code":"E0_15","desc":"0xE015","category":"Unknown"},{"code":"E0_16","desc":"0xE016","category":"Unknown"},{"code":"E0_17","desc":"0xE017","category":"Unknown"},{"code":"E0_18","desc":"0xE018","category":"Unknown"},{"code":"E0_19","desc":"Next Track","category":"Media"},{"code":"E0_1A","desc":"0xE01A","category":"Unknown"},{"code":"E0_1B","desc":"0xE01B","category":"Unknown"},{"code":"E0_1C","desc":"Enter","category":"Num"},{"code":"E0_1D","desc":"Right Ctrl","category":"Special"},{"code":"E0_1E","desc":"0xE01E","category":"Unknown"},{"code":"E0_1F","desc":"0xE01F","category":"Unknown"},{"code":"E0_20","desc":"Mute","category":"Media"},{"code":"E0_21","desc":"Calculator","category":"App"},{"code":"E0_22","desc":"Play/Pause","category":"Media"},{"code":"E0_23","desc":"Spell","category":"F-Lock"},{"code":"E0_24","desc":"Stop","category":"Media"},{"code":"E0_25","desc":"0xE025","category":"Unknown"},{"code":"E0_26","desc":"0xE026","category":"Unknown"},{"code":"E0_27","desc":"0xE027","category":"Unknown"},{"code":"E0_28","desc":"0xE028","category":"Unknown"},{"code":"E0_29","desc":"0xE029","category":"Unknown"},{"code":"E0_2B","desc":"0xE02B","category":"Unknown"},{"code":"E0_2C","desc":"0xE02C","category":"Unknown"},{"code":"E0_2D","desc":"0xE02D","category":"Unknown"},{"code":"E0_2E","desc":"Volume Down","category":"Media"},{"code":"E0_2F","desc":"0xE02F","category":"Unknown"},{"code":"E0_30","desc":"Volume Up","category":"Media"},{"code":"E0_31","desc":"0xE031","category":"Unknown"},{"code":"E0_32","desc":"Home","category":"Web"},{"code":"E0_33","desc":"0xE033","category":"Unknown"},{"code":"E0_34","desc":"0xE034","category":"Unknown"},{"code":"E0_35","desc":"/","category":"Num"},{"code":"E0_36","desc":"0xE036","category":"Unknown"},{"code":"E0_37","desc":"PrtSc","category":"Special"},{"code":"E0_38","desc":"Right Alt","category":"Special"},{"code":"E0_2038","desc":"Alt Gr","category":"Special"},{"code":"E0_39","desc":"0xE039","category":"Unknown"},{"code":"E0_3A","desc":"0xE03A","category":"Unknown"},{"code":"E0_3B","desc":"Help","category":"F-Lock"},{"code":"E0_3C","desc":"Office Home","category":"F-Lock"},{"code":"E0_3D","desc":"Task Pane","category":"F-Lock"},{"code":"E0_3E","desc":"New","category":"F-Lock"},{"code":"E0_3F","desc":"Open","category":"F-Lock"},{"code":"E0_40","desc":"Close","category":"F-Lock"},{"code":"E0_41","desc":"Reply","category":"F-Lock"},{"code":"E0_42","desc":"Fwd","category":"F-Lock"},{"code":"E0_43","desc":"Send","category":"F-Lock"},{"code":"E0_44","desc":"0xE044","category":"Unknown"},{"code":"E0_45","desc":"€","category":"Special"},{"code":"E0_46","desc":"Break","category":"Special"},{"code":"E0_47","desc":"Home","category":"Special"},{"code":"E0_48","desc":"Up","category":"Arrow"},{"code":"E0_49","desc":"Page Up","category":"Special"},{"code":"E0_4A","desc":"0xE04A","category":"Unknown"},{"code":"E0_4B","desc":"Left","category":"Arrow"},{"code":"E0_4C","desc":"0xE04C","category":"Unknown"},{"code":"E0_4D","desc":"Right","category":"Arrow"},{"code":"E0_4E","desc":"0xE04E","category":"Unknown"},{"code":"E0_4F","desc":"End","category":"Special"},{"code":"E0_50","desc":"Down","category":"Arrow"},{"code":"E0_51","desc":"Page Down","category":"Special"},{"code":"E0_52","desc":"Insert","category":"Special"},{"code":"E0_53","desc":"Delete","category":"Special"},{"code":"E0_54","desc":"0xE054","category":"Unknown"},{"code":"E0_55","desc":"0xE055","category":"Unknown"},{"code":"E0_56","desc":"\u003c \u003e |","category":"Special"},{"code":"E0_57","desc":"Save","category":"F-Lock"},{"code":"E0_58","desc":"Print","category":"F-Lock"},{"code":"E0_59","desc":"0xE059","category":"Unknown"},{"code":"E0_5A","desc":"0xE05A","category":"Unknown"},{"code":"E0_5B","desc":"Left Windows","category":"Special"},{"code":"E0_5C","desc":"Right Windows","category":"Special"},{"code":"E0_5D","desc":"Application","category":"Special"},{"code":"E0_5E","desc":"Power","category":"Special"},{"code":"E0_5F","desc":"Sleep","category":"Special"},{"code":"E0_60","desc":"0xE060","category":"Unknown"},{"code":"E0_61","desc":"0xE061","category":"Unknown"},{"code":"E0_62","desc":"0xE062","category":"Unknown"},{"code":"E0_63","desc":"Wake (or Fn)","category":"Special"},{"code":"E0_64","desc":"0xE064","category":"Unknown"},{"code":"E0_65","desc":"Search","category":"Web"},{"code":"E0_66","desc":"Favorites","category":"Web"},{"code":"E0_67","desc":"Refresh","category":"Web"},{"code":"E0_68","desc":"Stop","category":"Web"},{"code":"E0_69","desc":"Forward","category":"Web"},{"code":"E0_6A","desc":"Back","category":"Web"},{"code":"E0_6B","desc":"My Computer","category":"App"},{"code":"E0_6C","desc":"E-Mail","category":"App"},{"code":"E0_6D","desc":"Media Select","category":"App"},{"code":"E0_6E","desc":"0xE06E","category":"Unknown"},{"code":"E0_6F","desc":"0xE06F","category":"Unknown"},{"code":"E0_70","desc":"0xE070","category":"Unknown"},{"code":"E0_71","desc":"0xE071","category":"Unknown"},{"code":"E0_72","desc":"0xE072","category":"Unknown"},{"code":"E0_73","desc":"0xE073","category":"Unknown"},{"code":"E0_74","desc":"0xE074","category":"Unknown"},{"code":"E0_75","desc":"0xE075","category":"Unknown"},{"code":"E0_76","desc":"0xE076","category":"Unknown"},{"code":"E0_77","desc":"0xE077","category":"Unknown"},{"code":"E0_78","desc":"0xE078","category":"Unknown"},{"code":"E0_79","desc":"0xE079","category":"Unknown"},{"code":"E0_7A","desc":"0xE07A","category":"Unknown"},{"code":"E0_7B","desc":"0xE07B","category":"Unknown"},{"code":"E0_7C","desc":"0xE07C","category":"Unknown"},{"code":"E0_7D","desc":"0xE07D","category":"Unknown"},{"code":"E0_7E","desc":"0xE07E","category":"Unknown"},{"code":"E0_7F","desc":"0xE07F","category":"Unknown"},{"code":"E0_F1","desc":"Hanja Key","category":"Special"},{"code":"E0_F2","desc":"Hangul Key","category":"Special"}]
'@

    $keyData = ConvertFrom-Json $keyDataJson

    if ($PSCmdlet.ParameterSetName -eq 'GetAvailableSet')
    {
        foreach ($keyItem in $keyData)
        {
            [pscustomobject]@{
                Code = $keyItem.code
                Description = $keyItem.desc
                Category = $keyItem.category
            }
        }
    }
    elseif (($PSCmdlet.ParameterSetName -eq 'OnlineSet') -or ($PSCmdlet.ParameterSetName -eq 'OfflineServiceSet'))
    {
        if ($PSCmdlet.ParameterSetName -eq 'OfflineServiceSet')
        {
            $regKeyPath = Join-Path $SystemHiveMountPath -ChildPath 'CurrentControlSet\Control\Keyboard Layout'
        }
        else
        {
            $regKeyPath = 'HKLM:\System\CurrentControlSet\Control\Keyboard Layout'
        }

        $regValueName = 'Scancode Map'

        if (-not (Test-Path $regKeyPath))
        {
            return $null
        }

        $regKey = Get-Item $regKeyPath
        if ($regKey.GetValueNames() -notcontains $regValueName)
        {
            return $null
        }

        if ($regKey.GetValueKind($regValueName) -ne 'Binary')
        {
            throw ('The Windows registry key "{0}" is expected to have a Binary type property named "{1}", but found the existing type to be {2}.' -f $regKeyPath, $regValueName, $regKey.GetValueKind($regValueName))
        }

        $keyMapData = [byte[]]($regKey.GetValue($regValueName))
        $regKey.Close()
        $regKey.Dispose()

        if ($keyMapData.Length -le 8)
        {
            return $null
        }

        for ($i = 0; $i -lt [int]::Parse($keyMapData[8].ToString()) - 1; $i++)
        {
            $strFromCode = [string]::Format("{0,2:X}_{1,2:X}", $keyMapData[($i * 4) + 12 + 3], $keyMapData[($i * 4) + 12 + 2])
            $strFromCode = $strFromCode.Replace(" ", "0")
            $strFromDesc = $keyData | where { $_.code -eq $strFromCode } | select -expand desc

            $strToCode = [string]::Format("{0,2:X}_{1,2:X}", $keyMapData[($i * 4) + 12 + 1], $keyMapData[($i * 4) + 12 + 0])
            $strToCode = $strToCode.Replace(" ", "0")
            $strToDesc = $keyData | where { $_.code -eq $strToCode } | select -expand desc

            [pscustomobject]@{
                'KeyName' = $strFromDesc
                'MapTo' = $strToDesc
            }
        }
    }
    else
    {
        throw 'Internal error: uncaught parameter set.'
    }
}

function Set-WindowsKeyboardMap
{
    <#
        .SYNOPSIS
            Modifies the virtual key code generated when a key is pressed on the keyboard. This feature only works on Windows.

        .DESCRIPTION
            You can use this command to define all key mappings, add a key mapping, or modify an existing one.

            Type "Get-Help Get-WindowsKeyboardMap" for more details on Windows key mapping and available virtual key codes.

            Use "Remove-WindowsKeyboardMap" or "Clear-WindowsKeyboardMap" to remove key mappings.

            This command requires administrative privileges and affects all users on the Windows installation.

        .PARAMETER KeyName
            The key to modify. Use "Get-WindowsKeyboardMap -Available" for a list of available key codes.

        .PARAMETER MapTo
            The key that should be mapped to. Use "Get-WindowsKeyboardMap -Available" for a list of available key codes.

        .PARAMETER KeyMap
            A hashtable of key name to mapped names. Use this parameter to define all key mappings.

        .PARAMETER Online
            Writes changes to 'HKEY_LOCAL_MACHINE\\System\CurrentControlSet\Control\Keyboard Layout'. The property 'Scancode Map' will be created, modified or removed.

        .PARAMETER SystemHiveMountPath
            Registry mount point to "HKEY_LOCAL_MACHINE\System". You should mount the registry hive file "%SystemRoot%\System32\Config\System" to your online registry.
    #>

    [CmdletBinding(DefaultParameterSetName = 'KvpOnlineSet')]
    Param(
        [Parameter(Mandatory, ParameterSetName = 'KvpOnlineSet')]
        [Parameter(Mandatory, ParameterSetName = 'KvpOfflineServiceSet')]
        [string]$KeyName,

        [Parameter(Mandatory, ParameterSetName = 'KvpOnlineSet')]
        [Parameter(Mandatory, ParameterSetName = 'KvpOfflineServiceSet')]
        [string]$MapTo,

        [Parameter(Mandatory, ParameterSetName = 'MapOnlineSet')]
        [Parameter(Mandatory, ParameterSetName = 'MapOfflineServiceSet')]
        [hashtable]$KeyMap,

        [Parameter(Mandatory, ParameterSetName = 'KvpOnlineSet')]
        [Parameter(Mandatory, ParameterSetName = 'MapOnlineSet')]
        [switch]$Online,

        [Parameter(Mandatory, ParameterSetName = 'KvpOfflineServiceSet')]
        [Parameter(Mandatory, ParameterSetName = 'MapOfflineServiceSet')]
        [string]$SystemHiveMountPath
    )

    if (-not (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
    {
        throw 'This command requires administrative privileges.'
    }

    $regKeyPath = 'HKLM:\System\CurrentControlSet\Control\Keyboard Layout'

    if ($PSCmdlet.ParameterSetName -like '*OfflineServiceSet')
    {
        $regKeyPath = Join-Path $SystemHiveMountPath -ChildPath 'CurrentControlSet\Control\Keyboard Layout'
    }

    $regValueName = 'Scancode Map'

    $keyData = Get-WindowsKeyboardMap -Available
    $effectiveMap = @{}

    if ($PSCmdlet.ParameterSetName -like 'Map*')
    {
        foreach ($mapFromDesc in $KeyMap.Keys)
        {
            $mapToDesc = $KeyMap[$mapFromDesc]

            if (($mapFromDesc -isnot [string]) -or ($mapToDesc -isnot [string]))
            {
                throw ('The parameter KeyMap must be a hashtable of strings.')
            }

            $mapFromInfo = $keyData | where { $_.Description -eq $mapFromDesc }
            if (-not $mapFromInfo)
            {
                throw ('Unsupported source key "{0}". Use "Get-WindowsKeyboardMap -Available" to get a list of supported keys.' -f $mapFromDesc)
            }
            elseif ($mapFromInfo.Count -gt 1)
            {
                throw ('Internal error: ambiguous key description "{0}"' -f $mapFromDesc)
            }

            $mapToInfo = $keyData | where { $_.Description -eq $mapToDesc }
            if (-not $mapToInfo)
            {
                throw ('Unsupported target key "{0}". Use "Get-WindowsKeyboardMap -Available" to get a list of supported keys.' -f $mapToDesc)
            }
            elseif ($mapToInfo.Count -gt 1)
            {
                throw ('Internal error: ambiguous key description "{0}"' -f $mapToDesc)
            }

            $effectiveMap[$mapFromInfo.Code] = $mapToInfo.Code
        }   
    }
    elseif ($PSCmdlet.ParameterSetName -like 'Kvp*')
    {
        if ($PSCmdlet.ParameterSetName -like '*OnlineSet')
        {
            $currentMap = Get-WindowsKeyboardMap -Online
        }
        elseif ($PSCmdlet.ParameterSetName -like '*OfflineServiceSet')
        {
            $currentMap = Get-WindowsKeyboardMap -SystemHiveMountPath $SystemHiveMountPath
        }
        else
        {
            throw 'Internal error: uncaught parameter set.'
        }

        if ($currentMap)
        {
            foreach ($mapItem in $currentMap)
            {
                if (-not $mapItem.KeyName)
                {
                    continue
                }

                $mapFromInfo = $keyData | where { $_.Description -eq $mapItem.KeyName }
                if (-not $mapFromInfo)
                {
                    throw ('Registry data corruption. Clear the current key mapping using "Clear-WindowsKeyboardMap" and try again.' -f $mapItem.KeyName)
                }
                elseif ($mapFromInfo.Count -gt 1)
                {
                    throw ('Internal error: ambiguous key description "{0}"' -f $mapItem.KeyName)
                }

                $mapToInfo = $keyData | where { $_.Description -eq $mapItem.MapTo }
                if (-not $mapToInfo)
                {
                    throw ('Registry data corruption. Clear the current key mapping using "Clear-WindowsKeyboardMap" and try again.' -f $mapItem.MapTo)
                }
                elseif ($mapToInfo.Count -gt 1)
                {
                    throw ('Internal error: ambiguous key description "{0}"' -f $mapItem.MapTo)
                }

                $effectiveMap[$mapFromInfo.Code] = $mapToInfo.Code
            }
        }

        # add or modify

        $mapFromInfo = $keyData | where { $_.Description -eq $KeyName }
        if (-not $mapFromInfo)
        {
            throw ('Unsupported source key "{0}". Use "Get-WindowsKeyboardMap -Available" to get a list of supported keys.' -f $KeyName)
        }
        elseif ($mapFromInfo.Count -gt 1)
        {
            throw ('Internal error: ambiguous key description "{0}"' -f $KeyName)
        }

        $mapToInfo = $keyData | where { $_.Description -eq $MapTo }
        if (-not $mapToInfo)
        {
            throw ('Unsupported target key "{0}". Use "Get-WindowsKeyboardMap -Available" to get a list of supported keys.' -f $MapTo)
        }
        elseif ($mapToInfo.Count -gt 1)
        {
            throw ('Internal error: ambiguous key description "{0}"' -f $MapTo)
        }

        $effectiveMap[$mapFromInfo.Code] = $mapToInfo.Code
        [pscustomobject]@{
            KeyName = $mapFromInfo.Description
            MapTo = $mapToInfo.Description
        }
    }
    else
    {
        throw 'Internal error: uncaught parameter set.'
    }

    if ($effectiveMap.Keys.Count -eq 0)
    {
        # delete the key
        if (($PSCmdlet.ParameterSetName -like '*OnlineSet') -or ($PSCmdlet.ParameterSetName -like '*OfflineServiceSet'))
        {
            if (-not (Test-Path $regKeyPath))
            {
                # do nothing
            }
            else
            {
                $regKey = Get-Item $regKeyPath
                if ($regValueName -in $regKey.GetValueNames())
                {
                    Write-Verbose ('Remove "{0}" property "{1}".' -f $regKeyPath, $regValueName)
                    Remove-ItemProperty -Path $regKeyPath -Name $regValueName
                    #$regKey.DeleteValue($regValueName)
                }
                $regKey.Close()
                $regKey.Dispose()

                if ($PSCmdlet.ParameterSetName -like '*OnlineSet')
                {
                    Write-Warning ('Restart the computer or logout for changes to take effect.')
                }
            }
        }
        else
        {
            throw 'Internal error: uncaught parameter set.'
        }
    }
    else
    {
        $keymapCount = $effectiveMap.Keys.Count
        $regData = [byte[]]::CreateInstance([byte], (8 + 4 + (4 * $keymapCount) + 4))

        # skip #0-7

        # set #8 to count
        $regData[8] = [Convert]::ToByte($keymapCount + 1)

        # skip #9-11

        # add the list
        $cursor = 0
        foreach ($mapFromCode in $effectiveMap.Keys)
        {
            # Example: E0_0020

            $mapFromReg = $mapFromCode.Split('_')[0]
            $mapFromBin = $mapFromCode.Split('_')[1]

            # trim the prefix 0s (0020 -> 20)
            if ($mapFromBin.Length -gt 2)
            {
                $mapFromBin = $mapFromBin.Substring(2)
            }

            $mapToCode = $effectiveMap[$mapFromCode]
            
            $mapToReg = $mapToCode.Split('_')[0]
            $mapToBin = $mapToCode.Split('_')[1]

            if ($mapToBin.Length -gt 2)
            {
                $mapToBin = $mapToBin.Substring(2)
            }

            # scan codes are stored in ToHi ToLo FromHi FromLo

            $regData[($cursor * 4) + 12 + 0] = [Convert]::ToByte($mapToBin, 16)
            $regData[($cursor * 4) + 12 + 1] = [Convert]::ToByte($mapToReg, 16)

            $regData[($cursor * 4) + 12 + 2] = [Convert]::ToByte($mapFromBin, 16)
            $regData[($cursor * 4) + 12 + 3] = [Convert]::ToByte($mapFromReg, 16)

            $cursor += 1
        }

        # skip last 4

        if (($PSCmdlet.ParameterSetName -like '*OnlineSet') -or ($PSCmdlet.ParameterSetName -like '*OfflineServiceSet'))
        {
            if (-not (Test-Path $regKeyPath))
            {
                $regKey = md $regKeyPath -Force
                $regKey.Close()
                $regKey.Dispose()
            }

            if ($PSCmdlet.ParameterSetName -like '*OfflineServiceSet')
            {
                $regKey = Get-Item $regKeyPath
                $regKey.SetValue($regValueName, $regData)
                $regKey.Close()
                $regKey.Dispose()
            }
            else
            {
                Set-ItemProperty -Path $regKeyPath -Name $regValueName -Value $regData
                Write-Warning ('Restart the computer or logout for changes to take effect.')
            }
        }
        else
        {
            throw 'Internal error: uncaught parameter set.'
        }
    }
}

function Clear-WindowsKeyboardMap
{
    <#
        .SYNOPSIS
            Removes all Windows key mappings.

        .DESCRIPTION
            Type "Get-Help Get-WindowsKeyboardMap" for more details on Windows key mapping and available virtual key codes.

            Use "Remove-WindowsKeyboardMap" to remove a single key mapping.

            This command requires administrative privileges and affects all users on the Windows installation.

        .PARAMETER Online
            Writes changes to 'HKEY_LOCAL_MACHINE\\System\CurrentControlSet\Control\Keyboard Layout'. The property 'Scancode Map' will be removed.

        .PARAMETER SystemHiveMountPath
            Registry mount point to "HKEY_LOCAL_MACHINE\System". You should mount the registry hive file "%SystemRoot%\System32\Config\System" to your online registry.
    #>

    [CmdletBinding(DefaultParameterSetName = 'OnlineSet')]
    Param(
        [Parameter(Mandatory, ParameterSetName = 'OnlineSet')]
        [switch]$Online,

        [Parameter(Mandatory, ParameterSetName = 'OfflineServiceSet')]
        [string]$SystemHiveMountPath
    )

    $effectiveMap = @{}

    if ($PSCmdlet.ParameterSetName -eq 'OnlineSet')
    {
        Set-WindowsKeyboardMap -KeyMap $effectiveMap -Online
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'OfflineServiceSet')
    {
        Set-WindowsKeyboardMap -KeyMap $effectiveMap -SystemHiveMountPath $SystemHiveMountPath
    }
    else
    {
        throw 'Internal error: uncaught parameter set.'
    }
}

function Remove-WindowsKeyboardMap
{
    <#
        .SYNOPSIS
            Removes a keyboard mapping on Windows.

        .DESCRIPTION
            Use this command to remove an existing Windows key mapping.

            Type "Get-Help Get-WindowsKeyboardMap" for more details on Windows key mapping and available virtual key codes.

            Use "Clear-WindowsKeyboardMap" to remove all key mappings.

            This command requires administrative privileges and affects all users on the Windows installation.

        .PARAMETER KeyName
            The key to remove. Use "Get-WindowsKeyboardMap -Available" for a list of available key codes.

        .PARAMETER Online
            Writes changes to 'HKEY_LOCAL_MACHINE\\System\CurrentControlSet\Control\Keyboard Layout'. The property 'Scancode Map' will be modified or removed.

        .PARAMETER SystemHiveMountPath
            Registry mount point to "HKEY_LOCAL_MACHINE\System". You should mount the registry hive file "%SystemRoot%\System32\Config\System" to your online registry.
    #>

    [CmdletBinding(DefaultParameterSetName = 'OnlineSet')]
    Param(
        [Parameter(Mandatory)]
        [string]$KeyName,

        [Parameter(Mandatory, ParameterSetName = 'OnlineSet')]
        [switch]$Online,

        [Parameter(Mandatory, ParameterSetName = 'OfflineServiceSet')]
        [string]$SystemHiveMountPath
    )

    $effectiveMap = @{}

    if ($PSCmdlet.ParameterSetName -eq 'OnlineSet')
    {
        $currentMap = Get-WindowsKeyboardMap -Online
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'OfflineServiceSet')
    {
        $currentMap = Get-WindowsKeyboardMap -SystemHiveMountPath $SystemHiveMountPath
    }
    else
    {
        throw 'Internal error: uncaught parameter set.'
    }

    if (-not $currentMap)
    {
        # do nothing
        return
    }

    foreach ($mapItem in $currentMap)
    {
        $effectiveMap[$mapItem.KeyName] = $mapItem.MapTo
    }

    if ($KeyName -notin $effectiveMap.Keys)
    {
        # do nothing
        return
    }

    # remove the item
    $effectiveMap.Remove($KeyName)

    if ($PSCmdlet.ParameterSetName -eq 'OnlineSet')
    {
        Set-WindowsKeyboardMap -KeyMap $effectiveMap -Online
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'OfflineServiceSet')
    {
        Set-WindowsKeyboardMap -KeyMap $effectiveMap -SystemHiveMountPath $SystemHiveMountPath
    }
}

function Get-WindowsMediaKey
{
    <#
        .SYNOPSIS
            Shows all effective Windows multimedia keyboard configuration, or returns a list of supported multimedia keys.

        .DESCRIPTION
            Windows Explorer allows you to customize the applications that are launched using keys on multimedia keyboards.

            Administrative privileges are required to modify keyboard mappings. Changes affect all users.

        .PARAMETER Available
            Lists the media keys that are supported. No escalated privileges are required to execute with this flag. Windows will not be modified.

        .PARAMETER Online
            Reads from the Windows registry path 'HKEY_LOCAL_MACHINE\\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AppKey'. Sub-keys that can be parsed as integers will be analyzed.

        .PARAMETER SoftwareHiveMountPath
            Registry mount point to "HKEY_LOCAL_MACHINE\Software". You should mount the registry hive file "%SystemRoot%\System32\Config\Software" to your online registry.
    #>

    [CmdletBinding(DefaultParameterSetName = 'OnlineSet')]
    Param(
        [Parameter(Mandatory, ParameterSetName = 'OnlineSet')]
        [switch]$Online,

        [Parameter(Mandatory, ParameterSetName = 'OfflineServiceSet')]
        [string]$SoftwareHiveMountPath,

        [Parameter(Mandatory, ParameterSetName = 'GetAvailableSet')]
        [switch]$Available
    )

    $regKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AppKey'
    if ($PSCmdlet.ParameterSetName -eq 'OfflineServiceSet')
    {
        $regKeyPath = Join-Path $SoftwareHiveMountPath -ChildPath 'Microsoft\Windows\CurrentVersion\Explorer\AppKey'
    }

    #
    # Enum values from Microsoft
    # - https://docs.microsoft.com/en-us/windows/win32/api/winuser/
    #

    $mediaKeyboardMapping = @(
        'Backward'
        'Forward'
        'Refresh'
        'Stop'
        'Search'
        'Favorites'
        'Home'
        'Mute'
        'Down'
        'Up'
        'Next Track'
        'Previous Track'
        'Stop'
        'Play/Pause'
        'Mail'
        'Media Select'
        'App1/Computer'
        'App2/Calculator'
        'Bass Down'
        'Bass Boost'
        'Bass Up'
        'Treble Down'
        'Treble Up'
        'Microphone Volume Mute'
        'Microphone Volume Down'
        'Microphone Volume Up'
        'Help'
        'Find'
        'New'
        'Open'
        'Close'
        'Save'
        'Print'
        'Undo'
        'Redo'
        'Copy'
        'Cut'
        'Paste'
        'Reply To Mail'
        'Forward Mail'
        'Send Mail'
        'Spell Check'
        'Dictate or Command Control Toggle'
        'Microphone On/Off Toggle'
        'Correction List'
    )

    if ($PSCmdlet.ParameterSetName -eq 'GetAvailableSet')
    {
        for ($i = 0; $i -lt $mediaKeyboardMapping.Count; $i++)
        {
            [pscustomobject]@{
                KeyCode = $i + 1
                Description = $mediaKeyboardMapping[$i]
            }
        }

        return
    }

    if (-not (Test-Path $regKeyPath))
    {
        return
    }

    $mediaKeyBindings = dir $regKeyPath | select -expand PSChildName
    $mediaKeyBindings | ForEach-Object {
        $subkey = Get-Item (Join-Path $regKeyPath -ChildPath $_)
        
        $keyIndex = 0
        if (-not [int]::TryParse($_, [ref]$keyIndex))
        {
            continue
        }
        else
        {
            if (($keyIndex -gt 0) -and ($keyIndex -le $mediaKeyboardMapping.Count))
            {
                $keyDesc = $mediaKeyboardMapping[$keyIndex - 1]
            }
            else
            {
                $keyDesc = 'Unknown'
            }
        }

        if ('ShellExecute' -in $subkey.GetValueNames())
        {
            $shellExec = Get-ItemProperty -Path (Join-Path $regKeyPath -ChildPath $_) -Name 'ShellExecute' | select -expand ShellExecute
        }
        else
        {
            $shellExec = ''
        }

        if ('RegisteredApp' -in $subkey.GetValueNames())
        {
            $regApp = Get-ItemProperty -Path (Join-Path $regKeyPath -ChildPath $_) -Name 'RegisteredApp' | select -expand RegisteredApp
        }
        else
        {
            $regApp = ''
        }

        if ('Association' -in $subkey.GetValueNames())
        {
            $assoc = Get-ItemProperty -Path (Join-Path $regKeyPath -ChildPath $_) -Name 'Association' | select -expand Association
        }
        else
        {
            $assoc = ''
        }

        $outObject = [pscustomobject]@{
            KeyCode = $_
            Description = $keyDesc
        }

        if ($shellExec -ne '')
        {
            $outObject | Add-Member -MemberType NoteProperty -Name 'ShellExecute' -Value $shellExec
        }

        if ($regApp -ne '')
        {
            $outObject | Add-Member -MemberType NoteProperty -Name 'RegisteredApp' -Value $regApp
        }

        if ($assoc -ne '')
        {
            $outObject | Add-Member -MemberType NoteProperty -Name 'Association' -Value $assoc
        }

        $outObject
    }
}

function Set-WindowsMediaKey
{
    <#
        .SYNOPSIS
            Modifies the program associated with a Windows multimedia key. This feature only works on Windows.

        .DESCRIPTION
            You can use this command to define the program to launch when a multimedia key is press on your keyboard. Changes are immediate.

            Type "Get-Help Get-WindowsMediaKey" for more details on Windows multimedia keys.

            Use "Remove-WindowsMediaKey" or "Reset-WindowsMediaKey" to remove customized multimedia key configurations.

            This command requires administrative privileges and affects all users on the Windows installation.

        .PARAMETER KeyCode
            The key to modify. Use "Get-WindowsMedia -Available" for a list of available key codes.

        .PARAMETER ShellExecute
            Executes a program. May be an executable or shell object. Some examples are:
            - calc.exe
            - ::{20D04FE0-3AEA-1069-A2D8-08002B30309D}

            Any valid command that works in the Windows "Run" dialog box will work here.

        .PARAMETER RegisteredApp
            Execute the default application for a category of applications. You can configure default applications under Windows Settings. Some examples are:
            - Mail

        .PARAMETER Association
            Execute the default application associated with a protocol. Some examples are:
            - http

        .PARAMETER NoClobber
            Remove all previous customization on the multimedia key first, if any. Defaults to True.

        .PARAMETER Online
            Writes changes to the Windows registry path 'HKEY_LOCAL_MACHINE\\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AppKey\<KeyCode>'

        .PARAMETER SoftwareHiveMountPath
            Registry mount point to "HKEY_LOCAL_MACHINE\Software". You should mount the registry hive file "%SystemRoot%\System32\Config\Software" to your online registry.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ShellExecuteOnlineSet')]
    Param(
        [Parameter(Mandatory)]
        [int]$KeyCode,

        [Parameter(Mandatory, ParameterSetName = 'ShellExecuteOnlineSet')]
        [Parameter(Mandatory, ParameterSetName = 'ShellExecuteOfflineServiceSet')]
        [string]$ShellExecute,

        [Parameter(Mandatory, ParameterSetName = 'RegisteredAppOnlineSet')]
        [Parameter(Mandatory, ParameterSetName = 'RegisteredAppOfflineServiceSet')]
        [string]$RegisteredApp,

        [Parameter(Mandatory, ParameterSetName = 'AssociationOnlineSet')]
        [Parameter(Mandatory, ParameterSetName = 'AssociationOfflineServiceSet')]
        [string]$Association,

        [Parameter()]
        [switch]$NoClobber = $true,

        [Parameter(Mandatory, ParameterSetName = 'ShellExecuteOnlineSet')]
        [Parameter(Mandatory, ParameterSetName = 'RegisteredAppOnlineSet')]
        [Parameter(Mandatory, ParameterSetName = 'AssociationOnlineSet')]
        [switch]$Online,

        [Parameter(Mandatory, ParameterSetName = 'ShellExecuteOfflineServiceSet')]
        [Parameter(Mandatory, ParameterSetName = 'RegisteredAppOfflineServiceSet')]
        [Parameter(Mandatory, ParameterSetName = 'AssociationOfflineServiceSet')]
        [string]$SoftwareHiveMountPath
    )

    if (-not (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
    {
        throw 'This command requires administrative privileges.'
    }
    
    $regKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AppKey'
    if ($PSCmdlet.ParameterSetName -like '*OfflineServiceSet')
    {
        $regKeyPath = Join-Path $SoftwareHiveMountPath -ChildPath 'Microsoft\Windows\CurrentVersion\Explorer\AppKey'
    }

    $targetPath = Join-Path $regKeyPath -ChildPath $KeyCode
    if (-not (Test-Path $targetPath))
    {
        Write-Verbose ('Create profile for media key "{0}".' -f $KeyCode)
        $regkey = md $targetPath -Force
    }
    else
    {
        Write-Verbose ('Modify profile for media key "{0}".' -f $KeyCode)
        $regkey = Get-Item $targetPath

        if ($NoClobber)
        {
            @('Association', 'RegisteredApp', 'ShellExecute') | ForEach-Object {
                if ($_ -in $regkey.GetValueNames())
                {
                    Write-Verbose ('Removing existing property "{0}".' -f $_)
                    Remove-ItemProperty -Path $targetPath -Name $_
                }
            }        
        }    
    }

    if ($PSCmdlet.ParameterSetName -like 'ShellExecute*')
    {
        $propName = 'ShellExecute'
        $propValue = $ShellExecute
    }
    elseif ($PSCmdlet.ParameterSetName -like 'RegisteredApp*')
    {
        $propName = 'RegisteredApp'
        $propValue = $RegisteredApp
    }
    elseif ($PSCmdlet.ParameterSetName -like 'Association*')
    {
        $propName = 'Association'
        $propValue = $Association
    }
    else
    {
        throw 'Internal error: uncaught parameter set.'
    }

    Write-Verbose ('Set property "{0}".' -f $propName)
    Set-ItemProperty -Path $targetPath -Name $propName -Value $propValue

    $regkey.Close()
    $regkey.Dispose()
}

function Remove-WindowsMediaKey
{
    <#
        .SYNOPSIS
            Removes all settings on a Windows multimedia key. This feature only works on Windows.

        .DESCRIPTION
            You can use this command to remove all settings on a Windows multimedia key. Changes are immediate.

            Type "Get-Help Get-WindowsMediaKey" for more details on Windows multimedia keys.

            This command will remove the entire Windows registry key associated. To remove customization properties only, use "Reset-WindowsMediaKey".

            This command requires administrative privileges and affects all users on the Windows installation.

        .PARAMETER KeyCode
            The key to modify. Use "Get-WindowsMedia -Available" for a list of available key codes.

        .PARAMETER Online
            Removes the Windows registry path 'HKEY_LOCAL_MACHINE\\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AppKey\<KeyCode>' if required.

        .PARAMETER SoftwareHiveMountPath
            Registry mount point to "HKEY_LOCAL_MACHINE\Software". You should mount the registry hive file "%SystemRoot%\System32\Config\Software" to your online registry.
    #>

    [CmdletBinding(DefaultParameterSetName = 'OnlineSet')]
    Param(
        [Parameter(Mandatory)]
        [int]$KeyCode,

        [Parameter(Mandatory, ParameterSetName = 'OnlineSet')]
        [switch]$Online,

        [Parameter(Mandatory, ParameterSetName = 'OfflineServiceSet')]
        [string]$SoftwareHiveMountPath
    )

    if (-not (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
    {
        throw 'This command requires administrative privileges.'
    }

    $regKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AppKey'
    if ($PSCmdlet.ParameterSetName -eq 'OfflineServiceSet')
    {
        $regKeyPath = Join-Path $SoftwareHiveMountPath -ChildPath 'Microsoft\Windows\CurrentVersion\Explorer\AppKey'
    }

    $targetPath = Join-Path $regKeyPath -ChildPath $KeyCode
    if (-not (Test-Path $targetPath))
    {
        Write-Verbose ('Unable to find an existing profile for media key "{0}".' -f $KeyCode)
        return
    }

    Write-Verbose ('Removing profile for media key "{0}".' -f $KeyCode)
    Remove-Item $targetPath -Recurse -Force
}

function Reset-WindowsMediaKey
{
    <#
        .SYNOPSIS
            Reset all settings on a Windows multimedia key to its defaults. This feature only works on Windows.

        .DESCRIPTION
            You can use this command to remove customization properties on a Windows multimedia key. Changes are immediate.

            Type "Get-Help Get-WindowsMediaKey" for more details on Windows multimedia keys.

            This command will remove customization properties only, To remove the entire Windows registry key associated, use "Remove-WindowsMediaKey".

            This command requires administrative privileges and affects all users on the Windows installation.

        .PARAMETER KeyCode
            The key to modify. Use "Get-WindowsMedia -Available" for a list of available key codes.

        .PARAMETER Online
            Removes the following properties under the Windows registry path 'HKEY_LOCAL_MACHINE\\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AppKey\<KeyCode>' if required:
            - Association
            - RegisteredApp
            - ShellExecute

        .PARAMETER SoftwareHiveMountPath
            Registry mount point to "HKEY_LOCAL_MACHINE\Software". You should mount the registry hive file "%SystemRoot%\System32\Config\Software" to your online registry.
    #>

    [CmdletBinding(DefaultParameterSetName = 'OnlineSet')]
    Param(
        [Parameter(Mandatory)]
        [int]$KeyCode,

        [Parameter(Mandatory, ParameterSetName = 'OnlineSet')]
        [switch]$Online,

        [Parameter(Mandatory, ParameterSetName = 'OfflineServiceSet')]
        [string]$SoftwareHiveMountPath
    )

    if (-not (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
    {
        throw 'This command requires administrative privileges.'
    }

    $regKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AppKey'
    if ($PSCmdlet.ParameterSetName -eq 'OfflineServiceSet')
    {
        $regKeyPath = Join-Path $SoftwareHiveMountPath -ChildPath 'Microsoft\Windows\CurrentVersion\Explorer\AppKey'
    }

    $targetPath = Join-Path $regKeyPath -ChildPath $KeyCode
    if (-not (Test-Path $targetPath))
    {
        Write-Verbose ('Created profile for media key "{0}" using default values.' -f $KeyCode)
        $regkey = md $targetPath -Force
    }
    else
    {
        $regkey = Get-Item $targetPath

        @('Association', 'RegisteredApp', 'ShellExecute') | ForEach-Object {
            if ($_ -in $regkey.GetValueNames())
            {
                Write-Verbose ('Removed property "{0}" of media key "{1}".' -f $_, $KeyCode)
                Remove-ItemProperty -Path $targetPath -Name $_
            }
        }
    }

    $regkey.Close()
    $regkey.Dispose()
}
