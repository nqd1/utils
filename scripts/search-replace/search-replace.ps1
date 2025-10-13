# search and replace text in files

param(
    [Parameter(Mandatory=$true)]
    [string]$Search,
    
    [string]$Replace = "",
    [string]$Directory = ".",
    [string]$Extension = "",
    [switch]$CaseInsensitive,
    [switch]$WholeWord,
    [switch]$Regex,
    [switch]$Preview,
    [switch]$Backup
)

function Show-Usage {
    Write-Host "search and replace text in files" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "usage: .\search-replace.ps1 -Search <text> [options]"
    Write-Host ""
    Write-Host "parameters:"
    Write-Host "  -Search          text/pattern to search (required)"
    Write-Host "  -Replace         replacement text"
    Write-Host "  -Directory       search directory (default: current directory)"
    Write-Host "  -Extension       file extension (e.g. .txt, .js)"
    Write-Host "  -CaseInsensitive case insensitive search"
    Write-Host "  -WholeWord       whole word only"
    Write-Host "  -Regex           use regex pattern"
    Write-Host "  -Preview         preview only (don't replace)"
    Write-Host "  -Backup          backup files before replacing"
    Write-Host ""
    Write-Host "examples:"
    Write-Host "  .\search-replace.ps1 -Search 'old_function' -Replace 'new_function' -Extension .js"
    Write-Host "  .\search-replace.ps1 -Search 'TODO' -Directory .\src -Preview"
    Write-Host "  .\search-replace.ps1 -Search 'console.log' -Replace '// console.log' -Extension .js -Backup"
    Write-Host "  .\search-replace.ps1 -Search '\btest\b' -Replace 'exam' -Regex -CaseInsensitive"
    exit 0
}

Write-Host "search & replace script" -ForegroundColor Yellow

# check directory
if (!(Test-Path $Directory)) {
    Write-Host "directory not found: $Directory" -ForegroundColor Red
    exit 1
}

Write-Host "directory: $Directory" -ForegroundColor Blue
Write-Host "search: '$Search'" -ForegroundColor Blue
if ($Replace -ne "") {
    Write-Host "replace: '$Replace'" -ForegroundColor Blue
}
if ($Extension -ne "") {
    Write-Host "extension: $Extension" -ForegroundColor Blue
}
if ($Preview) {
    Write-Host "mode: preview only" -ForegroundColor Yellow
}
Write-Host ""

# build search pattern
$searchPattern = $Search
if (!$Regex) {
    $searchPattern = [regex]::Escape($Search)
}
if ($WholeWord) {
    $searchPattern = "\b$searchPattern\b"
}

# find files
Write-Host "searching for '$Search'..." -ForegroundColor Green
Write-Host ""

$files = if ($Extension -ne "") {
    Get-ChildItem -Path $Directory -Filter "*$Extension" -File -Recurse
} else {
    Get-ChildItem -Path $Directory -File -Recurse
}

$fileMatches = @{}
$totalMatches = 0

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction Stop
        
        $options = [Text.RegularExpressions.RegexOptions]::None
        if ($CaseInsensitive) {
            $options = [Text.RegularExpressions.RegexOptions]::IgnoreCase
        }
        
        $matches = [regex]::Matches($content, $searchPattern, $options)
        
        if ($matches.Count -gt 0) {
            $fileMatches[$file.FullName] = $matches.Count
            $totalMatches += $matches.Count
            
            Write-Host "$($file.FullName)" -ForegroundColor Blue -NoNewline
            Write-Host " (" -NoNewline
            Write-Host "$($matches.Count) match(es)" -ForegroundColor Yellow -NoNewline
            Write-Host ")"
            
            # show preview of matches
            $lines = Get-Content $file.FullName
            $lineNum = 0
            $shown = 0
            
            foreach ($line in $lines) {
                $lineNum++
                if ($line -match $searchPattern) {
                    $highlightedLine = $line -replace "($searchPattern)", '>>$1<<'
                    Write-Host "  $lineNum : $highlightedLine" -ForegroundColor Green
                    $shown++
                    if ($shown -ge 5) {
                        if ($matches.Count -gt 5) {
                            Write-Host "  ... and more" -ForegroundColor Yellow
                        }
                        break
                    }
                }
            }
            
            Write-Host ""
        }
    } catch {
        # skip files that can't be read
        continue
    }
}

# results
Write-Host ""
Write-Host "found $totalMatches match(es) in $($fileMatches.Count) file(s)" -ForegroundColor Blue

if ($fileMatches.Count -eq 0) {
    Write-Host "no matches found" -ForegroundColor Yellow
    exit 0
}

# replace if not preview
if ($Replace -ne "" -and !$Preview) {
    Write-Host ""
    $confirm = Read-Host "replace all occurrences? (y/n)"
    
    if ($confirm -eq "y" -or $confirm -eq "Y") {
        Write-Host ""
        Write-Host "replacing..." -ForegroundColor Green
        
        $replacedFiles = 0
        
        foreach ($filePath in $fileMatches.Keys) {
            try {
                # backup if requested
                if ($Backup) {
                    Copy-Item $filePath "$filePath.bak" -Force
                }
                
                # read content
                $content = Get-Content $filePath -Raw
                
                # replace
                $options = [Text.RegularExpressions.RegexOptions]::None
                if ($CaseInsensitive) {
                    $options = [Text.RegularExpressions.RegexOptions]::IgnoreCase
                }
                
                $newContent = [regex]::Replace($content, $searchPattern, $Replace, $options)
                
                # write back
                Set-Content -Path $filePath -Value $newContent -NoNewline
                
                Write-Host "  $filePath" -ForegroundColor Green
                $replacedFiles++
            } catch {
                Write-Host "  failed: $filePath - $_" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host "replaced in $replacedFiles file(s)" -ForegroundColor Green
        
        if ($Backup) {
            Write-Host "backup files created with .bak extension" -ForegroundColor Blue
        }
    } else {
        Write-Host "cancelled" -ForegroundColor Yellow
    }
} elseif ($Preview) {
    Write-Host "preview mode - no changes made" -ForegroundColor Yellow
}
