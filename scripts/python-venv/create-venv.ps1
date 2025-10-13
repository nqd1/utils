# create python virtual environment and install dependencies

param(
    [string]$VenvName = "venv"
)

Write-Host "creating python virtual environment: $VenvName" -ForegroundColor Yellow

# check if python is installed
try {
    $null = Get-Command python -ErrorAction Stop
} catch {
    Write-Host "python not found, please install it first" -ForegroundColor Red
    exit 1
}

# create virtual environment
Write-Host "creating virtual environment..." -ForegroundColor Green
python -m venv $VenvName

if ($LASTEXITCODE -eq 0) {
    Write-Host "virtual environment created successfully" -ForegroundColor Green
    
    # activate venv
    & "$VenvName\Scripts\Activate.ps1"
    
    # upgrade pip
    Write-Host "upgrading pip..." -ForegroundColor Green
    python -m pip install --upgrade pip
    
    # install requirements.txt if exists
    if (Test-Path "requirements.txt") {
        Write-Host "found requirements.txt, installing dependencies..." -ForegroundColor Green
        pip install -r requirements.txt
    }
    
    Write-Host "done! use '$VenvName\Scripts\Activate.ps1' to activate" -ForegroundColor Green
} else {
    Write-Host "failed to create virtual environment" -ForegroundColor Red
    exit 1
}
