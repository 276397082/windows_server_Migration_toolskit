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

set /a g=0

set dbname=
set allname=

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

for /f "tokens=1 delims=," %%n in ('sqlcmd   -I -Q "SET NOCOUNT ON; SELECT name FROM sys.databases WHERE state = 0 AND name ^!= 'tempdb'"  -h-1 -W') do (
set /a g=!g!+1

echo !g!��%%n
set allname=!allname!%%n,

)

rem echo !allname!
echo.
set /p user_input=��ѡ��Ҫ���ݵ����ݿ⣬֧�ֶ�ѡ��Ӣ�Ķ��ŷָ���1,2,3,4,5��

for %%o in (%user_input%) do (

set /a h=0

call :xx %%o
   
)
pause
exit

:xx
for %%p in (!allname!) do (
set /a h=!h!+1

if "!h!"=="%1" (

call :backup %%p

)
)

exit /B
 


pause
exit

:backup

rem  sqlcmd -U %USERNAME% -P %PASSWORD% -I -Q "BACKUP DATABASE %1 TO DISK='%1'"
echo.
sqlcmd  -U %USERNAME% -P %PASSWORD%  -I -Q "BACKUP DATABASE %1 TO DISK='!backupPath!\%1.bak'"
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
