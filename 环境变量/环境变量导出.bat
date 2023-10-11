@echo off
set regPath=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
set excludeKeys=PROCESSOR
if exist "%~dp0path.reg" del  "%~dp0path.reg" /f

reg export "%regPath%" "%~dp0temp.txt" /y
set input_file=%~dp0temp.txt
set output_file=%~dp0temp.txt

powershell -Command "(Get-Content -Path '%input_file%' -Encoding UTF8) | Set-Content -Path '%output_file%' -Encoding Default"

for /f "usebackq delims=*" %%a in ("%~dp0temp.txt") do (
echo "%%a" | findstr /i "\<OS" >nul || (
echo "%%a" | findstr /i "%excludeKeys%">nul || (
echo "%%a" | findstr /i "windir">nul || (
echo %%a >>"%~dp0path.reg"
)
)
)

)
del  "%~dp0temp.txt" /f
