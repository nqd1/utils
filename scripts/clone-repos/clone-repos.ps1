# clone multiple repositories from urls file

param(
    [string]$UrlFile = "urls.txt",
    [string]$DestDir = ".\repos",
    [string]$Branch = "",
    [switch]$Shallow,
    [switch]$Parallel
)

function Show-Usage {
    Write-Host "clone multiple repositories" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "usage: .\clone-repos.ps1 [options]"
    Write-Host ""
    Write-Host "parameters:"
    Write-Host "  -UrlFile      file with URLs list (default: urls.txt)"
    Write-Host "  -DestDir      destination directory (default: .\repos)"
    Write-Host "  -Branch       branch to checkout (default: main/master)"
    Write-Host "  -Shallow      shallow clone (latest commit only)"
    Write-Host "  -Parallel     clone in parallel"
    Write-Host ""
    Write-Host "urls file format (one URL per line):"
    Write-Host "  https://github.com/user/repo1.git"
    Write-Host "  https://github.com/user/repo2.git"
    Write-Host ""
    Write-Host "examples:"
    Write-Host "  .\clone-repos.ps1 -UrlFile repos.txt -DestDir .\projects"
    Write-Host "  .\clone-repos.ps1 -UrlFile urls.txt -Shallow -Parallel"
    exit 0
}

Write-Host "clone multiple repositories" -ForegroundColor Yellow

# check urls file
if (!(Test-Path $UrlFile)) {
    Write-Host "file not found: $UrlFile" -ForegroundColor Red
    Write-Host "creating sample urls.txt..." -ForegroundColor Yellow
    
    @"
# add git repository URLs here (one per line)
# examples:
# https://github.com/user/repo1.git
# https://github.com/user/repo2.git
# git@github.com:user/repo3.git
"@ | Out-File -FilePath "urls.txt" -Encoding UTF8
    
    Write-Host "created sample urls.txt, please add URLs and run again" -ForegroundColor Green
    exit 0
}

# create destination directory
if (!(Test-Path $DestDir)) {
    New-Item -ItemType Directory -Path $DestDir | Out-Null
}

Write-Host "source: $UrlFile" -ForegroundColor Blue
Write-Host "destination: $DestDir" -ForegroundColor Blue
Write-Host ""

# read URLs (skip empty lines and comments)
$urls = Get-Content $UrlFile | Where-Object { $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' }

if ($urls.Count -eq 0) {
    Write-Host "no URLs found in file" -ForegroundColor Red
    exit 1
}

Write-Host "found $($urls.Count) repository/repositories" -ForegroundColor Blue
Write-Host ""

# function to clone repo
function Clone-Repository {
    param([string]$Url)
    
    $repoName = [System.IO.Path]::GetFileNameWithoutExtension($Url)
    $clonePath = Join-Path $DestDir $repoName
    
    if (Test-Path $clonePath) {
        Write-Host "$repoName already exists, pulling updates..." -ForegroundColor Yellow
        Push-Location $clonePath
        git pull
        Pop-Location
        return $true
    } else {
        Write-Host "cloning $repoName..." -ForegroundColor Green
        
        $cloneCmd = "git clone"
        
        if ($Shallow) {
            $cloneCmd += " --depth 1"
        }
        
        if ($Branch -ne "") {
            $cloneCmd += " -b $Branch"
        }
        
        $cloneCmd += " `"$Url`" `"$clonePath`""
        
        Invoke-Expression $cloneCmd
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "cloned $repoName" -ForegroundColor Green
            return $true
        } else {
            Write-Host "failed to clone $repoName" -ForegroundColor Red
            return $false
        }
    }
}

# clone repositories
$success = 0
$failed = 0

if ($Parallel) {
    Write-Host "cloning in parallel mode..." -ForegroundColor Blue
    $jobs = @()
    
    foreach ($url in $urls) {
        $jobs += Start-Job -ScriptBlock {
            param($u, $d, $b, $s)
            
            $repoName = [System.IO.Path]::GetFileNameWithoutExtension($u)
            $clonePath = Join-Path $d $repoName
            
            $cloneCmd = "git clone"
            if ($s) { $cloneCmd += " --depth 1" }
            if ($b -ne "") { $cloneCmd += " -b $b" }
            $cloneCmd += " `"$u`" `"$clonePath`""
            
            Invoke-Expression $cloneCmd
        } -ArgumentList $url, $DestDir, $Branch, $Shallow
    }
    
    $jobs | Wait-Job | Receive-Job
    $jobs | Remove-Job
} else {
    foreach ($url in $urls) {
        if (Clone-Repository -Url $url) {
            $success++
        } else {
            $failed++
        }
    }
}

Write-Host ""
Write-Host "done" -ForegroundColor Green
Write-Host "total: $($urls.Count) repositories" -ForegroundColor Blue

if (!$Parallel) {
    Write-Host "success: $success" -ForegroundColor Green
    if ($failed -gt 0) {
        Write-Host "failed: $failed" -ForegroundColor Red
    }
}
