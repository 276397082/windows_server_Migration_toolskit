@echo off&SETLOCAL EnableDelayedExpansion
:s0
cls
mode con cols=100
color 0a
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem "') do (
  set "DEL=%%a"
)
echo.
echo.

call :ColorText 0e "��ʼִ��ǰ���������úò���"

echo.
echo.
rem -----------------------�û��Զ������-----------------------
set backupPath=E:\backup

set USERNAME=sa
set PASSWORD=KMS@admin459
rem -----------------------�û��Զ������-----------------------

set dbname=
if not exist "!backupPath!" ( 
mkdir "!backupPath!"
) else (

dir /s /b "!backupPath!\*.bak" >nul 2>1&& (
   echo.
   echo �����ļ����ڣ�����ִ�н�����ԭ�б����ļ�
   echo.
choice /C YN /M "�Ƿ񸲸�ԭ�б����ļ�!backupPath!�еı����ļ���"
   echo.
IF ERRORLEVEL 2 (
    REM �û�ѡ�񡰷񡱵Ĳ���
    echo ������ȡ��pause&exit
) ELSE (
    REM �û�ѡ���ǡ��Ĳ���
    echo ִ�в���
)
)
)

rem takeown /F "!backupPath!" /R /D Y
rem icacls "!backupPath!" /grant "NT Service\MSSQLSERVER":(OI)(CI)F
rem icacls "!backupPath!" /grant "everyone":(OI)(CI)F

rem �����������ݿ�-------------------------------------------------------------------------------------------------------------------------------
:s1

echo.
echo.
sqlcmd   -I -Q "SET NOCOUNT ON; SELECT name FROM sys.databases WHERE state = 0 AND name ^!= 'tempdb'"  -h-1 -W


for /f "tokens=1 delims=," %%c in ('sqlcmd -U %USERNAME% -P %PASSWORD% -I -Q "SET NOCOUNT ON; SELECT name FROM sys.databases WHERE state = 0 AND name ^!= 'tempdb'" -h-1 -W') do (
set dbname=%%c

call :backup
)
pause
exit

:backup

rem  sqlcmd -U %USERNAME% -P %PASSWORD% -I -Q "BACKUP DATABASE !dbname! TO DISK='!backupPath!'"
echo.
sqlcmd  -U %USERNAME% -P %PASSWORD%  -I -Q "BACKUP DATABASE !dbname! TO DISK='!backupPath!\!dbname!.bak'"
echo.
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
