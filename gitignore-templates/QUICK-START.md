# quick start guide

## find your template

### web development
- **frontend** → `web-frontend/` (angular, react, vue, nextjs, etc.)
- **backend** → `web-backend/` (node, laravel, rails, django, etc.)
- **fullstack** → `web-fullstack/` (nextjs, meteor, etc.)

### mobile development
- **android/ios** → `mobile/` (android, flutter, swift, kotlin, etc.)
- **cross-platform** → `mobile/` (flutter, cordova, expo, etc.)

### data & ai
- **data science** → `data-science/` (python, r, julia, jupyter, etc.)
- **machine learning** → `ai-ml/` (python, langchain, etc.)

### game development
- **game engines** → `game-dev/` (unity, unreal, godot, etc.)

### systems & low-level
- **systems programming** → `systems-programming/` (c, c++, rust, go, etc.)
- **embedded/iot** → `embedded-iot/` (arduino, esp-idf, cuda, etc.)

### other categories
- **desktop apps** → `desktop/` (qt, electron, etc.)
- **cloud/devops** → `cloud-devops/` (terraform, kubernetes, jenkins, etc.)
- **blockchain** → `blockchain/` (solidity, ethereum, etc.)
- **databases** → `database/` (sql, oracle, etc.)
- **hardware** → `hardware-design/` (kicad, eagle, fpga, etc.)
- **academic** → `academic-research/` (latex, r, matlab, etc.)
- **testing** → `testing/` (selenium, katalon, etc.)
- **scripting** → `scripting/` (python, ruby, perl, bash, etc.)
- **functional** → `functional-programming/` (haskell, elm, scala, etc.)

### special folders
- **os & editors** → `global-os-editors/` (windows, macos, vscode, vim, jetbrains, etc.)
- **community extras** → `community-extras/` (additional community templates)

## how to use

### single technology project

```bash
# example: react project
cp gitignore-templates/web-frontend/React.gitignore .gitignore

# example: python ml project
cp gitignore-templates/ai-ml/Python.gitignore .gitignore
```

### multi-technology project

combine multiple templates:

```bash
# example: nextjs + python backend
cat gitignore-templates/web-fullstack/Nextjs.gitignore > .gitignore
echo "" >> .gitignore
echo "# python backend" >> .gitignore
cat gitignore-templates/ai-ml/Python.gitignore >> .gitignore
echo "" >> .gitignore
echo "# os & editor" >> .gitignore
cat gitignore-templates/global-os-editors/macOS.gitignore >> .gitignore
cat gitignore-templates/global-os-editors/VisualStudioCode.gitignore >> .gitignore
```

### recommended combinations

**fullstack web (node + react)**
```bash
web-frontend/React.gitignore
+ web-backend/Node.gitignore
+ global-os-editors/[your-os].gitignore
+ global-os-editors/[your-editor].gitignore
```

**mobile (flutter)**
```bash
mobile/Flutter.gitignore
+ mobile/Dart.gitignore
+ global-os-editors/Android.gitignore (if targeting android)
+ global-os-editors/Xcode.gitignore (if targeting ios)
```

**data science**
```bash
data-science/Python.gitignore
+ data-science/JupyterNotebooks.gitignore
+ global-os-editors/[your-os].gitignore
```

**game dev (unity)**
```bash
game-dev/Unity.gitignore
+ global-os-editors/[your-os].gitignore
```

**backend api**
```bash
backend/[your-language].gitignore
+ cloud-devops/Docker.gitignore (if using docker)
+ database/[your-db].gitignore (if applicable)
```

## pro tips

1. **always add os/editor ignores** - even if not in template, add your os and editor specific ignores from `global-os-editors/`

2. **check multiple categories** - some technologies appear in multiple categories (e.g., python in ai-ml, data-science, scripting)

3. **customize for your needs** - these are starting points, adjust based on your project structure

4. **update regularly** - gitignore patterns evolve with tools and frameworks

5. **use gitignore.io** - for even more combinations: https://gitignore.io

## common scenarios

### "i'm building a nextjs app with python backend"
```
web-fullstack/Nextjs.gitignore
+ backend/Python.gitignore
+ global-os-editors/VisualStudioCode.gitignore
+ global-os-editors/macOS.gitignore (or Windows.gitignore)
```

### "react native mobile app"
```
mobile/Expo.gitignore (or React-Native if available)
+ web-frontend/React.gitignore
+ global-os-editors/[your-setup].gitignore
```

### "django rest api with postgresql"
```
web-backend/Django.gitignore
+ backend/Python.gitignore
+ database/PostgreSQL.gitignore (if available, else use custom)
+ global-os-editors/[your-setup].gitignore
```

### "unity game development"
```
game-dev/Unity.gitignore
+ global-os-editors/VisualStudio.gitignore
+ global-os-editors/Windows.gitignore
```

### "machine learning project with jupyter"
```
ai-ml/Python.gitignore
+ data-science/JupyterNotebooks.gitignore
+ global-os-editors/[your-setup].gitignore
```

### "rust systems programming"
```
systems-programming/Rust.gitignore
+ global-os-editors/[your-setup].gitignore
```

## need help?

if you're not sure which template to use:
1. check the README.md in each category folder
2. look at what files your framework/tool generates
3. search for your tech stack online: "[framework name] gitignore"
4. use multiple templates and remove duplicates

## updating templates

to get latest templates:
```bash
# pull latest from github/gitignore
cd gitignore
git pull

# re-run organization script
powershell -ExecutionPolicy Bypass -File scripts/organize-gitignore.ps1
```


