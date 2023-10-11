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
rem -----------------------用户自定义参数可以修改-----------------------
rem 备份文件存放路径
set backupPath=E:\backup

echo dataPath参数为【用户】数据库存放目录,【系统】数据库文件在默认位置保存，不接受指定位置
echo 想要都存放在系统默认路径，请设置dataPath为：def
echo 自定义：请根据实际需求修改为对应的路径

rem 数据库文件存放路径
set dataPath=D:\DataBase
rem set dataPath=def
rem 数据库用户
set USERNAME=sa
rem 数据库密码
set PASSWORD=sa2016
rem -----------------------用户自定义参数可以修改-----------------------
rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------
echo.
echo.
echo         	          	 master：包含有关整个SQL Server实例的系统级信息，例如登录凭据、系统配置选项等。
echo.
echo         	          	 model：用作新建数据库的模板。当创建新数据库时，SQL Server会使用model数据库的副本作为模板。
echo.
echo         	          	 msdb：存储SQL Server代理作业、备份和还原历史记录、数据库维护计划等管理任务的信息。
echo.
echo         	          	 tempdb：用于存储临时对象、临时表和临时结果集等临时数据。不用备份还原
echo.
echo         	          	 ReportServer：用于存储SQL Server Reporting Services (SSRS) 的报表定义、订阅、安全性设置和执行历史记录等信息。
echo.
echo         	          	 ReportServerTempDB：用于存储SSRS报表执行期间的临时数据和工作表。
echo.
echo.
echo.
call :ColorText 04 "----------------数据无价，请确保数据安全的情况下进行----------------"
echo.
echo.
echo 备份文件存放路径:!backupPath!
echo 数据库文件存放路径:!dataPath!
echo.
choice /M "请确保数据安全的情况下进行："
if %errorlevel%==2 exit
cls
echo.
echo.
call :ColorText 0e "开始执行前，请先设置好参数"
echo.
echo.
choice /M "参数是否设置好了："
if %errorlevel%==2 exit


if "!dataPath!"=="def" (call :getnamepath)

if not exist "!backupPath!"  (call :ColorText 0e "备份文件目录不存在，请检查backupPath参数或拷贝备份文件后再执行"&pause&exit)
dir /s /b "!backupPath!\*.bak" >nul 2>&1

if %errorlevel%==1 (
   echo.
   echo 备份文件不存在，请拷贝备份文件后再执行
   echo.
pause&exit
)
if not exist "!dataPath!"  (call :ColorText 0e "数据库存放目录不存在，请检查dataPath参数或创建目录后再执行"&pause&exit)

rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------
rem -----------------------脚本运行参数请勿修改-----------------------
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
rem -----------------------脚本运行参数请勿修改-----------------------
rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------



call :ColorText 0e "--------------------读取到的备份文件如下：--------------------"
echo.
if exist "%temp%\lzdb" ( del %temp%\lzdb)
for /f "delims=." %%x in ('dir  /b !backupPath!\*.bak') do (

set /a bb+=1
echo !bb!、%%x
echo !bb!、%%x>>%temp%\lzdb
set allname=!allname!%%x,
rem echo !allname!
)
set /a bb+=1
call :ColorText 09 "!bb!、批量模式"
echo.

rem 用户输入----------------------------------------
set /p user_input=请选择要还原的数据库，多选输入如（1,2,3）：
rem 批量操作判断
echo !user_input! | find /i "!bb!">nul&&(
  call :c1
) || (
 call :dx
)
echo.
echo.
call :ColorText 04 "----------------所有数据库还原完毕----------------"
pause
if exist "~%dp0err.log" (start "" "%~dp0err.log")

exit

rem 遍历用户输入的选项----------------------------------------
:dx
for %%y in (!user_input!) do (
set /a cc=0
call :xx %%y
)
exit /B

rem 遍历匹配用户输入的选项----------------------------------------
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

rem 具体操作----sys------------------------------------
:sys
echo.
call :ColorText 04 "----------------开始还原系统数据库!dbname!----------------"

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
echo !dbname!----数据还原成功......................
echo.

) || (
echo.
call :ColorText 0c "!dbname!----数据还原失败......................"
echo.
echo.
echo 执行语句：sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q !sqltext!
echo.
echo 错误消息：
echo.
sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q !sqltext!
echo.
echo.
)

exit /B

rem 具体操作----user------------------------------------
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
echo !dbname!----数据还原成功......................
echo.

) || (
echo.
call :ColorText 0c "!dbname!----数据还原失败......................"
echo.
echo.
echo 执行语句：sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q !sqltext!
echo.
echo 错误消息：
echo.
sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q !sqltext!
echo.
echo.
call :ColorText 09 "----继续为!dbname!执行move1语句......................，重试"
echo.
echo.
call :move
)
exit /B


:c1
cls

echo.
call :ColorText 0c "择要执行的还原操作"
echo:
echo.
echo         	          	 1、还原所有系统数据库：!sysDB!
echo:
echo         	          	 2、还原所有用户数据库，除：!userDB!之外的
echo.
echo         	提示：1-9项不安装或全部禁用即为最小模式
echo.

echo.
set /p choice=         请选择要进行的操作，然后按回车: 
echo.
if /i "%choice%"=="1" call :ColorText 04 "----------------还原所有系统----------------"&&pause&&cls&&call :s1&exit /B
echo.
if /i "%choice%"=="2" call :ColorText 04 "----------------还原所有用户数据库-----除!userDB!之外的----------------"&&pause&&cls&&call :s2&exit /B
echo.
if /i "%choice%"=="3" call :ColorText 04 "----------------还原所有系统+用户数据库----------------"&&pause&&cls&&call :s2&exit /B
echo.
call :ColorText 4f "---------------------菜鸟，你选择的无效，请重新输入---------------------"&&pause&&cls
echo.
goto c1

rem 还原所有系统数据库-------------------------------------------------------------------------------------------------------------------------------
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
call :ColorText 0e "--------------------读取到的备份文件如下：--------------------"
echo.
type %temp%\lzdb
echo.
echo.
call :ColorText 0e "--------------------你选择将要还原的数据库如下：--------------------"
echo.
echo.
echo !user_input!
echo.
echo.
call :ColorText 0e "--------------------确认执行--------------------"
pause
call :dx
exit /B


rem 还原户数据库------------------------------------------------------------------------------------------------------------------------------
:s2
echo.
call :s1 uuu
exit /B

:master

echo 启动单用户模式......................  
echo.
NET stop MSSQLSERVER
echo.
echo.
NET START MSSQLSERVER /m
echo.
call :ColorText 0d "正在还原!dbname!"
echo.
	   sqlcmd  -I -Q  "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH replace;"
rem ,MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!'  TO '%dataPath%\!dbname!_log.ldf'
IF %ERRORLEVEL% NEQ 0 (
echo.
echo  还原!dbname!错误，请重试&pause&goto s0
echo.
)
exit /B

:notmaster
echo.
call :ColorText 05 "构建!dbname!还原语句......................"
echo.
	set result2=RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH  replace;

echo.
call :ColorText 0d "!dbname!----正在还原......................"
echo. 
echo.

:cs
net start | find  "SQL Server (MSSQLSERVER)" >nul&& echo 服务已启动 || NET START MSSQLSERVER&timeout 5 >nul
sqlcmd  -I -U %USERNAME% -P %PASSWORD% -Q  "%result2%"| findstr "MB" >nul&&(
echo.
echo !dbname!----数据还原成功......................
echo.

) || (
echo.
call :ColorText 0c "!dbname!----数据还原失败......................"
echo.
sqlcmd  -I -U %USERNAME% -P %PASSWORD% -Q  "%result2%"
echo.
echo  请重试&pause&goto cs
echo.
)

exit /B


:notmaster2
echo.
call :ColorText 05 "构建!dbname!语句......................"
echo.
pause
if "!dbname!"=="("  goto str
	set result2=!result2!RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH  replace;

exit /B
:str
set "result2=%result2:~0,-1%"
if "%result2%"=="~0,-1" (echo 未获取到数据，请重试&pause&NET stop MSSQLSERVER&goto s0)

echo "%result2%"
echo.
call :ColorText 0d "正在还原master以外的系统数据库......................"
echo. 
echo.
net start | find  "SQL Server (MSSQLSERVER)" >nul&& echo 服务已启动 || NET START MSSQLSERVER&timeout 5 >nul
echo.
echo.
sqlcmd  -I -U %USERNAME% -P %PASSWORD% -Q  "%result2%"
IF %ERRORLEVEL% NEQ 0 (
echo.
echo  还原错误，请重试&pause&goto str
echo.
)
exit /B




:ReportServer

echo.
call :ColorText 0d "正在还原!dbname!......................"
echo.
net start | find  "SQL Server (MSSQLSERVER)" >nul&& echo 服务已启动 || NET START MSSQLSERVER&timeout 5 >nul
     sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "ALTER DATABASE ReportServer SET OFFLINE WITH ROLLBACK IMMEDIATE;"

IF %ERRORLEVEL% NEQ 0 (
echo.
call :ColorText 0c "ROLLBACK IMMEDIATE失败......................请重试"
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
echo !dbname!----数据执行move语句还原成功......................
echo.

) || (call :replace)
exit /B


:replace
echo.
echo.
call :ColorText 09 "MOVE '!dbname!'错误=== 继续执行WITH REPLACE,MOVE===重试......................"
echo.
echo.
sqlcmd -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH REPLACE,MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!_log.ldf'"| findstr "MB" >nul&&(
echo.
echo !dbname!----数据执行WITH REPLACE,MOVE还原成功......................

) || (call :err)
exit /B


:err
echo.
echo.
echo 执行语句：move
echo 执行语句：sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH   MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!.ldf'"
echo.
sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH   MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!.ldf'"
echo.
echo.
echo.


echo.
echo 执行语句：WITH REPLACE,MOVE
echo 错误消息：
echo 执行语句：sqlcmd -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH REPLACE,MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!.ldf'"
echo.
echo 错误消息：
echo.
sqlcmd -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE DATABASE !dbname! FROM DISK = '%backupPath%\!dbname!.bak' WITH REPLACE,MOVE '!movename!' TO '%dataPath%\!dbname!.mdf',MOVE '!movelog!' TO '%dataPath%\!dbname!.ldf'"
echo.


call :ColorText 09 "!dbname!-----数据还原失败， WITH move OR WITH REPLACE,MOVE均无法还原......................"
echo !dbname!-----数据还原失败， WITH move OR WITH REPLACE,MOVE均无法还原..................... >"%~dp0err.log"
echo.
exit /B


:getname
set filelist=
net start | find  "SQL Server (MSSQLSERVER)" >nul&& echo. || NET START MSSQLSERVER&timeout 5 >nul
rem 使用 RESTORE FILELISTONLY 命令查看备份集中的数据库文件信息。运行以下命令
rem sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE FILELISTONLY FROM DISK = '%backupPath%\!dbname!.bak'" -h-1 -W
for /f "tokens=1-2" %%e in ('sqlcmd  -I -U %USERNAME% -P %PASSWORD%   -Q "RESTORE FILELISTONLY FROM DISK = '%backupPath%\!dbname!.bak'" -h-1 -W ^| findstr /v "("') do (
set filelist=!filelist!%%e+
)
rem 获取名称
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
