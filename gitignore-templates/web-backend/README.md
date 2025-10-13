# web-backend gitignore templates

## included templates

- Node
- Nestjs
- Laravel
- Symfony
- Rails
- CakePHP
- CodeIgniter
- FuelPHP
- Kohana
- Lithium
- Phalcon
- Yii
- ZendFramework
- Drupal
- WordPress
- Joomla
- Magento
- Prestashop
- OpenCart
- Concrete5
- CraftCMS
- ExpressionEngine
- Textpattern
- SugarCRM
- Typo3
- EPiServer
- SymphonyCMS
- LemonStand
- Plone
- TurboGears2
- Grails
- PlayFramework
- SeamGen
- CFWheels
- ForceDotCom
- AppEngine
- Firebase


## usage

copy the appropriate .gitignore file to your project root or append to existing .gitignore

```bash
# example: copy to your project
cp web-backend/<template>.gitignore /path/to/your/project/.gitignore

# or append to existing .gitignore
cat web-backend/<template>.gitignore >> /path/to/your/project/.gitignore
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
