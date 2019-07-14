@echo off

:get_arch
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
    set ARCH=x64
    set PLATFORM=x64
) else (
    set ARCH=x86
    set PLATFORM=Win32
)

:ARGS_LOOP
if (%1) == () (
    echo Automactlly building release
    set _LAST_BUILD_CONF=Release
    set Building=rel
)
if (%1) == (dbg) (
    echo Manually building debug
    set _LAST_BUILD_CONF=Debug
    set Building=dbg
)
if (%1) == (rel) (
    echo Manually building release
    set _LAST_BUILD_CONF=Release
    set Building=rel
)
shift

:updateGit
cd "C:\"

rem check if terminal exist and update it
IF EXIST terminal\.git (
cd terminal
git pull
) ELSE (
    IF EXIST terminal (
    rmdir /s terminal
    )
git clone https://github.com/microsoft/terminal.git
cd terminal
)

:Update_git_sub
rem updating git submodule
git submodule update --init --recursive

echo.
echo Open OpenConsole.sln with VS2019, Install the following workloads which VS prompt you to install it before you continue.
echo If you already did this, Skip it!
echo ...and continue will kill Windows Terminal.
pause

taskkill /F /IM WindowsTerminal.exe
@echo on
call .\tools\razzle.cmd %Building%
call .\tools\bcz.cmd %Building%
@echo off

cls
:choice_shortcut
set /P c=Do you want to make a shortcut on desktop[Y/N]?
if /I "%c%" EQU "Y" goto :short
if /I "%c%" EQU "N" goto :pass_short
echo ooops! Please choose between Y or N
goto :choice_shortcut

:short
rem C:\terminal\src\cascadia\CascadiaPackage\bin\x64\Release\WindowsTerminal.exe
@echo off
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
if "%Building%" == "rel" (
echo sLinkFile = "%HOMEDRIVE%%HOMEPATH%\Desktop\Terminal.lnk" >> CreateShortcut.vbs
) else if "%Building%" == "dbg" (
echo sLinkFile = "%HOMEDRIVE%%HOMEPATH%\Desktop\Terminal-Debug.lnk" >> CreateShortcut.vbs
)
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "C:\terminal\src\cascadia\CascadiaPackage\bin\%ARCH%\%_LAST_BUILD_CONF%\WindowsTerminal.exe" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del CreateShortcut.vbs
set shortcut_exist=yes
goto :end


:pass_short
echo passing Making Shrotcut
set shortcut_exist=no

:end
cls
echo Done!
IF "%shortcut_exist%" == "yes" (
    echo You can run Terminal by desktop shortcut
    echo ... or ...
    echo "C:\terminal\src\cascadia\CascadiaPackage\bin\%ARCH%\%_LAST_BUILD_CONF%\WindowsTerminal.exe"
) ELSE IF "%shortcut_exist%" == "no" (
    echo You can run Terminal at "C:\terminal\src\cascadia\CascadiaPackage\bin\%ARCH%\%_LAST_BUILD_CONF%\WindowsTerminal.exe"
)

pause
