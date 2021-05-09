Dim path
If WScript.Arguments.Count = 0 Then 
    Wscript.Quit 
End If

path = WScript.Arguments(0)

Set objShell = CreateObject("WScript.Shell")
Set objEnv = objShell.Environment("USER")
 
objEnv("Path") = objEnv("Path") & ";" & path