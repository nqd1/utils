# backend gitignore templates

## included templates

- Node
- Go
- Rust
- Java
- Kotlin
- Scala
- Clojure
- Elixir
- Erlang
- Haskell
- OCaml
- Dotnet
- JBoss
- Maven
- Gradle
- Leiningen
- Composer
- Packer
- Terraform
- Ballerina


## usage

copy the appropriate .gitignore file to your project root or append to existing .gitignore

```bash
# example: copy to your project
cp backend/<template>.gitignore /path/to/your/project/.gitignore

# or append to existing .gitignore
cat backend/<template>.gitignore >> /path/to/your/project/.gitignore
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
