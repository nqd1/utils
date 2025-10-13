# cloud-devops gitignore templates

## included templates

- Terraform
- Packer
- JENKINS_HOME
- GitHubPages


## usage

copy the appropriate .gitignore file to your project root or append to existing .gitignore

```bash
# example: copy to your project
cp cloud-devops/<template>.gitignore /path/to/your/project/.gitignore

# or append to existing .gitignore
cat cloud-devops/<template>.gitignore >> /path/to/your/project/.gitignore
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
