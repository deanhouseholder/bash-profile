## Apache
alias apache='cd /etc/apache2/sites-available/ && ls *-ssl.conf'
alias logs='cd /var/log/apache2/ && ls'
alias rp='chown -R www-data:www-data .'

## Composer
alias c='composer'
alias ci='c install'
alias cu='c update'
alias cr='c require'
alias cc='c clear-cache;c dump-autoload;if [[ -f artisan ]];then a clear-compiled;a optimize:clear;a cache:clear;a config:clear;a route:clear;a view:clear;elif [[ -f bin/console ]]; then bc cache:clear;bc cache:warmup;fi;'

## Laravel
alias a='php artisan'
alias routes='a route:list'
alias newproject='np(){ c create-project --prefer-dist laravel/laravel .; }; np'

## Symfony
#alias bc='bin/console --ansi'
#alias rt='bc debug:router'
#alias aw='bc debug:autowiring'
#alias cdc='bc debug:container'
#alias dcfg='bc debug:config'
#alias dcfgf='bc debug:config framework'
#alias cdump='bc config:dump'
#alias cdumpf='bc config:dump framework'

## NPM
alias n='npm'
alias ni='npm install'

## Vagrant
if [[ "$bash_env" != "vagrant" ]]; then
  test $bash_on_windows -eq 1 && alias vagrant='vagrant.exe'
  alias vu='vagrant up'
  alias vh='vagrant halt'
  alias vs='vagrant ssh'
  alias vstart='vagrant up'
  alias vstop='vagrant down'
else
  alias va='echo You are in a Vagrant VM.'
  alias vu='echo You are in a Vagrant VM.'
  alias vh='echo You are in a Vagrant VM.'
  alias vs='echo You are in a Vagrant VM.'
  alias vstart='echo You are in a Vagrant VM.'
  alias vstop='echo You are in a Vagrant VM.'
fi
