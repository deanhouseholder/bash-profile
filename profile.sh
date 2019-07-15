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

## Exports
export PATH=$PATH:~/bin
export TERM='xterm-256color'
export PROFILE_SH_PATH="$BASH_SOURCE"
export PROFILE_SH_DIR="${PROFILE_SH_PATH%profile.sh}"
if [[ $bash_env == 'mac' ]]; then
  export LS_OPTIONS='-GF'
else
  export LS_OPTIONS='--color=auto -F'
fi
source ~/bin/git-prompt.sh

## Turn off CTRL+S mode
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
alias ds='OUT=$(df -PTh | grep -v "Use" | awk "{printf \"%-9s %4s %4s \n\", \$7, \$6, \$5}" | sort); printf "Location Used Free\n$OUT\n" | column -t'
alias dsf='OUT=$(df -PTh | grep -v "Use" | awk "{printf \"%-9s %4s %4s %-6s\n\", \$7, \$6, \$5, \$2}" | sort); printf "Location Used Free Format \n$OUT\n" | column -t'
alias reboot?='[[ -f /var/run/reboot-required ]] && cat /var/run/reboot-required || echo "No need to reboot."'
alias upt='echo Load Average w/ Graph && perl -e '"'"'while(1){`cat /proc/loadavg` =~ /^([^ ]+)/;printf("%5s %s\n",$1,"#"x($1*10));sleep 4}'"'"''
alias bin='cd ~/bin'
alias ut='cd /'
alias up='cd ..'
alias up2='cd ../..'
alias up3='cd ../../..'
alias up4='cd ../../../..'
alias up5='cd ../../../../..'

## PHP
alias c='composer'
alias cl='c list'
alias cr='c require'

## Apache
alias apache='cd /etc/apache2/sites-available/ && ls -lh'
alias logs='cd /var/log/apache2/ && ls'
alias rp='chown -R www-data:www-data .'

## Laravel
alias a='php artisan'
alias r='a route:list'
alias routes='a route:list'

## Symfony
alias bc='bin/console --ansi'
alias rt='bc debug:router'
alias aw='bc debug:autowiring'
alias cdc='bc debug:container'
alias dcfg='bc debug:config'
alias dcfgf='bc debug:config framework'
alias cdump='bc config:dump'
alias cdumpf='bc config:dump framework'

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
which winpty &>/dev/null
[[ $? == 0 ]] && WINPTY='winpty ' || WINPTY=''
alias doc="${WINPTY}docker"
alias dc='docker-compose'
alias dps='doc ps'
alias dup='dc up -d'
alias ddown='dc stop'
alias dssh='doc run -it app1 /bin/bash'

## Git
alias g='git'
alias gm='display_alias_menu "git-menu.md" "Git Shortcuts Menu"'
alias gmenu='gm'
alias gh='git help'
alias g.='git add . && gs'
alias ga='git add'
alias gac='git add . && git commit && git push'
alias gad='git status -s | awk '"'"'{print $2}'"'"''
alias gb='git branch -a'
alias gc='git commit'
alias gca='git commit -a --amend -C HEAD'
alias gcm='git checkout master'
alias gcd='git checkout develop'
alias gcb='f(){ git checkout bugfix/$1 2>/dev/null; git branch -u origin/bugfix/$1 bugfix/$1 >/dev/null; }; f'
alias gcf='f(){ git checkout feature/$1 2>/dev/null; git branch -u origin/feature/$1 feature/$1 >/dev/null; }; f'
alias gch='f(){ git checkout hotfix/$1 2>/dev/null; git branch -u origin/hotfix/$1 hotfix/$1 >/dev/null; }; f'
alias gcr='f(){ git checkout release/$1 2>/dev/null; git branch -u origin/release/$1 release/$1 >/dev/null; }; f'
alias gcs='f(){ git checkout support/$1 2>/dev/null; git branch -u origin/support/$1 support/$1 >/dev/null; }; f'
alias gd='git diff'
alias gf='git fetch'
alias gitcred='git config --global credential.helper "store --file ~/.git-credentials"'
alias gl='git log --graph --decorate'
alias glg='git log --oneline --graph --decorate'
alias gla='git log --oneline --all --source --decorate=short'
alias gld='git show'
alias glf='git log --name-only'
alias glast='git show --stat=$(tput cols) --compact-summary'
alias gp='git pull'
alias gps='git push'
alias gr='git checkout -- .'
alias grm='gad | xargs rm -r 2>/dev/null'
alias greset='gr && grm'
alias grh='git reset --hard'
alias gs='clear && git status --ignore-submodules'
alias gsa='clear && git status'
alias gss='git submodule status'
alias gsu='git submodule update'
alias gu='git update-git-for-windows'
alias new='f(){ git checkout -b $1 2>/dev/null; git branch -u origin/$1 $1 >/dev/null; }; f'
alias stash='git stash'
alias restore='git stash pop'
alias wip='git commit -am "WIP"'

## Useful Functions
alias cc='f(){ php ~/bin/composer clearcache;if [[ -f artisan ]]; then a clear-compiled;a optimize;a cache:clear;a config:clear;a route:clear;a view:clear;c clearcache;c dumpautoload;elif [[ -f bin/console ]]; then bc cache:clear;bc cache:warmup;c clearcache;c dumpautoload;fi }; f'

alias gphp='f(){ find . -type f -name "*.php" -exec grep -inHo "$1" \{\} \; | sed -r "s/^([^:]*):([0-9]*):.*$/\1\t:\2/g" | column -t; }; f'
alias gcss='f(){ find . -type f -name "*.css" -exec grep -inHo "$1" \{\} \; | uniq | sed -r "s/^([^:]*):([0-9]*):.*$/\1\t:\2/g" | column -t; }; f'
alias gjs='f(){ find . -type f -name "*.js" -exec grep -inHo "$1" \{\} \; | uniq | sed -r "s/^([^:]*):([0-9]*):.*$/\1\t:\2/g" | column -t; }; f'
alias gch='f(){ git checkout -b $1 origin/$1; }; f'
alias searchfiles='f(){ find . -type f -name "$1" -exec grep -nHo "$2" \{\} \;; }; f'
alias searchfilesi='f(){ find . -type f -name "$1" -exec grep -inHo "$2" \{\} \;; }; f'
search(){ \grep -RHn "$1" | grep -v '^Binary' | uniq | sed -r "s/^([^:]*):([0-9]*):.*$/\1\t:\2/g" | column -t; }
searchi(){ \grep -RHin "$1" | grep -v '^Binary' | uniq | sed -r "s/^([^:]*):([0-9]*):.*$/\1\t:\2/g" | column -t; }
change_title(){ printf '\033]2;'$1'\007'; }
find_up(){ p="$(pwd)"; while [[ "$p" != "" && ! -e "$p/$1" ]]; do p="${p%/*}"; done; echo "$p"; }
is_binary(){ grep -m1 '^' $1 | grep -q '^Binary'; } # Returns "0" for binary and "1" for text
gitflow() {
    GIT_FLOW_CONFIG="master\ndevelop\nfeature/\nbugfix/\nrelease/\nhotfix/\nsupport/\n\n\n"
    # Check to see if git flow is initialized and is correctly configured
    echo "Checking git flow config..."
    GIT_FLOW_CHECK=$(git flow config 2>/dev/null)
    if [[ $? -eq 1 ]]; then
      # Check if Git Flow is installed
      GIT_CHECK=$(git flow 2>&1 | grep 'not a git command' | wc -l)
      if [[ $GIT_CHECK -eq 1 ]]; then
        printf "\nError: Git Flow is not installed.\n\nPlease run: \"apt install git-flow\"\n\n"
        return 1
      fi
      # Set Git Flow config
      echo "Configuring git flow"
      printf "$GIT_FLOW_CONFIG" | git flow init >/dev/null
    elif [[ $(echo "$GIT_FLOW_CHECK" | grep "Feature branch prefix: feature/" | wc -l) -eq 0 ]]; then
      # Force reset of Git Flow config
      echo "Reconfiguring git flow"
      printf "$GIT_FLOW_CONFIG" | git flow init -f >/dev/null
    fi
}


## Display Alias Menu
display_alias_menu() {

  repeat_string() {
    printf "%0.s$1" $(seq 1 $2)
  }

  # Get Aliases from .md file passed in
  OUT="$(cat $PROFILE_SH_DIR/$1 | grep -E '^\|')"
  FIRST_LINE="$(echo "$OUT" | head -n1)"
  LENGTH=$((${#FIRST_LINE}+2))
  PADDING=$((($LENGTH / 2) - 10))
  BAR="$(repeat_string '-' $LENGTH)"

  HELP="$(echo "$OUT" | awk '{
   gsub("^\\| ([a-z\\[\\]][^ ]*)", "| \033[36m"$2"\033[37m");
   gsub("\\| Alias Name", "| \033[1;37mAlias Name\033[0;37m");
   gsub("\\| Description", "| \033[1;37mDescription\033[0;37m");
   gsub("\\|", " | ");
   print $0
  }')"

  printf "\n$(repeat_string ' ' $PADDING)${HEADER}$2$N\n"
  printf " +%s+\n%s\n +%s+\n\n" "$BAR" "$HELP" "$BAR"
}


## Extract function with progress bars where possible
e () {
  # Exit the function if the file is not found
  if [[ ! -f "$1" ]]; then
    printf "\n\e[31mERROR: Couldn't find file to extract.\e[0m\n"
    kill -INT $$
  fi
  local filename=$(basename $1)
  local dir=$(pwd)
  
  printf "Extract $filename into $dir\n\n"

  local count=$(\ls | wc -l | awk '{print $1}')
  if [[ $count -ne 0 ]]; then
    printf "\e[33mWARNING: The current directory is not empty!\n\n"
    printf "There are currently [$count] items in this directory.\e[0m\n\n"
    printf "Would you like to proceed anyway? [y/N]\n"
    read -sn 1 p
    if [[ ! $p =~ [yY] ]]; then
      printf "\nCancelled\n"
      kill -INT $$
    fi
    echo
  fi

  case "$1" in
    *.7z)       ext=".7z";       cmd="7z";          options="x";     usepv=0;;
    *.tar.bz2)  ext=".tar.bz2";  cmd="tar";         options="jxvf";  usepv=0;;
    *.tbz2)     ext=".tbz2";     cmd="tar";         options="jxvf";  usepv=0;;
    *.tar.gz)   ext=".tar.gz";   cmd="tar";         options="zxvf";  usepv=0;;
    *.tgz)      ext=".tgz";      cmd="tar";         options="zxvf";  usepv=0;;
    *.tar)      ext=".tar";      cmd="tar";         options="xvf";   usepv=0;;
    *.rar)      ext=".rar";      cmd="unrar";       options="x";     usepv=0;;
    *.Z)        ext=".Z";        cmd="uncompress";  options="";      usepv=0;;
    *.bz2)      ext=".bz2";      cmd="bunzip2";     options="";      usepv=1;;
    *.gz)       ext=".gz";       cmd="gunzip";      options="";      usepv=1;;
    *.zip)      ext=".zip";      cmd="unzip";       options="";      usepv=1;;
    *)          printf "\e[31mError: Cannot determine how to extract '$1'\e[0m\n" && kill -INT $$;;
  esac

  printf "\e[32mExtracting $filename\e[0m\n"

  # Check if extraction command is installed/executable
  [[ ! -x "$(which $cmd)" ]] && printf "\e[31mError: $cmd is not installed\e[0m\n" && kill -INT $$

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
  printf "\nDone\n\n"
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
      printf "\033[38;5;40m"
    else
      printf "\033[38;5;196m"
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
