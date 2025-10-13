# rename files by pattern and rules

param(
    [Parameter(Mandatory=$true)]
    [string]$Extension,
    
    [string]$Prefix = "",
    [string]$Suffix = "",
    [string]$Find = "",
    [string]$Replace = "",
    [switch]$Lowercase,
    [switch]$Uppercase,
    [switch]$Numbering,
    [string]$Directory = ".",
    [switch]$AutoYes
)

function Show-Usage {
    Write-Host "rename files by pattern" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "usage: .\rename-files.ps1 -Extension <ext> [options]"
    Write-Host ""
    Write-Host "parameters:"
    Write-Host "  -Extension     file extension to rename (e.g. .txt, .jpg)"
    Write-Host "  -Prefix        add prefix to filename"
    Write-Host "  -Suffix        add suffix to filename (before extension)"
    Write-Host "  -Find          find and replace: search string"
    Write-Host "  -Replace       find and replace: replacement string"
    Write-Host "  -Lowercase     convert filename to lowercase"
    Write-Host "  -Uppercase     convert filename to UPPERCASE"
    Write-Host "  -Numbering     number files (001, 002, ...)"
    Write-Host "  -Directory     target directory (default: current dir)"
    Write-Host "  -AutoYes       auto confirm (no prompts)"
    Write-Host ""
    Write-Host "examples:"
    Write-Host "  .\rename-files.ps1 -Extension .txt -Prefix 'document_' -Directory .\files"
    Write-Host "  .\rename-files.ps1 -Extension .jpg -Numbering -Directory .\photos"
    Write-Host "  .\rename-files.ps1 -Extension .md -Find 'draft' -Replace 'final'"
    exit 0
}

# check directory
if (!(Test-Path $Directory)) {
    Write-Host "directory not found: $Directory" -ForegroundColor Red
    exit 1
}

# find files
$files = Get-ChildItem -Path $Directory -Filter "*$Extension" -File

if ($files.Count -eq 0) {
    Write-Host "no files found with extension $Extension in $Directory" -ForegroundColor Red
    exit 1
}

Write-Host "found $($files.Count) file(s) with extension $Extension" -ForegroundColor Blue
Write-Host ""
Write-Host "preview:" -ForegroundColor Yellow

# preview rename
$renameMap = @{}
$counter = 1

foreach ($file in $files) {
    $name = $file.BaseName
    $newName = $name
    
    # apply find/replace
    if ($Find -ne "") {
        $newName = $newName.Replace($Find, $Replace)
    }
    
    # apply case
    if ($Lowercase) {
        $newName = $newName.ToLower()
    } elseif ($Uppercase) {
        $newName = $newName.ToUpper()
    }
    
    # apply numbering
    if ($Numbering) {
        $newName = "{0:D3}" -f $counter
        $counter++
    }
    
    # apply prefix/suffix
    $newName = "$Prefix$newName$Suffix"
    
    $newFilename = "$newName$Extension"
    
    if ($file.Name -ne $newFilename) {
        Write-Host "  " -NoNewline
        Write-Host $file.Name -ForegroundColor Green -NoNewline
        Write-Host " -> " -NoNewline
        Write-Host $newFilename -ForegroundColor Blue
        $renameMap[$file.FullName] = Join-Path $Directory $newFilename
    }
}

Write-Host ""

# confirm
if (!$AutoYes) {
    $confirm = Read-Host "continue renaming? (y/n)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "cancelled" -ForegroundColor Yellow
        exit 0
    }
}

# rename files
Write-Host ""
Write-Host "renaming..." -ForegroundColor Green
$renamed = 0

foreach ($oldPath in $renameMap.Keys) {
    $newPath = $renameMap[$oldPath]
    Move-Item -Path $oldPath -Destination $newPath -Force
    $renamed++
}

Write-Host "renamed $renamed file(s)" -ForegroundColor Green
