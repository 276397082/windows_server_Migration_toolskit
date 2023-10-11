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

call :ColorText 0e "开始执行前，请先设置好参数"

echo.
echo.
rem -----------------------用户自定义参数-----------------------
set backupPath=E:\backup

set USERNAME=sa
set PASSWORD=KMS@admin459
rem -----------------------用户自定义参数-----------------------

set /a g=0

set dbname=
set allname=

if not exist "!backupPath!" ( 
mkdir "!backupPath!"
) else (

dir /s /b "!backupPath!\*.bak" >nul 2>1&& (
   echo.
   echo 备份文件存在，继续执行将覆盖原有备份文件
   echo.
choice /C YN /M "是否覆盖原有备份文件!backupPath!中的备份文件？"
   echo.
IF ERRORLEVEL 2 (
    REM 用户选择“否”的操作
    echo 操作被取消pause&exit
) ELSE (
    REM 用户选择“是”的操作
    echo 执行操作
)
)
)


rem takeown /F "!backupPath!" /R /D Y
rem icacls "!backupPath!" /grant "NT Service\MSSQLSERVER":(OI)(CI)F
rem icacls "!backupPath!" /grant "everyone":(OI)(CI)F

rem 备份所有数据库-------------------------------------------------------------------------------------------------------------------------------
:s1

for /f "tokens=1 delims=," %%n in ('sqlcmd   -I -Q "SET NOCOUNT ON; SELECT name FROM sys.databases WHERE state = 0 AND name ^!= 'tempdb'"  -h-1 -W') do (
set /a g=!g!+1

echo !g!、%%n
set allname=!allname!%%n,

)

rem echo !allname!
echo.
set /p user_input=请选择要备份的数据库，支持多选用英文逗号分隔：1,2,3,4,5：

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
