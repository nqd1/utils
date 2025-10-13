# backup files and folders with timestamp

param(
    [Parameter(Mandatory=$true)]
    [string]$Source,
    
    [string]$Destination = ".\backups",
    [switch]$Compress,
    [int]$KeepDays = 0,
    [string]$CustomName = "",
    [string[]]$Exclude = @()
)

function Show-Usage {
    Write-Host "backup files/folders" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "usage: .\backup.ps1 -Source <path> [options]"
    Write-Host ""
    Write-Host "parameters:"
    Write-Host "  -Source        source directory/file to backup (required)"
    Write-Host "  -Destination   destination directory for backups (default: .\backups)"
    Write-Host "  -Compress      compress backup as .zip"
    Write-Host "  -KeepDays      keep backups for N days (delete older)"
    Write-Host "  -CustomName    custom name for backup (default: source name)"
    Write-Host "  -Exclude       exclude pattern (array)"
    Write-Host ""
    Write-Host "examples:"
    Write-Host "  .\backup.ps1 -Source .\project -Destination .\backups -Compress"
    Write-Host "  .\backup.ps1 -Source .\data -Compress -KeepDays 7"
    Write-Host "  .\backup.ps1 -Source .\app -Exclude @('*.log', 'node_modules') -Compress"
    exit 0
}

Write-Host "backup script" -ForegroundColor Yellow

# check source
if (!(Test-Path $Source)) {
    Write-Host "source not found: $Source" -ForegroundColor Red
    exit 1
}

# create backup directory
if (!(Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}

# create timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# backup name
if ($CustomName -eq "") {
    $basename = Split-Path $Source -Leaf
} else {
    $basename = $CustomName
}

Write-Host "source: $Source" -ForegroundColor Blue
Write-Host "destination: $Destination" -ForegroundColor Blue
Write-Host ""

if ($Compress) {
    # backup and compress
    $backupFile = Join-Path $Destination "${basename}_${timestamp}.zip"
    Write-Host "creating compressed backup: $backupFile" -ForegroundColor Green
    
    if ($Exclude.Count -gt 0) {
        # get all files excluding patterns
        $files = Get-ChildItem -Path $Source -Recurse -File | Where-Object {
            $file = $_
            $shouldExclude = $false
            foreach ($pattern in $Exclude) {
                if ($file.FullName -like "*$pattern*") {
                    $shouldExclude = $true
                    break
                }
            }
            -not $shouldExclude
        }
        
        # create temp directory and copy files
        $tempDir = Join-Path $env:TEMP "${basename}_temp"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        foreach ($file in $files) {
            $relativePath = $file.FullName.Substring($Source.Length + 1)
            $destPath = Join-Path $tempDir $relativePath
            $destFolder = Split-Path $destPath -Parent
            
            if (!(Test-Path $destFolder)) {
                New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
            }
            
            Copy-Item $file.FullName -Destination $destPath
        }
        
        Compress-Archive -Path "$tempDir\*" -DestinationPath $backupFile -Force
        Remove-Item -Path $tempDir -Recurse -Force
    } else {
        Compress-Archive -Path $Source -DestinationPath $backupFile -Force
    }
    
    if ($?) {
        $size = (Get-Item $backupFile).Length
        $sizeStr = "{0:N2} MB" -f ($size / 1MB)
        Write-Host "backup created successfully, size: $sizeStr" -ForegroundColor Green
    } else {
        Write-Host "backup failed" -ForegroundColor Red
        exit 1
    }
} else {
    # backup without compression
    $backupDir = Join-Path $Destination "${basename}_${timestamp}"
    Write-Host "creating backup: $backupDir" -ForegroundColor Green
    
    if ($Exclude.Count -gt 0) {
        Copy-Item -Path $Source -Destination $backupDir -Recurse -Exclude $Exclude
    } else {
        Copy-Item -Path $Source -Destination $backupDir -Recurse
    }
    
    if ($?) {
        $size = (Get-ChildItem $backupDir -Recurse | Measure-Object -Property Length -Sum).Sum
        $sizeStr = "{0:N2} MB" -f ($size / 1MB)
        Write-Host "backup created successfully, size: $sizeStr" -ForegroundColor Green
    } else {
        Write-Host "backup failed" -ForegroundColor Red
        exit 1
    }
}

# delete old backups
if ($KeepDays -gt 0) {
    Write-Host ""
    Write-Host "cleaning old backups (older than $KeepDays days)..." -ForegroundColor Yellow
    
    $cutoffDate = (Get-Date).AddDays(-$KeepDays)
    
    Get-ChildItem -Path $Destination -Filter "${basename}_*" | 
        Where-Object { $_.LastWriteTime -lt $cutoffDate } |
        Remove-Item -Recurse -Force
    
    Write-Host "cleanup completed" -ForegroundColor Green
}

Write-Host "done" -ForegroundColor Green
