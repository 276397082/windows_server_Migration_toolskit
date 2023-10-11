@echo off
color 0a
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem "') do (
  set "DEL=%%a"
)

chcp 936
cls
set timestamp=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set url=https://download.microsoft.com/download/5/6/4/56418889-EAC9-4CE6-93C3-E0DA3D64A0D8/WebDeploy_amd64_zh-CN.msi
set output=%~dp0WebDeploy_amd64_zh-CN.msi
set bkpath=C:\IIS_Backup
set file="%bkpath%\%timestamp%_Package.zip"



if not exist "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" (

rem powershell -Command "(New-Object Net.WebClient).DownloadFile('%url%', '%output%')"


msiexec /i %output%  /qn /norestart

)

if not exist "%bkpath%" (mkdir "%bkpath%")

:c1
echo:
echo.
echo         	          	 1、备份IIS——含网站目录和文件
echo:
echo         	          	 2、还原IIS——含网站目录和文件
echo.
echo         	          	 3、备份IIS——不含网站目录和文件
echo:
echo         	          	 4、还原IIS——不含网站目录和文件
echo.
echo         	提示：1-9项不安装或全部禁用即为最小模式
echo.

echo.
set /p choice=         请选择要进行的操作，然后按回车: 
echo.
if /i "%choice%"=="1" call :ColorText 04 "----------------备份IIS——含网站目录和文件----------------"&&pause&&cls&&call :s1&exit /B
echo.
if /i "%choice%"=="2" call :ColorText 04 "----------------还原IIS——含网站目录和文件----------------"&&pause&&cls&&call :s2&exit /B
echo.
if /i "%choice%"=="3" call :ColorText 04 "----------------备份IIS——不含网站目录和文件----------------"&&pause&&cls&&call :s3&exit /B
echo.
if /i "%choice%"=="4" call :ColorText 04 "----------------还原IIS——不含网站目录和文件----------------"&&pause&&cls&&call :s4&exit /B

echo.
call :ColorText 4f "---------------------菜鸟，你选择的无效，请重新输入---------------------"&&pause&&cls
echo.
goto c1

:s1

"C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync  -source:webServer -dest:package=%file%

call :ColorText 04 "----------------备份完成，请查看是否有报错----------------"&&pause
exit /B
:s3

"C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync  -source:webServer -dest:package=%file% -skip:Directory=".*"

call :ColorText 04 "----------------备份完成，请查看是否有报错----------------"&&pause
exit /B


:s2
dir /s /b "%bkpath%\*Package.zip" >nul 2>&1

if %errorlevel%==1 (
   echo.
   echo 备份文件不存在，请拷贝备份文件后再执行
   echo.
pause&exit
)

"C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync -source:package=%file% -dest:auto
call :ColorText 04 "----------------还原完成，请查看是否有报错----------------"&&pause
exit /B

:s4
dir /s /b "%bkpath%\*Package.zip" >nul 2>&1

if %errorlevel%==1 (
   echo.
   echo 备份文件不存在，请拷贝备份文件后再执行
   echo.
pause&exit
)

"C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync -source:package=%file% -dest:auto
call :ColorText 04 "----------------还原完成，请查看是否有报错----------------"&&pause
exit /B




goto :eof

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof
