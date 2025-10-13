@echo off
REM cleanup temp/cache files

setlocal enabledelayedexpansion

set "DIRECTORY=."
set "TYPE=all"
set "RECURSIVE=false"
set "PREVIEW=false"

REM parse arguments
:parse_args
if "%~1"=="" goto :start
if "%~1"=="-d" set "DIRECTORY=%~2" & shift & shift & goto :parse_args
if "%~1"=="-t" set "TYPE=%~2" & shift & shift & goto :parse_args
if "%~1"=="-r" set "RECURSIVE=true" & shift & goto :parse_args
if "%~1"=="-p" set "PREVIEW=true" & shift & goto :parse_args
if "%~1"=="-h" goto :show_usage
shift
goto :parse_args

:start
if not exist "%DIRECTORY%" (
    echo directory not found: %DIRECTORY%
    exit /b 1
)

echo cleanup script
echo directory: %DIRECTORY%
echo type: %TYPE%
if "%PREVIEW%"=="true" echo mode: preview only
echo.

echo scanning for cleanup items...
echo.

set count=0

REM nodejs cleanup
if "%TYPE%"=="node" goto :cleanup_node
if "%TYPE%"=="all" goto :cleanup_node
goto :skip_node

:cleanup_node
if "%RECURSIVE%"=="true" (
    for /d /r "%DIRECTORY%" %%d in (node_modules .npm) do (
        if exist "%%d" (
            echo   %%d
            if not "%PREVIEW%"=="true" (
                rd /s /q "%%d" 2>nul
                set /a count+=1
            )
        )
    )
    for /r "%DIRECTORY%" %%f in (package-lock.json yarn.lock pnpm-lock.yaml) do (
        if exist "%%f" (
            echo   %%f
            if not "%PREVIEW%"=="true" (
                del /f /q "%%f" 2>nul
                set /a count+=1
            )
        )
    )
) else (
    if exist "%DIRECTORY%\node_modules" (
        echo   %DIRECTORY%\node_modules
        if not "%PREVIEW%"=="true" (
            rd /s /q "%DIRECTORY%\node_modules" 2>nul
            set /a count+=1
        )
    )
)
if "%TYPE%"=="node" goto :cleanup_done

:skip_node

REM python cleanup
if "%TYPE%"=="python" goto :cleanup_python
if "%TYPE%"=="all" goto :cleanup_python
goto :skip_python

:cleanup_python
if "%RECURSIVE%"=="true" (
    for /d /r "%DIRECTORY%" %%d in (__pycache__ .pytest_cache .mypy_cache) do (
        if exist "%%d" (
            echo   %%d
            if not "%PREVIEW%"=="true" (
                rd /s /q "%%d" 2>nul
                set /a count+=1
            )
        )
    )
    for /r "%DIRECTORY%" %%f in (*.pyc *.pyo *.pyd) do (
        if exist "%%f" (
            echo   %%f
            if not "%PREVIEW%"=="true" (
                del /f /q "%%f" 2>nul
                set /a count+=1
            )
        )
    )
) else (
    if exist "%DIRECTORY%\__pycache__" (
        echo   %DIRECTORY%\__pycache__
        if not "%PREVIEW%"=="true" (
            rd /s /q "%DIRECTORY%\__pycache__" 2>nul
            set /a count+=1
        )
    )
)
if "%TYPE%"=="python" goto :cleanup_done

:skip_python

REM build cleanup
if "%TYPE%"=="build" goto :cleanup_build
if "%TYPE%"=="all" goto :cleanup_build
goto :skip_build

:cleanup_build
for %%d in (dist build out .next target) do (
    if exist "%DIRECTORY%\%%d" (
        echo   %DIRECTORY%\%%d
        if not "%PREVIEW%"=="true" (
            rd /s /q "%DIRECTORY%\%%d" 2>nul
            set /a count+=1
        )
    )
)
if "%TYPE%"=="build" goto :cleanup_done

:skip_build

REM temp cleanup
if "%TYPE%"=="temp" goto :cleanup_temp
if "%TYPE%"=="all" goto :cleanup_temp
goto :skip_temp

:cleanup_temp
for /r "%DIRECTORY%" %%f in (*.tmp *.temp *.log .DS_Store Thumbs.db) do (
    if exist "%%f" (
        echo   %%f
        if not "%PREVIEW%"=="true" (
            del /f /q "%%f" 2>nul
            set /a count+=1
        )
    )
)

:skip_temp

:cleanup_done
echo.
if "%PREVIEW%"=="true" (
    echo preview completed, found items to clean
    echo run without -p flag to actually delete
) else (
    echo cleaned up %count% items
)
goto :eof

:show_usage
echo cleanup temp/cache files
echo.
echo usage: %~nx0 [options]
echo.
echo options:
echo   -d DIR        directory to clean ^(default: current directory^)
echo   -t TYPE       cleanup type: all, node, python, build, temp
echo   -r            recursive ^(apply to all subdirectories^)
echo   -p            preview only ^(don't delete, just show^)
echo.
echo examples:
echo   %~nx0 -t node -r
echo   %~nx0 -d .\project -t python -r
echo   %~nx0 -t temp -p
exit /b 0
