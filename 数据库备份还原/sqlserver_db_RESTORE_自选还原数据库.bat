@echo off&SETLOCAL EnableDelayedExpansion
:s0
cls
mode con cols=150
color 0a
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem "') do (
  set "DEL=%%a"
)
echo.
echo.
echo.
rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------
rem -----------------------�û��Զ�����������޸�-----------------------
rem �����ļ����·��
set backupPath=E:\backup

echo dataPath����Ϊ���û������ݿ���Ŀ¼,��ϵͳ�����ݿ��ļ���Ĭ��λ�ñ��棬������ָ��λ��
echo ��Ҫ�������ϵͳĬ��·����������dataPathΪ��def
echo �Զ��壺�����ʵ�������޸�Ϊ��Ӧ��·��

rem ���ݿ��ļ����·��
set dataPath=D:\DataBase
rem set dataPath=def
rem ���ݿ��û�
set USERNAME=sa
rem ���ݿ�����
set PASSWORD=sa2016
rem -----------------------�û��Զ�����������޸�-----------------------
rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------
echo.
echo.
echo         	          	 master�������й�����SQL Serverʵ����ϵͳ����Ϣ�������¼ƾ�ݡ�ϵͳ����ѡ��ȡ�
echo.
echo         	          	 model�������½����ݿ��ģ�塣�����������ݿ�ʱ��SQL Server��ʹ��model���ݿ�ĸ�����Ϊģ�塣
echo.
echo         	          	 msdb���洢SQL Server������ҵ�����ݺͻ�ԭ��ʷ��¼�����ݿ�ά���ƻ��ȹ����������Ϣ��
echo.
echo         	          	 tempdb�����ڴ洢��ʱ������ʱ�����ʱ���������ʱ���ݡ����ñ��ݻ�ԭ
echo.
echo         	          	 ReportServer�����ڴ洢SQL Server Reporting Services (SSRS) �ı����塢���ġ���ȫ�����ú�ִ����ʷ��¼����Ϣ��
echo.
echo         	          	 ReportServerTempDB�����ڴ洢SSRS����ִ���ڼ����ʱ���ݺ͹�����
echo.
echo.
echo.
call :ColorText 04 "----------------�����޼ۣ���ȷ�����ݰ�ȫ������½���----------------"
echo.
echo.
echo �����ļ����·��:!backupPath!
echo ���ݿ��ļ����·��:!dataPath!
echo.
choice /M "��ȷ�����ݰ�ȫ������½��У�"
if %errorlevel%==2 exit
cls
echo.
echo.
call :ColorText 0e "��ʼִ��ǰ���������úò���"
echo.
echo.
choice /M "�����Ƿ����ú��ˣ�"
if %errorlevel%==2 exit


if "!dataPath!"=="def" (call :getnamepath)

if not exist "!backupPath!"  (call :ColorText 0e "�����ļ�Ŀ¼�����ڣ�����backupPath�����򿽱������ļ�����ִ��"&pause&exit)
dir /s /b "!backupPath!\*.bak" >nul 2>&1

if %errorlevel%==1 (
   echo.
   echo �����ļ������ڣ��뿽�������ļ�����ִ��
   echo.
pause&exit
)
if not exist "!dataPath!"  (call :ColorText 0e "���ݿ���Ŀ¼�����ڣ�����dataPath�����򴴽�Ŀ¼����ִ��"&pause&exit)

rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------
rem -----------------------�ű����в��������޸�-----------------------
set result2=
set dbname=
set filelist=
set movename=
set movelog=
set sysDB='master', 'model', 'msdb','ReportServer','ReportServerTempDB'
set userDB='master', 'model', 'msdb','tempdb','ReportServer','ReportServerTempDB'
set /a bb=0
set /a cc=0
set allname=
rem -----------------------�ű����в��������޸�-----------------------
rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------



call :ColorText 0e "--------------------��ȡ���ı����ļ����£�--------------------"
echo.
if exist "%temp%\lzdb" ( del %temp%\lzdb)
for /f "delims=." %%x in ('dir  /b !backupPath!\*.bak') do (

set /a bb+=1
echo !bb!��%%x
echo !bb!��%%x>>%temp%\lzdb
set allname=!allname!%%x,
rem echo !allname!
)
set /a bb+=1
call :ColorText 09 "!bb!������ģʽ"
echo.

rem �û�����----------------------------------------
set /p user_input=��ѡ��Ҫ��ԭ�����ݿ⣬��ѡ�����磨1,2,3����
rem ���������ж�
echo !user_input! | find /i "!bb!">nul&&(
  call :c1
) || (
 call :dx
)
echo.
echo.
call :ColorText 04 "----------------�������ݿ⻹ԭ���----------------"
pause
if exist "~%dp0err.log" (start "" "%~dp0err.log")

exit

rem �����û������ѡ��----------------------------------------
:dx
for %%y in (!user_input!) do (
set /a cc=0
call :xx %%y
)
exit /B

rem ����ƥ���û������ѡ��----------------------------------------
:xx

for %%z in (!allname!) do (

set /a cc=!cc!+1

if "!cc!"=="%1" (
set dbname=%%z
echo !sysDB! | findstr /i "\<%%z\>">nul&&(
rem echo !sysDB! | findstr /i "\<%%z\>"

    call :sys
) || (

 call :user
)
rem call :bk %%z

)
)
exit /B

rem �������----sys------------------------------------
:sys
echo.
call :ColorText 04 "----------------��ʼ��ԭϵͳ���ݿ�!dbname!----------------"

echo.
if "!dbname!"=="master" (call :master) else (
if "!dbname!"=="ReportServer" (call :ReportServer) else (call :sysdb)
)
exit /B

:sysdb
set sqltext=""
echo.
call :getname


   	rem sqlcmd  -I -U %USERNAME% -P %PASSWORD%  -Q "ALTER DATABASE !dbname! MODIFY FILE (NAME = '!movename!', FILENAME = '%dataPath%\!dbname!.mdf');" 
   	rem sqlcmd  -I -U %USERNAME% -P %PASSWORD% -Q  "ALTER DATABASE !dbname! MODIFY FILE (NAME =  '!movelog!' ,FILENAME =  '%dataPath%\!dbname!log.ldf');"
	rem set sqltext="RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH REPLACE,MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!_log.ldf'"

	set sqltext="RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH replace;"
	sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q !sqltext!| findstr "MB">nul&&(
echo.
echo !dbname!----���ݻ�ԭ�ɹ�......................
echo.

) || (
echo.
call :ColorText 0c "!dbname!----���ݻ�ԭʧ��......................"
echo.
echo.
echo ִ����䣺sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q !sqltext!
echo.
echo ������Ϣ��
echo.
sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q !sqltext!
echo.
echo.
)

exit /B

rem �������----user------------------------------------
:user

call :getname

set sqltext=""
if "!dbname!" == "!movename!" (
  set sqltext="RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH replace;"
if not "!dataPath!"=="def" (
set sqltext="RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH REPLACE,MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!_log.ldf'"
)
) else (
rem set sqltext="RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH   MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!_log.ldf'"
set sqltext="RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH REPLACE,MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!_log.ldf'"

)

sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q !sqltext!| findstr "MB">nul&&(
echo.
echo !dbname!----���ݻ�ԭ�ɹ�......................
echo.

) || (
echo.
call :ColorText 0c "!dbname!----���ݻ�ԭʧ��......................"
echo.
echo.
echo ִ����䣺sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q !sqltext!
echo.
echo ������Ϣ��
echo.
sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q !sqltext!
echo.
echo.
call :ColorText 09 "----����Ϊ!dbname!ִ��move1���......................������"
echo.
echo.
call :move
)
exit /B


:c1
cls

echo.
call :ColorText 0c "��Ҫִ�еĻ�ԭ����"
echo:
echo.
echo         	          	 1����ԭ����ϵͳ���ݿ⣺!sysDB!
echo:
echo         	          	 2����ԭ�����û����ݿ⣬����!userDB!֮���
echo.
echo         	��ʾ��1-9���װ��ȫ�����ü�Ϊ��Сģʽ
echo.

echo.
set /p choice=         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�: 
echo.
if /i "%choice%"=="1" call :ColorText 04 "----------------��ԭ����ϵͳ----------------"&&pause&&cls&&call :s1&exit /B
echo.
if /i "%choice%"=="2" call :ColorText 04 "----------------��ԭ�����û����ݿ�-----��!userDB!֮���----------------"&&pause&&cls&&call :s2&exit /B
echo.
if /i "%choice%"=="3" call :ColorText 04 "----------------��ԭ����ϵͳ+�û����ݿ�----------------"&&pause&&cls&&call :s2&exit /B
echo.
call :ColorText 4f "---------------------������ѡ�����Ч������������---------------------"&&pause&&cls
echo.
goto c1

rem ��ԭ����ϵͳ���ݿ�-------------------------------------------------------------------------------------------------------------------------------
:s1

echo.
set /a js=0
set user_input=
set "aaa= !sysDB! | findstr /i "^\^<%%k^\^>""
if "%1"=="uuu" (set "aaa= !userDB! | findstr /i /v "^\^<%%k^\^>"")
rem echo !allname!
for %%k in (!allname!) do (
rem echo !sysDB! | find /i "%%k">nul&&(
echo  %aaa% >nul&&(
rem echo %%k
set /a js+=1
   set user_input=!user_input!!js!,
) || (
set /a js+=1
)
) 
call :ColorText 0e "--------------------��ȡ���ı����ļ����£�--------------------"
echo.
type %temp%\lzdb
echo.
echo.
call :ColorText 0e "--------------------��ѡ��Ҫ��ԭ�����ݿ����£�--------------------"
echo.
echo.
echo !user_input!
echo.
echo.
call :ColorText 0e "--------------------ȷ��ִ��--------------------"
pause
call :dx
exit /B


rem ��ԭ�����ݿ�------------------------------------------------------------------------------------------------------------------------------
:s2
echo.
call :s1 uuu
exit /B

:master

echo �������û�ģʽ......................  
echo.
NET stop MSSQLSERVER
echo.
echo.
NET START MSSQLSERVER /m
echo.
call :ColorText 0d "���ڻ�ԭ!dbname!"
echo.
	   sqlcmd  -I -Q  "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH replace;"
rem ,MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!'  TO '%dataPath%\!dbname!_log.ldf'
IF %ERRORLEVEL% NEQ 0 (
echo.
echo  ��ԭ!dbname!����������&pause&goto s0
echo.
)
exit /B

:notmaster
echo.
call :ColorText 05 "����!dbname!��ԭ���......................"
echo.
	set result2=RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH  replace;

echo.
call :ColorText 0d "!dbname!----���ڻ�ԭ......................"
echo. 
echo.

:cs
net start | find  "SQL Server (MSSQLSERVER)" >nul&& echo ���������� || NET START MSSQLSERVER&timeout 5 >nul
sqlcmd  -I -U %USERNAME% -P %PASSWORD% -Q  "%result2%"| findstr "MB" >nul&&(
echo.
echo !dbname!----���ݻ�ԭ�ɹ�......................
echo.

) || (
echo.
call :ColorText 0c "!dbname!----���ݻ�ԭʧ��......................"
echo.
sqlcmd  -I -U %USERNAME% -P %PASSWORD% -Q  "%result2%"
echo.
echo  ������&pause&goto cs
echo.
)

exit /B


:notmaster2
echo.
call :ColorText 05 "����!dbname!���......................"
echo.
pause
if "!dbname!"=="("  goto str
	set result2=!result2!RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH  replace;

exit /B
:str
set "result2=%result2:~0,-1%"
if "%result2%"=="~0,-1" (echo δ��ȡ�����ݣ�������&pause&NET stop MSSQLSERVER&goto s0)

echo "%result2%"
echo.
call :ColorText 0d "���ڻ�ԭmaster�����ϵͳ���ݿ�......................"
echo. 
echo.
net start | find  "SQL Server (MSSQLSERVER)" >nul&& echo ���������� || NET START MSSQLSERVER&timeout 5 >nul
echo.
echo.
sqlcmd  -I -U %USERNAME% -P %PASSWORD% -Q  "%result2%"
IF %ERRORLEVEL% NEQ 0 (
echo.
echo  ��ԭ����������&pause&goto str
echo.
)
exit /B




:ReportServer

echo.
call :ColorText 0d "���ڻ�ԭ!dbname!......................"
echo.
net start | find  "SQL Server (MSSQLSERVER)" >nul&& echo ���������� || NET START MSSQLSERVER&timeout 5 >nul
     sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "ALTER DATABASE ReportServer SET OFFLINE WITH ROLLBACK IMMEDIATE;"

IF %ERRORLEVEL% NEQ 0 (
echo.
call :ColorText 0c "ROLLBACK IMMEDIATEʧ��......................������"
echo.
goto ReportServer
echo.
)

call :user sys
exit /B




:move
call :getname

sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH   MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!_log.ldf'"| findstr "MB" >nul&&(
echo.
echo !dbname!----����ִ��move��仹ԭ�ɹ�......................
echo.

) || (call :replace)
exit /B


:replace
echo.
echo.
call :ColorText 09 "MOVE '!dbname!'����=== ����ִ��WITH REPLACE,MOVE===����......................"
echo.
echo.
sqlcmd -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH REPLACE,MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!_log.ldf'"| findstr "MB" >nul&&(
echo.
echo !dbname!----����ִ��WITH REPLACE,MOVE��ԭ�ɹ�......................

) || (call :err)
exit /B


:err
echo.
echo.
echo ִ����䣺move
echo ִ����䣺sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH   MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!.ldf'"
echo.
sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH   MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!.ldf'"
echo.
echo.
echo.


echo.
echo ִ����䣺WITH REPLACE,MOVE
echo ������Ϣ��
echo ִ����䣺sqlcmd -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH REPLACE,MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!.ldf'"
echo.
echo ������Ϣ��
echo.
sqlcmd -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH REPLACE,MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!.ldf'"
echo.


call :ColorText 09 "!dbname!-----���ݻ�ԭʧ�ܣ� WITH move OR WITH REPLACE,MOVE���޷���ԭ......................"
echo !dbname!-----���ݻ�ԭʧ�ܣ� WITH move OR WITH REPLACE,MOVE���޷���ԭ..................... >"%~dp0err.log"
echo.
exit /B


:getname
set filelist=
net start | find  "SQL Server (MSSQLSERVER)" >nul&& echo. || NET START MSSQLSERVER&timeout 5 >nul
rem ʹ�� RESTORE FILELISTONLY ����鿴���ݼ��е����ݿ��ļ���Ϣ��������������
rem sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE FILELISTONLY FROM DISK = '%backupPath%\!dbname!.bak'" -h-1 -W
for /f "tokens=1-2" %%e in ('sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE FILELISTONLY FROM DISK = '%backupPath%\!dbname!.bak'" -h-1 -W ^| findstr /v "("') do (
set filelist=!filelist!%%e+
)
rem ��ȡ����
for /F "delims=+ tokens=1-2" %%g in ("!filelist!") do (
set movename=
set movelog=
set movename=%%g
set movelog=%%h
)
exit /B

:getnamepath

for /f "tokens=* delims=" %%i in ('sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "SELECT LEFT(physical_name, LEN(physical_name) - CHARINDEX('\', REVERSE(physical_name))) FROM sys.master_files WHERE database_id = DB_ID('master') AND type = 0;" -h-1 -W ^| findstr /v "("') do (
set  dataPath="%%i"

)

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
