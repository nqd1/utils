@echo off
REM auto commit and push with custom date
REM note: for educational/testing purposes only

setlocal enabledelayedexpansion

set "MESSAGE=auto commit"
set "CUSTOM_DATE="
set "PUSH=false"
set "BRANCH="

REM parse arguments
:parse_args
if "%~1"=="" goto :start
if "%~1"=="-m" set "MESSAGE=%~2" & shift & shift & goto :parse_args
if "%~1"=="-d" set "CUSTOM_DATE=%~2" & shift & shift & goto :parse_args
if "%~1"=="-p" set "PUSH=true" & shift & goto :parse_args
if "%~1"=="-b" set "BRANCH=%~2" & shift & shift & goto :parse_args
if "%~1"=="-h" goto :show_usage
shift
goto :parse_args

:start
echo auto commit script

REM check git repo
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    echo not a git repository
    exit /b 1
)

REM stage changes
echo staging changes...
git add -A

REM check for changes
git diff --cached --quiet
if %errorlevel% equ 0 (
    echo no changes to commit
    exit /b 0
)

REM commit
if not "%CUSTOM_DATE%"=="" (
    echo committing with custom date: %CUSTOM_DATE%
    set "GIT_AUTHOR_DATE=%CUSTOM_DATE%"
    set "GIT_COMMITTER_DATE=%CUSTOM_DATE%"
    git commit -m "%MESSAGE%"
) else (
    echo committing with current date...
    git commit -m "%MESSAGE%"
)

if %errorlevel% equ 0 (
    echo commit successful
    
    REM push if requested
    if "%PUSH%"=="true" (
        if "%BRANCH%"=="" (
            for /f "tokens=*" %%b in ('git rev-parse --abbrev-ref HEAD') do set "BRANCH=%%b"
        )
        
        echo pushing to !BRANCH!...
        git push origin !BRANCH!
        
        if !errorlevel! equ 0 (
            echo push successful
        ) else (
            echo push failed
            exit /b 1
        )
    )
) else (
    echo commit failed
    exit /b 1
)

echo done
goto :eof

:show_usage
echo auto commit with custom date
echo.
echo usage: %~nx0 [options]
echo.
echo options:
echo   -m MESSAGE    commit message ^(default: 'auto commit'^)
echo   -d DATE       date for commit ^(format: 'YYYY-MM-DD HH:MM:SS'^)
echo   -p            push after commit
echo   -b BRANCH     branch to push ^(default: current branch^)
echo.
echo examples:
echo   %~nx0 -m "feature update" -d "2024-01-15 10:30:00" -p
exit /b 0
