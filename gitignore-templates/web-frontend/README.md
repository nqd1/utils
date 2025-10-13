# web-frontend gitignore templates

## included templates

- Angular
- Nextjs
- ExtJs
- Qooxdoo
- Elm
- PureScript
- ReScript
- Sass
- Jekyll
- GitBook
- Nanoc
- Yeoman
- Hexo
- GitHubPages


## usage

copy the appropriate .gitignore file to your project root or append to existing .gitignore

```bash
# example: copy to your project
cp web-frontend/<template>.gitignore /path/to/your/project/.gitignore

# or append to existing .gitignore
cat web-frontend/<template>.gitignore >> /path/to/your/project/.gitignore
```

## combining templates

you can combine multiple templates for complex projects:

```bash
# example: combine multiple technologies
cat web-frontend/React.gitignore > .gitignore
echo "" >> .gitignore
cat backend/Node.gitignore >> .gitignore
echo "" >> .gitignore
cat global-os-editors/VisualStudioCode.gitignore >> .gitignore
```

## sources

these templates are from [github/gitignore](https://github.com/github/gitignore) repository
