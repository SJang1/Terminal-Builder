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
    echo.  /D                   Build as Debug 
    echo.  /R                   Build as Release
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
    set Inst_Type=D
    goto :parse

:set_release
    echo Building Release
    set _LAST_BUILD_CONF=Release
    set Building=rel
    set Inst_Type=R
    goto :parse

:init
    set "__NAME=%~n0"
    set "__VERSION=20190718"
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
    set "Git_to_clone=https://github.com/microsoft/terminal.git"
    set "Inst_Type="

:parse
    if "%~1"=="" goto :validate

    if /i "%~1"=="/?"         call :header & call :usage "%~2" & goto :end
    if /i "%~1"=="-?"         call :header & call :usage "%~2" & goto :end
    if /i "%~1"=="--help"     call :header & call :usage "%~2" & goto :end

    if /i "%~1"=="/v"         call :version      & goto :end
    if /i "%~1"=="-v"         call :version      & goto :end
    if /i "%~1"=="--version"  call :version      & goto :end

    
    if /i "%~1"=="--dir"     set "Directory_to_inst=%~2"   & shift & shift & goto :parse

    if /i "%~1"=="--git"     set "Git_to_clone=%~2"   & shift & shift & goto :parse
    
    if /i "%~1"=="/D"        call :set_debug   & shift & shift & goto :parse
    if /i "%~1"=="/R"        call :set_release & shift & shift & goto :parse
    
    

    if not defined UnNamedArgument     set "UnNamedArgument=%~1"     & shift & goto :parse
    if not defined UnNamedOptionalArg  set "UnNamedOptionalArg=%~1"  & shift & goto :parse

    shift
    goto :parse

:validate
    rem if not defined UnNamedArgument call :missing_argument & goto :end

:main
    rem if no install type definded set to release
    if /i "%Inst_Type%"==""    call :set_release & shift & shift & goto :parse
    
    if defined Directory_to_inst (
        echo Directory to install: %Directory_to_inst%\terminal
    )
    if not defined Directory_to_inst (
        set Directory_to_inst="C:\"
        echo Directory_to_install:          C:\terminal
    ) 
    echo git to clone: %Git_to_clone%
    if /i "%Git_to_clone%"=="https://github.com/microsoft/terminal.git" (
        rem No-Problem
    ) else (
        echo.
        echo git name MUST BE terminal to use this script.
    )
    echo.
    pause
    rem Directory to install : %Directory_to_inst%
    
shift


:get_arch
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
    set ARCH=x64
    set PLATFORM=x64
) else (
    set ARCH=x86
    set PLATFORM=Win32
)

:makePath
rem make path if not exist
IF NOT EXIST %Directory_to_inst% (
    mkdir %Directory_to_inst%
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
git clone %Git_to_clone%
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

:set_root_path_of_terminal
cd %Directory_to_inst%
cd terminal
set _terminal_ROOT_PATH_Source=%cd%
rem %_terminal_ROOT_PATH_Source% is a terminal source root path
echo %_terminal_ROOT_PATH_Source%


cls
:choice_shortcut
set /P c=Do you want to make a shortcut on desktop[Y/N]?
if /I "%c%" EQU "Y" goto :short
if /I "%c%" EQU "N" goto :pass_short
echo ooops! Please choose between Y or N
goto :choice_shortcut

:short
rem %_terminal_ROOT_PATH_Source%\src\cascadia\CascadiaPackage\bin\x64\Release\WindowsTerminal.exe
@echo off
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
if "%Building%" == "rel" (
echo sLinkFile = "%HOMEDRIVE%%HOMEPATH%\Desktop\Terminal.lnk" >> CreateShortcut.vbs
) else if "%Building%" == "dbg" (
echo sLinkFile = "%HOMEDRIVE%%HOMEPATH%\Desktop\Terminal-Debug.lnk" >> CreateShortcut.vbs
)
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%_terminal_ROOT_PATH_Source%\src\cascadia\CascadiaPackage\bin\%ARCH%\%_LAST_BUILD_CONF%\WindowsTerminal.exe" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del CreateShortcut.vbs
set shortcut_exist=yes
goto :end


:pass_short
echo passing Making Shrotcut
set shortcut_exist=no
goto :end

:end
cls
echo Done!
IF "%shortcut_exist%" == "yes" (
    echo You can run Terminal by desktop shortcut
    echo ... or ...
    echo "%_terminal_ROOT_PATH_Source%\src\cascadia\CascadiaPackage\bin\%ARCH%\%_LAST_BUILD_CONF%\WindowsTerminal.exe"
) ELSE IF "%shortcut_exist%" == "no" (
    echo You can run Terminal at "%_terminal_ROOT_PATH_Source%\src\cascadia\CascadiaPackage\bin\%ARCH%\%_LAST_BUILD_CONF%\WindowsTerminal.exe"
)

:exit
echo.
echo.
echo press any key to exit
pause >nul
exit
