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
rem ע�⡾˳��

rem ����Զ��--Դ�����̡�d��ӳ�䵽���ء�y��
rem ����Զ��--Դ�����̡�e��ӳ�䵽���ء�z��
rem ����y���̿��������ء�d��
rem ����z���̿��������ء�e��


rem ��Դ�����̡��̷���
set src=d,e


rem ӳ�䵽���ء��̷���
set dts=y,z


rem ���ش��̡��̷���
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
call :ColorText 09 "��ʼͬ����������"
echo.
echo.
echo  net use  !bbb!: /delete >nul 2>&1
net use  !bbb!: /delete 

echo ����ӳ��----------Զ�̴��̣�[\\!srcserver!\!aaa!$] ----------^> ӳ����̣�[!bbb!:]
echo.
echo.
net use !bbb!: \\%srcserver%\!aaa!$  

set logf=%~dp0copylog.txt
set logr=%~dp0RobocopyLog.txt

echo �ļ�ͬ��----------ӳ����̣�[!bbb!: ]----------^>���ش��̣�[ !ccc!:]
echo.
echo.
call :ColorText 09 "��ȷ��·���Ƿ���ȷ����ʼͬ����������"&&pause
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