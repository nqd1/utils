@echo off
REM search and replace text in files

setlocal enabledelayedexpansion

set "SEARCH="
set "REPLACE="
set "DIRECTORY=."
set "EXTENSION="
set "PREVIEW=false"
set "BACKUP=false"

REM parse arguments
:parse_args
if "%~1"=="" goto :check_params
if "%~1"=="-s" set "SEARCH=%~2" & shift & shift & goto :parse_args
if "%~1"=="-r" set "REPLACE=%~2" & shift & shift & goto :parse_args
if "%~1"=="-d" set "DIRECTORY=%~2" & shift & shift & goto :parse_args
if "%~1"=="-e" set "EXTENSION=%~2" & shift & shift & goto :parse_args
if "%~1"=="-p" set "PREVIEW=true" & shift & goto :parse_args
if "%~1"=="-b" set "BACKUP=true" & shift & goto :parse_args
if "%~1"=="-h" goto :show_usage
shift
goto :parse_args

:check_params
if "%SEARCH%"=="" (
    echo please specify search text ^(-s^)
    goto :show_usage
)

if not exist "%DIRECTORY%" (
    echo directory not found: %DIRECTORY%
    exit /b 1
)

echo search ^& replace script
echo directory: %DIRECTORY%
echo search: '%SEARCH%'
if not "%REPLACE%"=="" echo replace: '%REPLACE%'
if not "%EXTENSION%"=="" echo extension: %EXTENSION%
if "%PREVIEW%"=="true" echo mode: preview only
echo.

echo searching for '%SEARCH%'...
echo.

set count=0
set total_files=0

REM search in files
if "%EXTENSION%"=="" (
    set "FILE_PATTERN=*.*"
) else (
    set "FILE_PATTERN=*%EXTENSION%"
)

for /r "%DIRECTORY%" %%f in (%FILE_PATTERN%) do (
    findstr /N /C:"%SEARCH%" "%%f" >nul 2>&1
    if !errorlevel! equ 0 (
        set /a total_files+=1
        echo %%f
        
        REM show preview
        findstr /N /C:"%SEARCH%" "%%f" 2>nul | findstr /N "^" | findstr "^[1-5]:"
        echo.
    )
)

if %total_files% equ 0 (
    echo no matches found
    exit /b 0
)

echo.
echo found matches in %total_files% file^(s^)

REM replace if not preview
if not "%REPLACE%"=="" (
    if not "%PREVIEW%"=="true" (
        echo.
        set /p "confirm=replace all occurrences? (y/n): "
        
        if /i "!confirm!"=="y" (
            echo.
            echo replacing...
            
            set replaced=0
            
            for /r "%DIRECTORY%" %%f in (%FILE_PATTERN%) do (
                findstr /N /C:"%SEARCH%" "%%f" >nul 2>&1
                if !errorlevel! equ 0 (
                    REM backup if requested
                    if "%BACKUP%"=="true" (
                        copy "%%f" "%%f.bak" >nul 2>&1
                    )
                    
                    REM replace using powershell
                    powershell -command "(Get-Content '%%f') -replace '%SEARCH%', '%REPLACE%' | Set-Content '%%f'"
                    
                    if !errorlevel! equ 0 (
                        echo   %%f
                        set /a replaced+=1
                    ) else (
                        echo   failed: %%f
                    )
                )
            )
            
            echo.
            echo replaced in !replaced! file^(s^)
            
            if "%BACKUP%"=="true" (
                echo backup files created with .bak extension
            )
        ) else (
            echo cancelled
        )
    )
)

if "%PREVIEW%"=="true" (
    echo preview mode - no changes made
)

goto :eof

:show_usage
echo search and replace text in files
echo.
echo usage: %~nx0 [options]
echo.
echo options:
echo   -s SEARCH     text/pattern to search ^(required^)
echo   -r REPLACE    replacement text
echo   -d DIR        search directory ^(default: current directory^)
echo   -e EXT        file extension ^(e.g. .txt, .js^)
echo   -p            preview only ^(don't replace^)
echo   -b            backup files before replacing
echo.
echo examples:
echo   %~nx0 -s "old_function" -r "new_function" -e .js
echo   %~nx0 -s "TODO" -d .\src -p
echo   %~nx0 -s "console.log" -r "// console.log" -e .js -b
exit /b 0
