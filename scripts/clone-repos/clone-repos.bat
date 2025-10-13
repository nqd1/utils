@echo off
REM clone multiple repositories from urls file

setlocal enabledelayedexpansion

set "URL_FILE=urls.txt"
set "DEST_DIR=.\repos"
set "BRANCH="
set "SHALLOW=false"

REM parse arguments
:parse_args
if "%~1"=="" goto :start
if "%~1"=="-f" set "URL_FILE=%~2" & shift & shift & goto :parse_args
if "%~1"=="-d" set "DEST_DIR=%~2" & shift & shift & goto :parse_args
if "%~1"=="-b" set "BRANCH=%~2" & shift & shift & goto :parse_args
if "%~1"=="-s" set "SHALLOW=true" & shift & goto :parse_args
if "%~1"=="-h" goto :show_usage
shift
goto :parse_args

:start
echo clone multiple repositories

REM check urls file
if not exist "%URL_FILE%" (
    echo file not found: %URL_FILE%
    echo creating sample urls.txt...
    (
        echo # add git repository URLs here ^(one per line^)
        echo # examples:
        echo # https://github.com/user/repo1.git
        echo # https://github.com/user/repo2.git
        echo # git@github.com:user/repo3.git
    ) > urls.txt
    echo created sample urls.txt, please add URLs and run again
    exit /b 0
)

REM create destination directory
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"

echo source: %URL_FILE%
echo destination: %DEST_DIR%
echo.

set count=0
set success=0
set failed=0

REM clone each repository
for /f "usebackq tokens=* delims=" %%u in ("%URL_FILE%") do (
    set "url=%%u"
    
    REM skip empty lines and comments
    if not "!url!"=="" (
        echo !url! | findstr /r "^#" >nul
        if errorlevel 1 (
            set /a count+=1
            
            REM get repo name
            for %%a in ("!url!") do set "repo_name=%%~na"
            set "clone_path=%DEST_DIR%\!repo_name!"
            
            if exist "!clone_path!" (
                echo !repo_name! already exists, pulling updates...
                cd "!clone_path!"
                git pull
                cd ..\..
            ) else (
                echo cloning !repo_name!...
                
                set "clone_cmd=git clone"
                
                if "%SHALLOW%"=="true" (
                    set "clone_cmd=!clone_cmd! --depth 1"
                )
                
                if not "%BRANCH%"=="" (
                    set "clone_cmd=!clone_cmd! -b %BRANCH%"
                )
                
                !clone_cmd! "!url!" "!clone_path!"
                
                if !errorlevel! equ 0 (
                    echo cloned !repo_name!
                    set /a success+=1
                ) else (
                    echo failed to clone !repo_name!
                    set /a failed+=1
                )
            )
        )
    )
)

echo.
echo done
echo total: %count% repositories
echo success: %success%
if %failed% gtr 0 (
    echo failed: %failed%
)
goto :eof

:show_usage
echo clone multiple repositories
echo.
echo usage: %~nx0 [options]
echo.
echo options:
echo   -f FILE       file with URLs list ^(default: urls.txt^)
echo   -d DIR        destination directory ^(default: .\repos^)
echo   -b BRANCH     branch to checkout ^(default: main/master^)
echo   -s            shallow clone ^(latest commit only^)
echo.
echo urls file format ^(one URL per line^):
echo   https://github.com/user/repo1.git
echo   https://github.com/user/repo2.git
echo.
echo examples:
echo   %~nx0 -f repos.txt -d .\projects
echo   %~nx0 -f urls.txt -s
exit /b 0
