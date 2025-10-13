@echo off
REM create python virtual environment and install dependencies

setlocal enabledelayedexpansion

REM venv name (default is 'venv')
set "VENV_NAME=%~1"
if "%VENV_NAME%"=="" set "VENV_NAME=venv"

echo creating python virtual environment: %VENV_NAME%

REM check if python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo python not found, please install it first
    exit /b 1
)

REM create virtual environment
echo creating virtual environment...
python -m venv %VENV_NAME%

if %errorlevel% equ 0 (
    echo virtual environment created successfully
    
    REM activate venv
    call %VENV_NAME%\Scripts\activate.bat
    
    REM upgrade pip
    echo upgrading pip...
    python -m pip install --upgrade pip
    
    REM install requirements.txt if exists
    if exist requirements.txt (
        echo found requirements.txt, installing dependencies...
        pip install -r requirements.txt
    )
    
    echo done! use '%VENV_NAME%\Scripts\activate.bat' to activate
) else (
    echo failed to create virtual environment
    exit /b 1
)

endlocal
