If CreateObject("WScript.Shell").Run("%ComSpec% /C ""NET FILE""", 0, True) <> 0 Then
    CreateObject("Shell.Application").ShellExecute WScript.FullName, """" & WScript.ScriptFullName & """", , "runas", 5
    WScript.Quit
End If
Set Shell = CreateObject("WScript.Shell")
strHomeFolder = Shell.ExpandEnvironmentStrings("%USERPROFILE%")


Cmd = Shell.Exec("%ComSpec% /C ""REG QUERY ""HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"" /v Path | FINDSTR /I /C:""REG_SZ"" /C:""REG_EXPAND_SZ""""").StdOut.ReadAll
Cmd = """" & Trim(Replace(Mid(Cmd, InStr(1, Cmd, "_SZ", VBTextCompare) + 3), vbCrLf, ""))
If Right(Cmd, 1) <> ";" Then Cmd = Cmd & ";"
Cmd = "%ComSpec% /C ""REG ADD ""HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"" /v Path /t REG_EXPAND_SZ /d " & Replace(Cmd & strHomeFolder & "\.flutter-sdktest\bin"" /f""", "%", """%""")
Shell.Run Cmd, 0, True