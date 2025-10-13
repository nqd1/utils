# cleanup temp/cache files

param(
    [string]$Directory = ".",
    [ValidateSet("all", "node", "python", "build", "cache", "temp", "git")]
    [string]$Type = "all",
    [switch]$Recursive,
    [switch]$Preview,
    [switch]$AutoYes
)

function Show-Usage {
    Write-Host "cleanup temp/cache files" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "usage: .\cleanup.ps1 [options]"
    Write-Host ""
    Write-Host "parameters:"
    Write-Host "  -Directory    directory to clean (default: current directory)"
    Write-Host "  -Type         cleanup type (all, node, python, build, cache, temp, git)"
    Write-Host "  -Recursive    apply to all subdirectories"
    Write-Host "  -Preview      preview only (don't delete, just show)"
    Write-Host "  -AutoYes      auto confirm (no prompts)"
    Write-Host ""
    Write-Host "examples:"
    Write-Host "  .\cleanup.ps1 -Type node -Recursive"
    Write-Host "  .\cleanup.ps1 -Directory .\project -Type python -Recursive"
    Write-Host "  .\cleanup.ps1 -Type cache -Preview"
    exit 0
}

Write-Host "cleanup script" -ForegroundColor Yellow

# check directory
if (!(Test-Path $Directory)) {
    Write-Host "directory not found: $Directory" -ForegroundColor Red
    exit 1
}

Write-Host "directory: $Directory" -ForegroundColor Blue
Write-Host "type: $Type" -ForegroundColor Blue
if ($Preview) {
    Write-Host "mode: preview only" -ForegroundColor Yellow
}
Write-Host ""

# arrays for patterns
$dirsToDelete = @()
$filePatternsToDelete = @()

# add patterns based on type
if ($Type -eq "node" -or $Type -eq "all") {
    $dirsToDelete += "node_modules", ".npm", ".yarn"
    $filePatternsToDelete += "package-lock.json", "yarn.lock", "pnpm-lock.yaml"
}

if ($Type -eq "python" -or $Type -eq "all") {
    $dirsToDelete += "__pycache__", ".pytest_cache", ".mypy_cache", "*.egg-info", ".tox"
    $filePatternsToDelete += "*.pyc", "*.pyo", "*.pyd", ".coverage"
}

if ($Type -eq "build" -or $Type -eq "all") {
    $dirsToDelete += "dist", "build", "out", ".next", ".nuxt", "target"
}

if ($Type -eq "cache" -or $Type -eq "all") {
    $dirsToDelete += ".cache", ".parcel-cache", ".eslintcache"
    $filePatternsToDelete += "*.log", "*.cache"
}

if ($Type -eq "temp" -or $Type -eq "all") {
    $filePatternsToDelete += "*.tmp", "*.temp", "~*", "*.swp", "*.swo", ".DS_Store", "Thumbs.db"
    $dirsToDelete += "tmp", "temp"
}

if ($Type -eq "git") {
    if (Test-Path (Join-Path $Directory ".git")) {
        Write-Host "cleaning git ignored files..." -ForegroundColor Green
        Push-Location $Directory
        git clean -fdX
        Pop-Location
        Write-Host "done" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "not a git repository" -ForegroundColor Red
        exit 1
    }
}

Write-Host "scanning for cleanup items..." -ForegroundColor Green
Write-Host ""

$itemsToDelete = @()
$totalSize = 0

# find directories
foreach ($dirPattern in $dirsToDelete) {
    if ($Recursive) {
        $items = Get-ChildItem -Path $Directory -Directory -Filter $dirPattern -Recurse -ErrorAction SilentlyContinue
    } else {
        $items = Get-ChildItem -Path $Directory -Directory -Filter $dirPattern -ErrorAction SilentlyContinue
    }
    
    foreach ($item in $items) {
        $size = (Get-ChildItem $item.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $sizeStr = "{0:N2} MB" -f ($size / 1MB)
        Write-Host "  $($item.FullName) ($sizeStr)" -ForegroundColor Yellow
        $itemsToDelete += $item
        $totalSize += $size
    }
}

# find files
foreach ($filePattern in $filePatternsToDelete) {
    if ($Recursive) {
        $items = Get-ChildItem -Path $Directory -File -Filter $filePattern -Recurse -ErrorAction SilentlyContinue
    } else {
        $items = Get-ChildItem -Path $Directory -File -Filter $filePattern -ErrorAction SilentlyContinue
    }
    
    foreach ($item in $items) {
        $sizeStr = "{0:N2} KB" -f ($item.Length / 1KB)
        Write-Host "  $($item.FullName) ($sizeStr)" -ForegroundColor Yellow
        $itemsToDelete += $item
        $totalSize += $item.Length
    }
}

Write-Host ""
Write-Host "total: $($itemsToDelete.Count) items, size: $("{0:N2} MB" -f ($totalSize / 1MB))" -ForegroundColor Blue
Write-Host ""

if ($Preview) {
    Write-Host "preview completed, found items to clean" -ForegroundColor Blue
    Write-Host "run without -Preview flag to actually delete" -ForegroundColor Yellow
} else {
    if (!$AutoYes) {
        $confirm = Read-Host "delete these items? (y/n)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Host "cancelled" -ForegroundColor Yellow
            exit 0
        }
    }
    
    Write-Host "deleting..." -ForegroundColor Green
    $deleted = 0
    
    foreach ($item in $itemsToDelete) {
        try {
            Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop
            $deleted++
        } catch {
            Write-Host "  failed to delete: $($item.FullName)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "cleaned up $deleted items, freed: $("{0:N2} MB" -f ($totalSize / 1MB))" -ForegroundColor Green
}
