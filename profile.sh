## Exports
export PATH=$PATH:~/bin
export TERM='xterm-256color'
export LS_OPTIONS='--color=auto -F'
source ~/bin/git-prompt.sh

## Detect Environment and set vars
OSVER="$(cat /proc/version 2>/dev/null)"

# Cygwin
if [[ "$OSVER" =~ CYGWIN ]]; then
  export bash_env='cygwin'
  export dir_prefix='/cygdrive/c/'
# Git for Windows
elif [[ "$OSVER" =~ MINGW ]]; then
  export bash_env='gitforwin'
  export dir_prefix='/mnt/c/'
# Git Bash
elif [[ "$OSVER" =~ Microsoft ]]; then
  export bash_env='git'
  export dir_prefix='/c/'
# Mac OSX
elif [[ $(uname) == "Darwin" ]]; then
  export bash_env='mac'
  export dir_prefix='/'
# Vagrant
elif [[ -d '/vagrant' ]]; then
  export bash_env='vagrant'
  export dir_prefix='/'
# Linux
else
  export bash_env='linux'
  export dir_prefix='/'
fi


## Turn off CTRLS mode
stty -ixon

## Aliases
alias vi='vim "+syntax on"'
alias ls='\ls $LS_OPTIONS'
alias d='ls'
alias da='ls -a'
alias la='ls -lah'
alias ll='ls -lh'
alias v='ls -l'
alias vless='$(find /usr/share/vim/ -name less.sh 2>/dev/null)'
alias clear='printf "\033c"'
alias cls='printf "\033c"'
alias reload='. ~/bin/profile.sh'
alias p='$EDITOR ~/bin/profile.sh'
alias s='sudo su -'
alias ds='OUT=$(df -PTh | grep -v "Use" | awk "{printf \"%-9s %4s %4s \n\", \$7, \$6, \$5}" | sort); echo -e "Location Used Free\n$OUT" | column -t'
alias dsf='OUT=$(df -PTh | grep -v "Use" | awk "{printf \"%-9s %4s %4s %-6s\n\", \$7, \$6, \$5, \$2}" | sort); echo -e "Location Used Free Format \n$OUT" | column -t'
alias reboot?='[[ -f /var/run/reboot-required ]] && cat /var/run/reboot-required || echo "No need to reboot."'
alias upt='echo Load Average w/ Graph && perl -e '"'"'while(1){`cat /proc/loadavg` =~ /^([^ ]+)/;printf("%5s %s\n",$1,"#"x($1*10));sleep 4}'"'"''


## Apache
alias apache='cd /etc/apache2/sites-available/ && ls -lh'
alias logs='cd /var/log/apache2/ && ls'
alias rp='chown -R www-data:www-data .'

## Laravel
alias a='php artisan'
alias c='composer'
alias cr='composer require'
alias r='php artisan route:list'
alias routes='php artisan route:list'

## Symfony
alias bc='bin/console --ansi'
alias rt='bin/console --ansi debug:router'
alias aw='bin/console --ansi debug:autowiring'
alias cdc='bin/console --ansi debug:container'
alias dcfg='bin/console --ansi debug:config'
alias dcfgf='bin/console --ansi debug:config framework'
alias cdump='bin/console --ansi config:dump'
alias cdumpf='bin/console --ansi config:dump framework'

## Vagrant
if [[ $bash_env != "vagrant" ]]; then
  alias va='vagrant'
  alias vu='vagrant up'
  alias vh='vagrant halt'
  alias vs='vagrant ssh'
  alias start='vagrant up'
  alias stop='vagrant down'
else
  alias va='echo You are in a Vagrant VM.'
  alias vu='echo You are in a Vagrant VM.'
  alias vh='echo You are in a Vagrant VM.'
  alias vs='echo You are in a Vagrant VM.'
  alias start='echo You are in a Vagrant VM.'
  alias stop='echo You are in a Vagrant VM.'
fi

## Docker
alias dc='docker-compose'
alias dps='docker ps'
alias don='docker-compose up --build -d'
alias doff='docker-compose stop 2>/dev/null; docker-compose rm -f 2>/dev/null; docker rmi localdev-image -f 2>/dev/null'
alias dssh='winpty docker run -it app1 /bin/bash'

## Git
alias g='git'
alias gg='alias | grep [g]it'
alias g.='git add . && gs'
alias ga='git add'
alias gac='git add . && git commit && git push'
alias gad='git status -s | awk '"'"'{print $2}'"'"''
alias gb='git branch -a'
alias gc='git commit'
alias gca='git commit -a --amend -C HEAD'
alias gcm='git checkout master'
alias gcd='git checkout develop'
alias gd='git diff'
alias gf='git fetch'
alias gh='git help'
alias gitcred='git config --global credential.helper "store --file ~/.git-credentials"'
alias gl='git log --graph --decorate'
alias gl1='git log --oneline --graph --decorate'
alias gla='git log --oneline --all --source --decorate=short'
alias glf='git log --name-only'
alias gp='git pull'
alias gps='git push'
alias greset='git checkout -- . && gad | xargs rm -r'
alias grh='git reset HEAD --hard'
alias gs='clear && git status --ignore-submodules'
alias gsa='clear && git status'
alias gss='git submodule status'
alias gsu='git submodule update'
alias gu='git update-git-for-windows'
alias wip='git commit -am "WIP"'

## Useful Functions
alias cc='f(){ php ~/bin/composer clearcache; if [[ -f bin/console ]]; then php bin/console --ansi cache:clear; php bin/console --ansi cache:warmup; elif [[ -f artisan ]]; then php artisan view:clear; php artisan clear-compiled; fi }; f'
alias fgrep='f(){ find -type f -name "$1" -exec grep -inHo "$2" \{\} \; }; f'
alias gphp='f(){ find -type f -name "*.php" -exec grep -inHo "$1" \{\} \; | sed -r "s/^([^:]*):([0-9]*):.*$/\1\t:\2/g" | column -t; }; f'
alias gcss='f(){ find -type f -name "*.css" -exec grep -inHo "$1" \{\} \; | uniq | sed -r "s/^([^:]*):([0-9]*):.*$/\1\t:\2/g" | column -t; }; f'
alias gjs='f(){ find -type f -name "*.js" -exec grep -inHo "$1" \{\} \; | uniq | sed -r "s/^([^:]*):([0-9]*):.*$/\1\t:\2/g" | column -t; }; f'
alias gch='f(){ git checkout -b $1 origin/$1; }; f'
change_title(){ echo -e '\033]2;'$1'\007'; }
find_up() { p="$(pwd)"; while [[ "$p" != "" && ! -e "$p/$1" ]]; do p="${p%/*}"; done; echo "$p"; }
is_binary() { grep -m1 '^' $1 | grep -q '^Binary'; } # Returns "0" for binary and "1" for text


## Extract function with progress bars where possible
e () {
  # Exit the function if the file is not found
  if [[ ! -f "$1" ]]; then
    echo -e "\e[31mError: Couldn't find file.\e[0m"
    kill -INT $$
  fi

  case "$1" in
    *.7z)       ext=".7z";       cmd="7z";          options="x";      usepv=0;;
    *.tar.bz2)  ext=".tar.bz2";  cmd="tar";         options="jxvf";   usepv=0;;
    *.tbz2)     ext=".tbz2";     cmd="tar";         options="jxvf";   usepv=0;;
    *.tar.gz)   ext=".tar.gz";   cmd="tar";         options="zxvf";   usepv=0;;
    *.tgz)      ext=".tgz";      cmd="tar";         options="zxvf";   usepv=0;;
    *.tar)      ext=".tar";      cmd="tar";         options="xvf";    usepv=0;;
    *.rar)      ext=".rar";      cmd="unrar";       options="x";      usepv=0;;
    *.Z)        ext=".Z";        cmd="uncompress";  options="";       usepv=0;;
    *.bz2)      ext=".bz2";      cmd="bunzip2";     options="";       usepv=1;;
    *.gz)       ext=".gz";       cmd="gunzip";      options="";       usepv=1;;
    *.zip)      ext=".zip";      cmd="unzip";       options="";       usepv=1;;
    *)          echo -e "\e[31mError: Cannot determine how to extract '$1'\e[0m" && kill -INT $$;;
  esac

  echo -e "\e[32mExtracting $1\e[0m"

  # Check if extraction command is installed/executable
  [[ ! -x "$(which $cmd)" ]] && echo -e "\e[31mError: $cmd is not installed\e[0m" && kill -INT $$

  # Check if pv is enabled and installed
  if [[ $usepv -eq 1 && -x "$(which pv)" ]]; then
    filesize=$(stat -c '%s' "$1")
    newfile="${1%%$ext}"

    # Handle special case for .zip since unzip command doesn't allow piping and funzip doesn't allow multiple files
    if [[ $ext == ".zip" ]]; then
      # If the .zip contains 1 file and if funzip and pv are installed we can show a progress bar
      if [[ $(zipinfo -t "$1" | awk '{print $1}') -eq 1 && -x "$(which funzip)" ]]; then
        cat "$1" | pv -s $filesize -i 0.1 -D 0 | funzip > "$newfile"
      else
        unzip "$1"
      fi
    else
      # Use pv command to show progress bars
      cat "$1" | pv -s $filesize -i 0.1 -D 0 | $cmd $options > $newfile
    fi
  else
    # Run command
    $cmd $options "$1"
  fi
}

## ls with octal permission labels
lso () {
  test -z "$1" && dirname="." || dirname="$1"
  ls -lF --color "$dirname" | sed -e 's/--x/1/g' -e 's/-w-/2/g' -e 's/-wx/3/g' -e 's/r--/4/g' -e 's/r-x/5/g' -e 's/rw-/6/g' -e 's/rw[xt]/7/g' -e 's/---/0/g'
}

## Get an ordered list of subdirectory sizes
big () {
  cd "$1"
  du -sk * 2>/dev/null | sort -n | awk 'BEGIN{ pref[1]="K"; pref[2]="M"; pref[3]="G";} { total = total + $1; x = $1; y = 1; while( x > 1024 ) { x = (x + 1023)/1024; y++; } printf("%g%s\t%s\n",int(x*10)/10,pref[y],$2); } END { y = 1; while( total > 1024 ) { total = (total + 1023)/1024; y++; } printf("Total: %g%s\n",int(total*10)/10,pref[y]); }'
  cd - >/dev/null
}


## Load SSH Agent/Install SSH Key
if [[ -f ~/.ssh/id_rsa ]] && [[ -f ~/.ssh/.pkey ]]; then
  if [[ -S /tmp/ssh-agent.sock ]]; then
    agent_running=$(\ps | grep [s]sh-agent | awk '{print $2}' | wc -l)
    if [[ $agent_running == 0 ]]; then
      rm /tmp/ssh-agent.sock
    fi
  fi
  ssh-agent -a /tmp/ssh-agent.sock -s >/dev/null 2>&1
  export SSH_AUTH_SOCK=/tmp/ssh-agent.sock
  cat ~/.ssh/id_rsa | SSH_ASKPASS=~/.ssh/.pkey DISPLAY= ssh-add - 2>/dev/null
fi


## Colors
root_bg="8;5;130m"
root_fg="7m"
user_bg="8;5;39m"
user_fg="7m"
dir_bg="8;5;236m"
dir_fg="7m"
git_fg="7m"
git_bg="8;5;55m"

## Helper Vars
fmt_bold="\e[1m"
default="9m"
bg="\e[4"
fg="\e[3"
end="\e[0m"

## Formattings
if [ $UID -eq 0 ]; then
  user_fmt="$fg$root_fg$bg$root_bg$fmt_bold"
else
  user_fmt="$fg$user_fg$bg$user_bg$fmt_bold"
fi
dir_fmt="$fg$dir_fg$bg$dir_bg"
git_fmt="$fg$git_fg$bg$git_bg$fmt_bold"

## Function to get the current git branch
function git_branch {
  if [[ -n $1 ]]; then
    if [[ -z $(git status --porcelain 2>/dev/null) ]]; then
      echo -e "\033[38;5;40m"
    else
      echo -e "\033[38;5;196m"
    fi
  fi
}

## Prompts
export PS1="\[$user_fmt\] \u \[$end\]\
\[$dir_fmt\] \w \[$end\]\
\[$git_fmt\] [\[\$(git_branch \$(__git_ps1))\]\$(__git_ps1 '%s')\[$end$git_fmt\]]> \[$end\]"
export PS2="\[$dir_term_fmt\]#> \[$end\]"
export PS3="\[$dir_term_fmt\]#> \[$end\]"
export PS4="\[$dir_fmt\]+\[$dir_term_fmt\] \[$end\]"


## Include local_env.sh
touch ~/bin/local_env.sh
source ~/bin/local_env.sh
