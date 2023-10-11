@echo off &SETLOCAL EnableDelayedExpansion
cls
color 0a
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem "') do (
  set "DEL=%%a"
)
echo.
rem ---------------------------------------------


set srcserver=10.87.72.55
echo.
net use \\%srcserver% /d /y >nul 2>&1
net use \\%srcserver%\ipc$ "*********" /user:"administrator" 
echo.
rem 注意【顺序】

rem 将【远程--源】磁盘【d】映射到本地【y】
rem 将【远程--源】磁盘【e】映射到本地【z】
rem 将【y】盘拷贝到本地【d】
rem 将【z】盘拷贝到本地【e】


rem 【源】磁盘【盘符】
set src=d,e


rem 映射到本地【盘符】
set dts=y,z


rem 本地磁盘【盘符】
set mydts=d,e



rem ---------------------------------------------



set aaa=
set bbb=
set ccc=
set srcc=0
for %%a in (%src%) do (

set /a srcc +=1
set aaa=%%a
call :dts !srcc! %%a
call :mydts !srcc! %%a
call :tb

)
pause
exit


:dts
set dtss=0
for %%b in (%dts%) do (
set /a dtss +=1
if "%1" =="!dtss!" (
set bbb=%%b
)
)
exit /B


:mydts
set mydtsdtss=0
for %%c in (%mydts%) do (
set /a mydtsdtss +=1
if "%1" =="!mydtsdtss!" (
set ccc=%%c
)
)
exit /B


:tb
call :ColorText 09 "开始同步…………"
echo.
echo.
echo  net use  !bbb!: /delete >nul 2>&1
net use  !bbb!: /delete 

echo 磁盘映射----------远程磁盘：[\\!srcserver!\!aaa!$] ----------^> 映射磁盘：[!bbb!:]
echo.
echo.
net use !bbb!: \\%srcserver%\!aaa!$  

set logf=%~dp0copylog.txt
set logr=%~dp0RobocopyLog.txt

echo 文件同步----------映射磁盘：[!bbb!: ]----------^>本地磁盘：[ !ccc!:]
echo.
echo.
call :ColorText 09 "请确认路径是否正确，开始同步…………"&&pause
echo.
echo.
start FastCopy.exe /cmd=diff     /open_window /auto_close /force_close /bufsize=8192 /log    /no_confirm_stop   /logfile="%logf%"     "!bbb!:\" /to="!ccc!:\"
rem ROBOCOPY  "!bbb!:" "!ccc!:" /E /COPYALL /MT:30 /Z  /TEE /LOG+:%logr%
exit /B

pause
exit

goto :eof

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof