@::!/dos/rocks
@echo off
goto :init


rem https://stackoverflow.com/a/45070967
:header
    echo Windows Terminal Auto Builder
    echo.
    goto :eof

:usage
    echo USAGE:
    echo   %__BAT_NAME% [flags] "required argument" "optional argument" 
    echo.
    echo.  /?, --help           shows this help
    echo.  /v, --version        shows the version
    echo.  --dir value          specifies a directory to install
    echo.  /t, -t, --type       Value can be R to Release, D to Debug
    goto :eof

:version
    if "%~1"=="full" call :header & goto :eof
    echo %__VERSION%
    goto :eof

:missing_argument
    call :header
    call :usage
    echo.
    echo ****                                   ****
    echo ****    MISSING "REQUIRED ARGUMENT"    ****
    echo ****                                   ****
    echo.
    goto :eof

:set_debug

    echo Manually building debug
    set _LAST_BUILD_CONF=Debug
    set Building=dbg
    goto :parse

:set_release
    echo Building Release
    set _LAST_BUILD_CONF=Release
    set Building=rel
    goto :parse

:init
    set "__NAME=%~n0"
    set "__VERSION=20190715"
    set "__YEAR=2019"

    set "__BAT_FILE=%~0"
    set "__BAT_PATH=%~dp0"
    set "__BAT_NAME=%~nx0"

    set "OptHelp="
    set "OptVersion="
    set "OptVerbose="

    set "UnNamedArgument="
    set "UnNamedOptionalArg="
    set "NamedFlag="
    
    set "Directory_to_inst="
    rem set "Inst_Type="

:parse
    if "%~1"=="" goto :validate

    if /i "%~1"=="/?"         call :header & call :usage "%~2" & goto :end
    if /i "%~1"=="-?"         call :header & call :usage "%~2" & goto :end
    if /i "%~1"=="--help"     call :header & call :usage "%~2" & goto :end

    if /i "%~1"=="/v"         call :version      & goto :end
    if /i "%~1"=="-v"         call :version      & goto :end
    if /i "%~1"=="--version"  call :version full & goto :end

    
    
    if /i "%~1"=="--dir"     set "Directory_to_inst=%~2"   & shift & shift & goto :parse
    
    if /i "%~1"=="/D"        set "Inst_Type=D" & call :set_debug & shift & shift & call :set_debug & goto :parse
    if /i "%~1"=="/R"        set "Inst_Type=R" & call :set_release & shift & shift & call :set_debug & goto :parse
    
    if not defined Inst_Type           set "Inst_Type=R"             & call :set_release & shift & goto :parse
    if not defined UnNamedArgument     set "UnNamedArgument=%~1"     & shift & goto :parse
    if not defined UnNamedOptionalArg  set "UnNamedOptionalArg=%~1"  & shift & goto :parse

    shift
    goto :parse

:validate
    rem if not defined UnNamedArgument call :missing_argument & goto :end

:main

    if defined Directory_to_inst               echo Directory to install:          %Directory_to_inst%\terminal
    if not defined Directory_to_inst (
        set Directory_to_inst="C:\"
        echo Directory_to_install:          C:\terminal
    )           
    rem Directory to install : %Directory_to_inst%
    

:get_arch
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
    set ARCH=x64
    set PLATFORM=x64
) else (
    set ARCH=x86
    set PLATFORM=Win32
)

:updateGit
cd %Directory_to_inst%

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
pause

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

echo Done!
IF "%shortcut_exist%" == "yes" (
    echo You can run Terminal by desktop shortcut
    echo ... or ...
    echo "%_root_path_terminal%\src\cascadia\CascadiaPackage\bin\%ARCH%\%_LAST_BUILD_CONF%\WindowsTerminal.exe"
) ELSE IF "%shortcut_exist%" == "no" (
    echo You can run Terminal at "%_root_path_terminal%\src\cascadia\CascadiaPackage\bin\%ARCH%\%_LAST_BUILD_CONF%\WindowsTerminal.exe"
)

:exit
echo.
echo.
echo press any key to exit
pause >nul
call :cleanup
exit /B

:cleanup
    REM The cleanup function is only really necessary if you
    REM are _not_ using SETLOCAL.
    set "__NAME="
    set "__VERSION="
    set "__YEAR="

    set "__BAT_FILE="
    set "__BAT_PATH="
    set "__BAT_NAME="

    set "OptHelp="
    set "OptVersion="
    set "OptVerbose="

    set "UnNamedArgument="
    set "UnNamedArgument2="
    set "NamedFlag="
    
    set "Directory_to_inst="
    set "Inst_Type="

    goto :eof
