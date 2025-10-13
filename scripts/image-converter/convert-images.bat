@echo off
REM batch convert images (requires imagemagick)

setlocal enabledelayedexpansion

set "SOURCE=.\images"
set "DEST=.\converted"
set "FORMAT="
set "QUALITY=85"
set "RESIZE="

REM parse arguments
:parse_args
if "%~1"=="" goto :check_params
if "%~1"=="-s" set "SOURCE=%~2" & shift & shift & goto :parse_args
if "%~1"=="-d" set "DEST=%~2" & shift & shift & goto :parse_args
if "%~1"=="-f" set "FORMAT=%~2" & shift & shift & goto :parse_args
if "%~1"=="-q" set "QUALITY=%~2" & shift & shift & goto :parse_args
if "%~1"=="-r" set "RESIZE=%~2" & shift & shift & goto :parse_args
if "%~1"=="-h" goto :show_usage
shift
goto :parse_args

:check_params
REM check imagemagick
where magick >nul 2>&1
if errorlevel 1 (
    where convert >nul 2>&1
    if errorlevel 1 (
        echo imagemagick not installed
        echo download: https://imagemagick.org/script/download.php
        exit /b 1
    )
    set "CONVERT_CMD=convert"
) else (
    set "CONVERT_CMD=magick convert"
)

if "%FORMAT%"=="" (
    echo please specify target format ^(-f^)
    goto :show_usage
)

if not exist "%SOURCE%" (
    echo source directory not found: %SOURCE%
    exit /b 1
)

REM create destination directory
if not exist "%DEST%" mkdir "%DEST%"

echo image batch converter
echo source: %SOURCE%
echo destination: %DEST%
echo format: %FORMAT%
echo quality: %QUALITY%
if not "%RESIZE%"=="" echo resize: %RESIZE%
echo.

set count=0
set success=0
set failed=0

REM convert images
for %%e in (jpg jpeg png gif bmp webp tiff) do (
    for %%f in ("%SOURCE%\*.%%e") do (
        set /a count+=1
        set "filename=%%~nf"
        set "output=%DEST%\!filename!.%FORMAT%"
        
        echo converting: %%~nxf
        
        if "%RESIZE%"=="" (
            %CONVERT_CMD% "%%f" -quality %QUALITY% "!output!" >nul 2>&1
        ) else (
            %CONVERT_CMD% "%%f" -resize "%RESIZE%^>" -quality %QUALITY% "!output!" >nul 2>&1
        )
        
        if !errorlevel! equ 0 (
            echo   converted
            set /a success+=1
        ) else (
            echo   failed
            set /a failed+=1
        )
    )
)

if %count% equ 0 (
    echo no images found in %SOURCE%
    exit /b 1
)

echo.
echo done
echo total: %count% image^(s^)
echo success: %success%
if %failed% gtr 0 (
    echo failed: %failed%
)
goto :eof

:show_usage
echo batch convert images
echo.
echo usage: %~nx0 [options]
echo.
echo options:
echo   -s SOURCE     source directory with images ^(default: .\images^)
echo   -d DEST       destination directory ^(default: .\converted^)
echo   -f FORMAT     target format ^(jpg, png, webp, gif, etc.^)
echo   -q QUALITY    quality ^(1-100, default: 85^)
echo   -r WIDTHxHEIGHT  resize images ^(e.g. 1920x1080^)
echo.
echo examples:
echo   %~nx0 -s .\photos -f webp -q 80
echo   %~nx0 -s .\images -f jpg -r 1920x1080
echo.
echo note: requires imagemagick
exit /b 0
