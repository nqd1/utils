# organize ALL gitignore files into categories

$sourceDir = ".\gitignore"
$targetDir = ".\gitignore-templates"

Write-Host "organizing all gitignore files..." -ForegroundColor Yellow
Write-Host ""

# first, copy EVERYTHING to preserve all files
Write-Host "step 1: copying all gitignore files to preserve originals..." -ForegroundColor Cyan

# copy Global folder
$globalSource = Join-Path $sourceDir "Global"
if (Test-Path $globalSource) {
    $globalTarget = Join-Path $targetDir "global-os-editors"
    if (Test-Path $globalTarget) {
        Remove-Item $globalTarget -Recurse -Force
    }
    Copy-Item $globalSource $globalTarget -Recurse -Force
    $globalCount = (Get-ChildItem $globalTarget -Filter "*.gitignore" -Recurse).Count
    Write-Host "  copied Global -> global-os-editors ($globalCount files)" -ForegroundColor Green
}

# copy community folder
$communitySource = Join-Path $sourceDir "community"
if (Test-Path $communitySource) {
    $communityTarget = Join-Path $targetDir "community-extras"
    if (Test-Path $communityTarget) {
        Remove-Item $communityTarget -Recurse -Force
    }
    Copy-Item $communitySource $communityTarget -Recurse -Force
    $communityCount = (Get-ChildItem $communityTarget -Filter "*.gitignore" -Recurse).Count
    Write-Host "  copied community -> community-extras ($communityCount files)" -ForegroundColor Green
}

Write-Host ""
Write-Host "step 2: organizing into categories..." -ForegroundColor Cyan

# category mapping - organized by use case
$categories = @{
    "web-frontend" = @(
        "Angular", "Nextjs", "ExtJs", "Qooxdoo",
        "Elm", "PureScript", "ReScript", "Sass", "Jekyll", "GitBook",
        "Nanoc", "Yeoman", "Hexo", "GitHubPages"
    )
    
    "web-backend" = @(
        "Node", "Nestjs", "Laravel", "Symfony", "Rails", 
        "CakePHP", "CodeIgniter", "FuelPHP", "Kohana", "Lithium",
        "Phalcon", "Yii", "ZendFramework", "Drupal", "WordPress",
        "Joomla", "Magento", "Prestashop", "OpenCart", "Concrete5",
        "CraftCMS", "ExpressionEngine", "Textpattern", "SugarCRM",
        "Typo3", "EPiServer", "SymphonyCMS", "LemonStand", "Plone",
        "TurboGears2", "Grails", "PlayFramework", "SeamGen",
        "CFWheels", "ForceDotCom", "AppEngine", "Firebase"
    )
    
    "web-fullstack" = @(
        "Nextjs", "GWT", "RhodesRhomobile"
    )
    
    "mobile" = @(
        "Android", "Flutter", "AppceleratorTitanium",
        "Swift", "Objective-C", "Kotlin", "Dart"
    )
    
    "game-dev" = @(
        "Unity", "UnrealEngine", "Godot", "FlaxEngine", "AdventureGameStudio",
        "Processing", "SketchUp"
    )
    
    "data-science" = @(
        "Python", "R", "Julia"
    )
    
    "ai-ml" = @(
        "Python", "LangChain"
    )
    
    "backend" = @(
        "Node", "Go", "Rust", "Java", "Kotlin", "Scala", "Clojure",
        "Elixir", "Erlang", "Haskell", "OCaml", "Dotnet",
        "JBoss", "Maven", "Gradle", "Leiningen", "Composer", 
        "Packer", "Terraform", "Ballerina"
    )
    
    "desktop" = @(
        "Qt", "VisualStudio", "Xojo", "Delphi", "VBA"
    )
    
    "embedded-iot" = @(
        "CUDA", "HIP", "LabVIEW", "TwinCAT3", "IAR"
    )
    
    "systems-programming" = @(
        "C", "C++", "Rust", "Go", "Zig", "Nim", "D", "Fortran",
        "Ada", "CMake", "Autotools", "SCons", "Waf"
    )
    
    "functional-programming" = @(
        "Haskell", "Elm", "Elixir", "Erlang", "Clojure", "Scala",
        "OCaml", "ReScript", "PureScript", "Racket", "Scheme",
        "CommonLisp", "Elisp", "Idris", "Agda", "Coq", "Fancy",
        "Mercury", "Opa", "Raku"
    )
    
    "cloud-devops" = @(
        "Terraform", "Packer", "JENKINS_HOME", "GitHubPages"
    )
    
    "blockchain" = @(
        "Solidity-Remix"
    )
    
    "scripting" = @(
        "Python", "Ruby", "Perl", "Lua", "Luau", "VBA"
    )
    
    "academic-research" = @(
        "TeX", "R", "Julia", "Scrivener", "Lilypond"
    )
    
    "database" = @(
        "SSDT-sqlproj", "OracleForms"
    )
    
    "testing" = @(
        "TestComplete", "Katalon", "ecu.test"
    )
    
    "audio-visual" = @(
        "Finale", "Lilypond"
    )
    
    "hardware-design" = @(
        "KiCad", "Eagle", "ModelSim"
    )
}

# create all category directories
foreach ($category in $categories.Keys) {
    $categoryPath = Join-Path $targetDir $category
    if (!(Test-Path $categoryPath)) {
        New-Item -ItemType Directory -Path $categoryPath -Force | Out-Null
    }
}

# track which files have been categorized
$categorized = @{}
$stats = @{}
foreach ($category in $categories.Keys) {
    $stats[$category] = 0
}

# copy files to categories
foreach ($category in $categories.Keys) {
    $categoryPath = Join-Path $targetDir $category
    
    foreach ($lang in $categories[$category]) {
        # try main directory first
        $sourceFile = Join-Path $sourceDir "$lang.gitignore"
        
        if (Test-Path $sourceFile) {
            $targetFile = Join-Path $categoryPath "$lang.gitignore"
            Copy-Item $sourceFile $targetFile -Force
            $categorized[$lang] = $true
            $stats[$category]++
        } else {
            # try community subdirectories
            $found = $false
            $communitySubdirs = Get-ChildItem -Path (Join-Path $sourceDir "community") -Directory -ErrorAction SilentlyContinue
            
            foreach ($subdir in $communitySubdirs) {
                $communityFile = Join-Path $subdir.FullName "$lang.gitignore"
                if (Test-Path $communityFile) {
                    $targetFile = Join-Path $categoryPath "$lang.gitignore"
                    Copy-Item $communityFile $targetFile -Force
                    $categorized[$lang] = $true
                    $stats[$category]++
                    $found = $true
                    break
                }
            }
        }
    }
}

Write-Host ""
Write-Host "step 3: collecting uncategorized files..." -ForegroundColor Cyan

# find all main gitignore files that weren't categorized
$allMainFiles = Get-ChildItem -Path $sourceDir -Filter "*.gitignore" -File

# create misc category for uncategorized files
$miscPath = Join-Path $targetDir "misc"
if (!(Test-Path $miscPath)) {
    New-Item -ItemType Directory -Path $miscPath -Force | Out-Null
}

$miscCount = 0
foreach ($file in $allMainFiles) {
    $baseName = $file.BaseName
    if (!$categorized.ContainsKey($baseName)) {
        $targetFile = Join-Path $miscPath $file.Name
        Copy-Item $file.FullName $targetFile -Force
        $miscCount++
        Write-Host "  $baseName -> misc" -ForegroundColor DarkGray
    }
}

$stats["misc"] = $miscCount

Write-Host ""
Write-Host "step 4: creating README files..." -ForegroundColor Cyan

# create README for each category
foreach ($category in $categories.Keys) {
    $categoryPath = Join-Path $targetDir $category
    $readmePath = Join-Path $categoryPath "README.md"
    
    $templateList = $categories[$category] | ForEach-Object { "- $_" } | Out-String
    
    $readmeContent = @"
# $category gitignore templates

## included templates

$templateList

## usage

copy the appropriate .gitignore file to your project root or append to existing .gitignore

``````bash
# example: copy to your project
cp $($category)/<template>.gitignore /path/to/your/project/.gitignore

# or append to existing .gitignore
cat $($category)/<template>.gitignore >> /path/to/your/project/.gitignore
``````

## combining templates

you can combine multiple templates for complex projects:

``````bash
# example: combine multiple technologies
cat web-frontend/React.gitignore > .gitignore
echo "" >> .gitignore
cat backend/Node.gitignore >> .gitignore
echo "" >> .gitignore
cat global-os-editors/VisualStudioCode.gitignore >> .gitignore
``````

## sources

these templates are from [github/gitignore](https://github.com/github/gitignore) repository
"@

    Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
}

# create README for misc
$miscReadmePath = Join-Path $miscPath "README.md"
$miscFiles = Get-ChildItem -Path $miscPath -Filter "*.gitignore" | ForEach-Object { "- $($_.BaseName)" } | Out-String
$miscReadme = @"
# miscellaneous gitignore templates

various specialized and less common gitignore templates

## included templates

$miscFiles

## usage

copy the appropriate .gitignore file to your project root

``````bash
cp misc/<template>.gitignore /path/to/your/project/.gitignore
``````

## sources

these templates are from [github/gitignore](https://github.com/github/gitignore) repository
"@

Set-Content -Path $miscReadmePath -Value $miscReadme -Encoding UTF8

# create main README
$mainReadme = Join-Path $targetDir "README.md"
$categoryList = ""
$sortedCategories = $categories.Keys + "misc" | Sort-Object
foreach ($cat in $sortedCategories) {
    $count = $stats[$cat]
    $categoryList += "- **$cat** ($count templates)`n"
}

$mainReadmeContent = @"
# gitignore templates collection

organized gitignore templates by project type and technology stack

## categories

$categoryList
## special folders

- **global-os-editors** ($globalCount templates) - OS-specific and editor-specific gitignores (windows, macos, linux, vscode, vim, etc.)
- **community-extras** ($communityCount templates) - community-contributed templates

## quick start

see **[QUICK-START.md](QUICK-START.md)** for common use cases and examples

see **[INDEX.md](INDEX.md)** for complete list of all templates

## usage

1. browse to the category that matches your project
2. copy the relevant .gitignore file to your project root
3. you can combine multiple templates if your project uses multiple technologies

### example: fullstack web project

``````bash
# combine react frontend + node backend + os/editor ignores
cat gitignore-templates/web-frontend/React.gitignore > .gitignore
echo "" >> .gitignore
cat gitignore-templates/backend/Node.gitignore >> .gitignore
echo "" >> .gitignore
cat gitignore-templates/global-os-editors/VisualStudioCode.gitignore >> .gitignore
``````

## directory structure

``````
gitignore-templates/
├── web-frontend/          # frontend frameworks
├── web-backend/           # backend frameworks & cms
├── web-fullstack/         # fullstack frameworks
├── mobile/                # mobile development
├── data-science/          # data analysis & science
├── ai-ml/                 # machine learning & ai
├── game-dev/              # game engines
├── systems-programming/   # low-level languages
├── backend/               # backend languages & tools
├── functional-programming/# functional languages
├── scripting/             # scripting languages
├── cloud-devops/          # cloud & devops tools
├── blockchain/            # blockchain development
├── testing/               # testing frameworks
├── database/              # database systems
├── desktop/               # desktop applications
├── embedded-iot/          # embedded & iot
├── hardware-design/       # hardware & fpga
├── audio-visual/          # audio/video production
├── academic-research/     # academic & research
├── misc/                  # miscellaneous
├── global-os-editors/     # os & editor specific
└── community-extras/      # community contributions
``````

## sources

all templates are from the official [github/gitignore](https://github.com/github/gitignore) repository

## updates

to update templates:
1. pull latest from github/gitignore repository
2. run ``powershell -ExecutionPolicy Bypass -File scripts/organize-gitignore.ps1``

## total

**$($allMainFiles.Count + $communityCount + $globalCount)+ gitignore templates** organized into **$($categories.Keys.Count + 3)+ categories**
"@

Set-Content -Path $mainReadme -Value $mainReadmeContent -Encoding UTF8

# summary
Write-Host ""
Write-Host "=" -NoNewline -ForegroundColor Green
Write-Host ("=" * 50) -ForegroundColor Green
Write-Host "SUMMARY" -ForegroundColor Yellow
Write-Host ("=" * 51) -ForegroundColor Green
Write-Host ""

$totalCategorized = 0
foreach ($cat in $sortedCategories) {
    $count = $stats[$cat]
    if ($count -gt 0) {
        Write-Host ("{0,-25} : {1,3} files" -f $cat, $count) -ForegroundColor Cyan
        $totalCategorized += $count
    }
}

Write-Host ""
Write-Host "global-os-editors        : $globalCount files" -ForegroundColor Green
Write-Host "community-extras         : $communityCount files" -ForegroundColor Green
Write-Host ""
Write-Host ("=" * 51) -ForegroundColor Green
Write-Host "TOTAL                    : $($totalCategorized + $globalCount + $communityCount) files organized" -ForegroundColor Yellow
Write-Host ("=" * 51) -ForegroundColor Green
Write-Host ""
Write-Host "all gitignore files have been organized into: $targetDir" -ForegroundColor Green
Write-Host ""
