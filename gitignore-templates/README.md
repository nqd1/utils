# gitignore templates collection

organized gitignore templates by project type and technology stack

## categories

- **academic-research** (5 templates)
- **ai-ml** (2 templates)
- **audio-visual** (2 templates)
- **backend** (20 templates)
- **blockchain** (1 templates)
- **cloud-devops** (4 templates)
- **database** (2 templates)
- **data-science** (3 templates)
- **desktop** (5 templates)
- **embedded-iot** (5 templates)
- **functional-programming** (20 templates)
- **game-dev** (7 templates)
- **hardware-design** (3 templates)
- **misc** (19 templates)
- **mobile** (7 templates)
- **scripting** (6 templates)
- **systems-programming** (13 templates)
- **testing** (3 templates)
- **web-backend** (37 templates)
- **web-frontend** (13 templates)
- **web-fullstack** (3 templates)

## special folders

- **global-os-editors** (73 templates) - OS-specific and editor-specific gitignores (windows, macos, linux, vscode, vim, etc.)
- **community-extras** (69 templates) - community-contributed templates

## quick start

see **[QUICK-START.md](QUICK-START.md)** for common use cases and examples

see **[INDEX.md](INDEX.md)** for complete list of all templates

## usage

1. browse to the category that matches your project
2. copy the relevant .gitignore file to your project root
3. you can combine multiple templates if your project uses multiple technologies

### example: fullstack web project

```bash
# combine react frontend + node backend + os/editor ignores
cat gitignore-templates/web-frontend/React.gitignore > .gitignore
echo "" >> .gitignore
cat gitignore-templates/backend/Node.gitignore >> .gitignore
echo "" >> .gitignore
cat gitignore-templates/global-os-editors/VisualStudioCode.gitignore >> .gitignore
```

## directory structure

```
gitignore-templates/
â”œâ”€â”€ web-frontend/          # frontend frameworks
â”œâ”€â”€ web-backend/           # backend frameworks & cms
â”œâ”€â”€ web-fullstack/         # fullstack frameworks
â”œâ”€â”€ mobile/                # mobile development
â”œâ”€â”€ data-science/          # data analysis & science
â”œâ”€â”€ ai-ml/                 # machine learning & ai
â”œâ”€â”€ game-dev/              # game engines
â”œâ”€â”€ systems-programming/   # low-level languages
â”œâ”€â”€ backend/               # backend languages & tools
â”œâ”€â”€ functional-programming/# functional languages
â”œâ”€â”€ scripting/             # scripting languages
â”œâ”€â”€ cloud-devops/          # cloud & devops tools
â”œâ”€â”€ blockchain/            # blockchain development
â”œâ”€â”€ testing/               # testing frameworks
â”œâ”€â”€ database/              # database systems
â”œâ”€â”€ desktop/               # desktop applications
â”œâ”€â”€ embedded-iot/          # embedded & iot
â”œâ”€â”€ hardware-design/       # hardware & fpga
â”œâ”€â”€ audio-visual/          # audio/video production
â”œâ”€â”€ academic-research/     # academic & research
â”œâ”€â”€ misc/                  # miscellaneous
â”œâ”€â”€ global-os-editors/     # os & editor specific
â””â”€â”€ community-extras/      # community contributions
```

## sources

all templates are from the official [github/gitignore](https://github.com/github/gitignore) repository

## updates

to update templates:
1. pull latest from github/gitignore repository
2. run `powershell -ExecutionPolicy Bypass -File scripts/organize-gitignore.ps1`

## total

**299+ gitignore templates** organized into **23+ categories**
