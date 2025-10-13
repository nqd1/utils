@echo off
REM backup files and folders with timestamp

setlocal enabledelayedexpansion

set "SOURCE="
set "DEST=.\backups"
set "COMPRESS=false"
set "CUSTOM_NAME="

REM parse arguments
:parse_args
if "%~1"=="" goto :check_params
if "%~1"=="-s" set "SOURCE=%~2" & shift & shift & goto :parse_args
if "%~1"=="-d" set "DEST=%~2" & shift & shift & goto :parse_args
if "%~1"=="-z" set "COMPRESS=true" & shift & goto :parse_args
if "%~1"=="-n" set "CUSTOM_NAME=%~2" & shift & shift & goto :parse_args
if "%~1"=="-h" goto :show_usage
shift
goto :parse_args

:check_params
if "%SOURCE%"=="" (
    echo please specify source ^(-s^)
    goto :show_usage
)

if not exist "%SOURCE%" (
    echo source not found: %SOURCE%
    exit /b 1
)

REM create backup directory
if not exist "%DEST%" mkdir "%DEST%"

REM create timestamp
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set TIMESTAMP=%datetime:~0,8%_%datetime:~8,6%

REM backup name
if "%CUSTOM_NAME%"=="" (
    for %%F in ("%SOURCE%") do set "BASENAME=%%~nxF"
) else (
    set "BASENAME=%CUSTOM_NAME%"
)

echo backup script
echo source: %SOURCE%
echo destination: %DEST%
echo.

if "%COMPRESS%"=="true" (
    REM backup and compress (requires powershell)
    set "BACKUP_FILE=%DEST%\%BASENAME%_%TIMESTAMP%.zip"
    echo creating compressed backup: !BACKUP_FILE!
    
    powershell -command "Compress-Archive -Path '%SOURCE%' -DestinationPath '!BACKUP_FILE!' -Force"
    
    if !errorlevel! equ 0 (
        echo backup created successfully
    ) else (
        echo backup failed
        exit /b 1
    )
) else (
    REM backup without compression
    set "BACKUP_DIR=%DEST%\%BASENAME%_%TIMESTAMP%"
    echo creating backup: !BACKUP_DIR!
    
    xcopy "%SOURCE%" "!BACKUP_DIR!\" /E /I /H /Y >nul
    
    if !errorlevel! equ 0 (
        echo backup created successfully
    ) else (
        echo backup failed
        exit /b 1
    )
)

echo done
goto :eof

:show_usage
echo backup files/folders
echo.
echo usage: %~nx0 [options]
echo.
echo options:
echo   -s SOURCE     source directory/file to backup
echo   -d DEST       destination directory for backups ^(default: .\backups^)
echo   -z            compress backup as .zip
echo   -n NAME       custom name for backup ^(default: source name^)
echo.
echo examples:
echo   %~nx0 -s .\project -d .\backups -z
echo   %~nx0 -s .\data -z
exit /b 0
