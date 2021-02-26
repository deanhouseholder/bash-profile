## Apache
alias apache='cd /etc/apache2/sites-available/ && ls *-ssl.conf'
alias logs='cd /var/log/apache2/ && ls'
alias rp='sudo chown -R www-data:www-data .' # Reset permissions
alias ra='sudo service apache2 restart'
alias rla='sudo service apache2 reload'

## Composer
alias c='composer'
alias ci='c install'
alias cu='c update'
alias cr='c require'
alias cc='c clear-cache;c dump-autoload;if [[ -f artisan ]];then a clear-compiled;a optimize:clear;a cache:clear;a config:clear;a route:clear;a view:clear;fi;'

## Laravel
alias a='php artisan'
alias routes='a route:list'
alias newproject='c create-project --prefer-dist laravel/laravel .'

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
