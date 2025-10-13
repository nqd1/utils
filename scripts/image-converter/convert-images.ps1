# batch convert images (requires imagemagick or built-in .net)

param(
    [string]$Source = ".\images",
    [string]$Destination = ".\converted",
    [Parameter(Mandatory=$true)]
    [string]$Format,
    [int]$Quality = 85,
    [string]$Resize = "",
    [int]$Percent = 0,
    [switch]$KeepAspect
)

function Show-Usage {
    Write-Host "batch convert images" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "usage: .\convert-images.ps1 -Format <format> [options]"
    Write-Host ""
    Write-Host "parameters:"
    Write-Host "  -Source       source directory with images (default: .\images)"
    Write-Host "  -Destination  destination directory (default: .\converted)"
    Write-Host "  -Format       target format (jpg, png, webp, gif, etc.) [required]"
    Write-Host "  -Quality      quality (1-100, default: 85)"
    Write-Host "  -Resize       resize (e.g. 1920x1080)"
    Write-Host "  -Percent      resize by percentage"
    Write-Host "  -KeepAspect   keep aspect ratio"
    Write-Host ""
    Write-Host "examples:"
    Write-Host "  .\convert-images.ps1 -Source .\photos -Format webp -Quality 80"
    Write-Host "  .\convert-images.ps1 -Format jpg -Resize 1920x1080 -KeepAspect"
    Write-Host ""
    Write-Host "note: best with imagemagick installed or uses built-in .net"
    exit 0
}

Write-Host "image batch converter" -ForegroundColor Yellow

# check source
if (!(Test-Path $Source)) {
    Write-Host "source directory not found: $Source" -ForegroundColor Red
    exit 1
}

# create destination directory
if (!(Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}

Write-Host "source: $Source" -ForegroundColor Blue
Write-Host "destination: $Destination" -ForegroundColor Blue
Write-Host "format: $Format" -ForegroundColor Blue
Write-Host "quality: $Quality" -ForegroundColor Blue
if ($Resize -ne "") {
    Write-Host "resize: $Resize" -ForegroundColor Blue
}
if ($Percent -gt 0) {
    Write-Host "resize: $Percent%" -ForegroundColor Blue
}
Write-Host ""

# check imagemagick
$useImageMagick = $false
try {
    $null = Get-Command magick -ErrorAction Stop
    $useImageMagick = $true
    Write-Host "using imagemagick" -ForegroundColor Green
} catch {
    try {
        $null = Get-Command convert -ErrorAction Stop
        $useImageMagick = $true
        Write-Host "using imagemagick (convert)" -ForegroundColor Green
    } catch {
        Write-Host "imagemagick not found, using .net (limited features)" -ForegroundColor Yellow
        Add-Type -AssemblyName System.Drawing
    }
}

# find images
$extensions = @("*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp", "*.webp", "*.tiff")
$images = Get-ChildItem -Path $Source -Include $extensions -File

if ($images.Count -eq 0) {
    Write-Host "no images found in $Source" -ForegroundColor Red
    exit 1
}

Write-Host "found $($images.Count) image(s)" -ForegroundColor Blue
Write-Host ""

$success = 0
$failed = 0

foreach ($img in $images) {
    $name = $img.BaseName
    $output = Join-Path $Destination "$name.$Format"
    
    Write-Host "converting: $($img.Name)" -ForegroundColor Green
    
    try {
        if ($useImageMagick) {
            # use imagemagick
            $cmd = "magick convert"
            
            # try convert if magick doesn't exist
            try {
                $null = Get-Command magick -ErrorAction Stop
                $cmd = "magick convert"
            } catch {
                $cmd = "convert"
            }
            
            $args = "`"$($img.FullName)`""
            
            if ($Resize -ne "") {
                if ($KeepAspect) {
                    $args += " -resize `"$Resize>`""
                } else {
                    $args += " -resize `"$Resize!`""
                }
            }
            
            if ($Percent -gt 0) {
                $args += " -resize `"$Percent%`""
            }
            
            $args += " -quality $Quality `"$output`""
            
            $fullCmd = "$cmd $args"
            Invoke-Expression $fullCmd 2>$null
            
            if ($LASTEXITCODE -eq 0) {
                $origSize = "{0:N2} KB" -f ($img.Length / 1KB)
                $newSize = "{0:N2} KB" -f ((Get-Item $output).Length / 1KB)
                Write-Host "  $origSize -> $newSize" -ForegroundColor Green
                $success++
            } else {
                throw "imagemagick conversion failed"
            }
        } else {
            # use .net (basic functionality)
            $bitmap = [System.Drawing.Image]::FromFile($img.FullName)
            
            if ($Resize -ne "" -or $Percent -gt 0) {
                $width = $bitmap.Width
                $height = $bitmap.Height
                
                if ($Percent -gt 0) {
                    $width = [int]($width * $Percent / 100)
                    $height = [int]($height * $Percent / 100)
                } elseif ($Resize -match "(\d+)x(\d+)") {
                    $width = [int]$matches[1]
                    $height = [int]$matches[2]
                }
                
                $resized = New-Object System.Drawing.Bitmap($width, $height)
                $graphics = [System.Drawing.Graphics]::FromImage($resized)
                $graphics.DrawImage($bitmap, 0, 0, $width, $height)
                $bitmap.Dispose()
                $bitmap = $resized
            }
            
            # save image
            switch ($Format.ToLower()) {
                "jpg" { $format = [System.Drawing.Imaging.ImageFormat]::Jpeg }
                "jpeg" { $format = [System.Drawing.Imaging.ImageFormat]::Jpeg }
                "png" { $format = [System.Drawing.Imaging.ImageFormat]::Png }
                "gif" { $format = [System.Drawing.Imaging.ImageFormat]::Gif }
                "bmp" { $format = [System.Drawing.Imaging.ImageFormat]::Bmp }
                "tiff" { $format = [System.Drawing.Imaging.ImageFormat]::Tiff }
                default { $format = [System.Drawing.Imaging.ImageFormat]::Png }
            }
            
            $bitmap.Save($output, $format)
            $bitmap.Dispose()
            
            $origSize = "{0:N2} KB" -f ($img.Length / 1KB)
            $newSize = "{0:N2} KB" -f ((Get-Item $output).Length / 1KB)
            Write-Host "  $origSize -> $newSize" -ForegroundColor Green
            $success++
        }
    } catch {
        Write-Host "  failed: $_" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "done" -ForegroundColor Green
Write-Host "total: $($images.Count) image(s)" -ForegroundColor Blue
Write-Host "success: $success" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "failed: $failed" -ForegroundColor Red
}
