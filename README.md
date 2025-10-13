# handy scripts collection

collection of useful bash/batch/powershell scripts for common development tasks

## scripts

### python-venv
create python virtual environment and install dependencies

**bash:**
```bash
./create-venv.sh [venv_name]
```

**batch:**
```batch
create-venv.bat [venv_name]
```

**powershell:**
```powershell
.\create-venv.ps1 [-VenvName venv_name]
```

---

### rename-files
batch rename files by pattern with various rules

**bash:**
```bash
./rename-files.sh -e .txt -p "doc_" -d ./files
./rename-files.sh -e .jpg -n -d ./photos
./rename-files.sh -e .md -r "draft" -R "final"
```

**batch:**
```batch
rename-files.bat -e .txt -p "doc_" -d .\files
rename-files.bat -e .jpg -n -d .\photos
```

**powershell:**
```powershell
.\rename-files.ps1 -Extension .txt -Prefix "doc_" -Directory .\files
.\rename-files.ps1 -Extension .jpg -Numbering -Directory .\photos
```

---

### auto-commit
auto commit and push with custom date

**note:** for educational/testing purposes only

**bash:**
```bash
./auto-commit.sh -m "feature update" -d "2024-01-15 10:30:00" -p
./auto-commit.sh -m "bug fix" -r 7 -p
```

**batch:**
```batch
auto-commit.bat -m "feature update" -d "2024-01-15 10:30:00" -p
```

**powershell:**
```powershell
.\auto-commit.ps1 -Message "feature update" -Date "2024-01-15 10:30:00" -Push
.\auto-commit.ps1 -Message "bug fix" -RandomDays 7 -Push
```

---

### clone-repos
clone multiple repositories from a urls file

create `urls.txt` with one git url per line:
```
https://github.com/user/repo1.git
https://github.com/user/repo2.git
git@github.com:user/repo3.git
```

**bash:**
```bash
./clone-repos.sh -f repos.txt -d ./projects
./clone-repos.sh -f urls.txt -s -p
```

**batch:**
```batch
clone-repos.bat -f repos.txt -d .\projects
clone-repos.bat -f urls.txt -s
```

**powershell:**
```powershell
.\clone-repos.ps1 -UrlFile repos.txt -DestDir .\projects
.\clone-repos.ps1 -UrlFile urls.txt -Shallow -Parallel
```

---

### backup
backup files and folders with timestamp

**bash:**
```bash
./backup.sh -s ./project -d ./backups -z
./backup.sh -s ./data -z -k 7
./backup.sh -s ./app -e '*.log' -e 'node_modules' -z
```

**batch:**
```batch
backup.bat -s .\project -d .\backups -z
backup.bat -s .\data -z
```

**powershell:**
```powershell
.\backup.ps1 -Source .\project -Destination .\backups -Compress
.\backup.ps1 -Source .\data -Compress -KeepDays 7
.\backup.ps1 -Source .\app -Exclude @('*.log', 'node_modules') -Compress
```

---

### image-converter
batch convert images to different formats

**requires:** imagemagick (or built-in .net for powershell)

**bash:**
```bash
./convert-images.sh -s ./photos -f webp -q 80
./convert-images.sh -s ./images -f jpg -r 1920x1080 -k
./convert-images.sh -f png -p 50
```

**batch:**
```batch
convert-images.bat -s .\photos -f webp -q 80
convert-images.bat -s .\images -f jpg -r 1920x1080
```

**powershell:**
```powershell
.\convert-images.ps1 -Source .\photos -Format webp -Quality 80
.\convert-images.ps1 -Format jpg -Resize 1920x1080 -KeepAspect
```

---

### cleanup
cleanup temp/cache files from projects

**bash:**
```bash
./cleanup.sh -t node -r
./cleanup.sh -d ./project -t python -r
./cleanup.sh -t cache -p
```

**batch:**
```batch
cleanup.bat -t node -r
cleanup.bat -d .\project -t python -r
cleanup.bat -t temp -p
```

**powershell:**
```powershell
.\cleanup.ps1 -Type node -Recursive
.\cleanup.ps1 -Directory .\project -Type python -Recursive
.\cleanup.ps1 -Type cache -Preview
```

**cleanup types:**
- `all` - everything
- `node` - nodejs (node_modules, package-lock.json, etc.)
- `python` - python (__pycache__, *.pyc, .pytest_cache, etc.)
- `build` - build files (dist, build, out, etc.)
- `cache` - cache files (.cache, *.tmp, *.log, etc.)
- `temp` - temp files (*.tmp, *.temp, ~*, etc.)
- `git` - git ignored files

---

### search-replace
search and replace text in files

**bash:**
```bash
./search-replace.sh -s 'old_function' -r 'new_function' -e .js
./search-replace.sh -s 'TODO' -d ./src -p
./search-replace.sh -s 'console.log' -r '// console.log' -e .js -b
```

**batch:**
```batch
search-replace.bat -s "old_function" -r "new_function" -e .js
search-replace.bat -s "TODO" -d .\src -p
search-replace.bat -s "console.log" -r "// console.log" -e .js -b
```

**powershell:**
```powershell
.\search-replace.ps1 -Search 'old_function' -Replace 'new_function' -Extension .js
.\search-replace.ps1 -Search 'TODO' -Directory .\src -Preview
.\search-replace.ps1 -Search '\btest\b' -Replace 'exam' -Regex -CaseInsensitive
```

---

## installation

just download the scripts you need and make them executable

**for bash scripts:**
```bash
chmod +x script-name.sh
```

**for batch scripts:**
just run them directly on windows

**for powershell scripts:**
you might need to set execution policy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## notes

- all scripts support `-h` flag for help/usage information
- bash scripts work on linux/macos/wsl
- batch scripts work on windows cmd
- powershell scripts work on windows powershell/pwsh
- some scripts require external tools (like imagemagick for image conversion)
- always test scripts on sample data first before using on important files

## license

feel free to use, modify, and distribute these scripts however you want


