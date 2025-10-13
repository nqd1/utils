# auto commit and push with custom date
# note: for educational/testing purposes only

param(
    [string]$Message = "auto commit",
    [string]$Date = "",
    [int]$RandomDays = 0,
    [switch]$Push,
    [string]$Branch = ""
)

function Show-Usage {
    Write-Host "auto commit with custom date" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "usage: .\auto-commit.ps1 [options]"
    Write-Host ""
    Write-Host "parameters:"
    Write-Host "  -Message      commit message (default: 'auto commit')"
    Write-Host "  -Date         date for commit (format: 'YYYY-MM-DD HH:MM:SS')"
    Write-Host "  -RandomDays   random commit within last N days"
    Write-Host "  -Push         push after commit"
    Write-Host "  -Branch       branch to push (default: current branch)"
    Write-Host ""
    Write-Host "examples:"
    Write-Host "  .\auto-commit.ps1 -Message 'feature update' -Date '2024-01-15 10:30:00' -Push"
    Write-Host "  .\auto-commit.ps1 -Message 'bug fix' -RandomDays 7 -Push"
    exit 0
}

Write-Host "auto commit script" -ForegroundColor Yellow

# check git repo
try {
    git rev-parse --git-dir 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw
    }
} catch {
    Write-Host "not a git repository" -ForegroundColor Red
    exit 1
}

# generate random date if requested
if ($RandomDays -gt 0) {
    $randomSeconds = Get-Random -Minimum 0 -Maximum ($RandomDays * 86400)
    $Date = (Get-Date).AddSeconds(-$randomSeconds).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "random date: $Date" -ForegroundColor Blue
}

# stage changes
Write-Host "staging changes..." -ForegroundColor Green
git add -A

# check for changes
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "no changes to commit" -ForegroundColor Yellow
    exit 0
}

# commit
if ($Date -ne "") {
    Write-Host "committing with custom date: $Date" -ForegroundColor Green
    $env:GIT_AUTHOR_DATE = $Date
    $env:GIT_COMMITTER_DATE = $Date
    git commit -m $Message
    Remove-Item Env:\GIT_AUTHOR_DATE
    Remove-Item Env:\GIT_COMMITTER_DATE
} else {
    Write-Host "committing with current date..." -ForegroundColor Green
    git commit -m $Message
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "commit successful" -ForegroundColor Green
    
    # push if requested
    if ($Push) {
        if ($Branch -eq "") {
            $Branch = git rev-parse --abbrev-ref HEAD
        }
        
        Write-Host "pushing to $Branch..." -ForegroundColor Green
        git push origin $Branch
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "push successful" -ForegroundColor Green
        } else {
            Write-Host "push failed" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "commit failed" -ForegroundColor Red
    exit 1
}

Write-Host "done" -ForegroundColor Green
