:: A simple batch program for appending a path to user environment variable

@echo off
setlocal

:: set user path
set ok=0
for /f "skip=2 tokens=3*" %%a in ('reg query HKCU\Environment /v PATH') do if [%%b]==[] ( setx PATH "%%~a;%*" && set ok=1 ) else ( setx PATH "%%~a;%%~b;%*" && set ok=1 )
if "%ok%" == "0" setx PATH "%*"

:end
endlocal
echo.
