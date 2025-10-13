@echo off
REM rename files by pattern and rules

setlocal enabledelayedexpansion

set "EXTENSION="
set "PREFIX="
set "SUFFIX="
set "FIND="
set "REPLACE="
set "NUMBERING=false"
set "DIRECTORY=."

REM parse arguments
:parse_args
if "%~1"=="" goto :check_params
if "%~1"=="-e" set "EXTENSION=%~2" & shift & shift & goto :parse_args
if "%~1"=="-p" set "PREFIX=%~2" & shift & shift & goto :parse_args
if "%~1"=="-s" set "SUFFIX=%~2" & shift & shift & goto :parse_args
if "%~1"=="-r" set "FIND=%~2" & shift & shift & goto :parse_args
if "%~1"=="-R" set "REPLACE=%~2" & shift & shift & goto :parse_args
if "%~1"=="-n" set "NUMBERING=true" & shift & goto :parse_args
if "%~1"=="-d" set "DIRECTORY=%~2" & shift & shift & goto :parse_args
if "%~1"=="-h" goto :show_usage
shift
goto :parse_args

:check_params
if "%EXTENSION%"=="" (
    echo please specify extension ^(-e^)
    goto :show_usage
)

if not exist "%DIRECTORY%" (
    echo directory not found: %DIRECTORY%
    exit /b 1
)

echo renaming files with extension %EXTENSION%
echo.

REM count files
set count=0
for %%f in ("%DIRECTORY%\*%EXTENSION%") do set /a count+=1

if %count% equ 0 (
    echo no files found with extension %EXTENSION%
    exit /b 1
)

echo found %count% file^(s^) with extension %EXTENSION%
echo.
echo preview:

REM preview
set counter=1
for %%f in ("%DIRECTORY%\*%EXTENSION%") do (
    set "filename=%%~nf"
    set "new_name=!filename!"
    
    REM apply find/replace
    if not "%FIND%"=="" (
        set "new_name=!new_name:%FIND%=%REPLACE%!"
    )
    
    REM apply numbering
    if "%NUMBERING%"=="true" (
        set "num=00!counter!"
        set "new_name=!num:~-3!"
        set /a counter+=1
    )
    
    REM apply prefix/suffix
    set "new_name=%PREFIX%!new_name!%SUFFIX%"
    
    if not "%%~nf"=="!new_name!" (
        echo   %%~nxf -^> !new_name!%EXTENSION%
    )
)

echo.
set /p "confirm=continue renaming? (y/n): "
if /i not "%confirm%"=="y" (
    echo cancelled
    exit /b 0
)

REM rename files
echo.
echo renaming...
set renamed=0
set counter=1

for %%f in ("%DIRECTORY%\*%EXTENSION%") do (
    set "filename=%%~nf"
    set "new_name=!filename!"
    
    if not "%FIND%"=="" (
        set "new_name=!new_name:%FIND%=%REPLACE%!"
    )
    
    if "%NUMBERING%"=="true" (
        set "num=00!counter!"
        set "new_name=!num:~-3!"
        set /a counter+=1
    )
    
    set "new_name=%PREFIX%!new_name!%SUFFIX%"
    
    if not "%%~nf"=="!new_name!" (
        ren "%%f" "!new_name!%EXTENSION%"
        set /a renamed+=1
    )
)

echo renamed %renamed% file^(s^)
goto :eof

:show_usage
echo rename files by pattern
echo.
echo usage: %~nx0 [options]
echo.
echo options:
echo   -e EXT        file extension to rename ^(e.g. .txt, .jpg^)
echo   -p PREFIX     add prefix to filename
echo   -s SUFFIX     add suffix to filename ^(before extension^)
echo   -r FIND       find and replace: search string
echo   -R REPLACE    find and replace: replacement string
echo   -n            number files ^(001, 002, ...^)
echo   -d DIR        target directory ^(default: current dir^)
echo.
echo examples:
echo   %~nx0 -e .txt -p "document_" -d .\files
echo   %~nx0 -e .jpg -n -d .\photos
echo   %~nx0 -e .md -r "draft" -R "final"
exit /b 0
