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
echo         	          	 1������IIS��������վĿ¼���ļ�
echo:
echo         	          	 2����ԭIIS��������վĿ¼���ļ�
echo.
echo         	          	 3������IIS����������վĿ¼���ļ�
echo:
echo         	          	 4����ԭIIS����������վĿ¼���ļ�
echo.
echo         	��ʾ��1-9���װ��ȫ�����ü�Ϊ��Сģʽ
echo.

echo.
set /p choice=         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�: 
echo.
if /i "%choice%"=="1" call :ColorText 04 "----------------����IIS��������վĿ¼���ļ�----------------"&&pause&&cls&&call :s1&exit /B
echo.
if /i "%choice%"=="2" call :ColorText 04 "----------------��ԭIIS��������վĿ¼���ļ�----------------"&&pause&&cls&&call :s2&exit /B
echo.
if /i "%choice%"=="3" call :ColorText 04 "----------------����IIS����������վĿ¼���ļ�----------------"&&pause&&cls&&call :s3&exit /B
echo.
if /i "%choice%"=="4" call :ColorText 04 "----------------��ԭIIS����������վĿ¼���ļ�----------------"&&pause&&cls&&call :s4&exit /B

echo.
call :ColorText 4f "---------------------������ѡ�����Ч������������---------------------"&&pause&&cls
echo.
goto c1

:s1

"C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync  -source:webServer -dest:package=%file%

call :ColorText 04 "----------------������ɣ���鿴�Ƿ��б���----------------"&&pause
exit /B
:s3

"C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync  -source:webServer -dest:package=%file% -skip:Directory=".*"

call :ColorText 04 "----------------������ɣ���鿴�Ƿ��б���----------------"&&pause
exit /B


:s2
dir /s /b "%bkpath%\*Package.zip" >nul 2>&1

if %errorlevel%==1 (
   echo.
   echo �����ļ������ڣ��뿽�������ļ�����ִ��
   echo.
pause&exit
)

"C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync -source:package=%file% -dest:auto
call :ColorText 04 "----------------��ԭ��ɣ���鿴�Ƿ��б���----------------"&&pause
exit /B

:s4
dir /s /b "%bkpath%\*Package.zip" >nul 2>&1

if %errorlevel%==1 (
   echo.
   echo �����ļ������ڣ��뿽�������ļ�����ִ��
   echo.
pause&exit
)

"C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync -source:package=%file% -dest:auto
call :ColorText 04 "----------------��ԭ��ɣ���鿴�Ƿ��б���----------------"&&pause
exit /B




goto :eof

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof
