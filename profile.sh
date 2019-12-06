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
if [[ "$(echo $PATH | grep ~/bin | wc -l)" -eq 0 ]]; then
  export PATH=$PATH:~/bin
fi
export TERM='xterm-256color'
export PROFILE_SH_PATH="$BASH_SOURCE"
export PROFILE_SH_DIR="${PROFILE_SH_PATH%profile.sh}"
export LS_OPTIONS='--color=auto -F --time-style=posix-long-iso'
source ~/bin/git-completion.bash

## Turn off CTRL+S mode
stty -ixon

## Aliases
alias vi='vim'
alias l='vi ~/bin/local_env.sh'
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

## Apache
alias apache='cd /etc/apache2/sites-available/ && ls -lh'
alias logs='cd /var/log/apache2/ && ls'
alias rp='chown -R www-data:www-data .'

## Laravel
alias a='php artisan'
alias r='a route:list'
alias routes='a route:list'
alias newproject='f(){ composer create-project --prefer-dist laravel/laravel .; }; f'

## Symfony
alias bc='bin/console --ansi'
alias rt='bc debug:router'
alias aw='bc debug:autowiring'
alias cdc='bc debug:container'
alias dcfg='bc debug:config'
alias dcfgf='bc debug:config framework'
alias cdump='bc config:dump'
alias cdumpf='bc config:dump framework'

## PHP
alias c='composer'
alias ci='c install'
alias cu='c update'
alias cr='c require'
alias cc='c clear-cache;c dump-autoload;if [[ -f artisan ]];then a clear-compiled;a optimize:clear;a cache:clear;a config:clear;a route:clear;a view:clear;elif [[ -f bin/console ]]; then bc cache:clear;bc cache:warmup;fi;'

## NPM
alias n='npm'
alias ni='npm install'

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
alias dm='docker-machine'
alias dmnative='echo "Switching native docker"; eval $(docker-machine env -u)'
alias dssh='f(){ docker exec -it -u root $1 bash; }; f'
alias dps='doc ps -a'
alias dup='dc up -d'
alias ddown='dc stop'
alias dssh='doc run -it app1 /bin/bash'

## Git
alias g='git'
alias gm='display_alias_menu "git-menu.md" "Git Shortcuts Menu"'
alias gmenu='gm'
alias gh='git help'
alias gha='git help -a'
alias g.='git add . && gs'
alias ga='git add'
alias gac='git add . && git commit && git push'
alias gad='git status -s | awk '"'"'{print $2}'"'"''
alias gb='git branch -a'
alias gback='git checkout -'
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
alias ghash='git branch --contains'
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
alias gum='git stash; git checkout master; git pull; git checkout -; git stash pop'
alias gs='clear && git status --ignore-submodules'
alias gsa='clear && git status'
alias gss='git submodule status'
alias gsu='git submodule update'
alias gu='git update-git-for-windows'
alias cleanup='d=($(git branch --merged | grep -Ev develop\|master | sed -e "s/^\*//" -e "s/^ *//g" | uniq)); if [[ ${#d[@]} -gt 0 ]]; then echo ${d[@]} | xargs git branch -d; fi'
alias branch='f(){ test -z "$1" && echo "No branch name given." && return; git checkout -b $1 2>/dev/null || git checkout $1; git branch -u origin/$1 $1 2>/dev/null; gp; git push --set-upstream origin $1; }; f'
alias stash='git stash'
alias restore='git stash pop'
alias wip='git commit -am "WIP"'


# Recursive File Search function
# $1 = File pattern (ex: *.js)
# $2 = String to search for
# $3 = (optional) Set to 1 for case-insensitive search
search(){
  # Define Vars
  local SEP='ᚦ' # Obscure ascii character not likely to appear in files
  local BOLD='\e[4m\e[1m'
  local END='\e[m\e[K'
  local PLAIN='\e[15m\e[K'
  local HEADING="${BOLD}\e[37m"
  local HEADER="${END}${BOLD}%s${END}${PLAIN}$SEP${BOLD}%s${END}${PLAIN}$SEP${BOLD}%s${END}\n"
  local FILTER="s/^([^:]*):([^:]+):(.*)$/\2$SEP\1$SEP\3/g"
  local CASE_SENSITIVE=''

  # Check user input
  if [[ -z "$1" ]] || [[ -z "$2" ]]; then
    local ERROR="${BOLD}\e[37m\e[41m"
    local MESSAGE="${BOLD}\e[36m"
    local USAGE="\n${HEADING}Recursive File Search${END}\n\n"
    USAGE="${USAGE}${ERROR}Error: %s${END}\n\n${MESSAGE}Usage:\n${END}"
    USAGE="${USAGE}search \"[file pattern]\" \"[search string]\" [insensitive]\n\n"
    USAGE="${USAGE}${MESSAGE}Examples:${END}\n"
    USAGE="${USAGE}search '*.js' 'undefined' 1\n"
    USAGE="${USAGE}search '*.log' 'Fatal Error:'\n\n"
    test -z "$1" && printf "$USAGE" "No file pattern given" && return 1
    test -z "$2" && printf "$USAGE" "No search string given" && return 1
  fi
  test "$3" == '1' && CASE_SENSITIVE='i'

  # Perform Search
  echo
  ( printf "$HEADER" "Line" "File Path" "Search Results"
    printf "$HEADER" "----" "---------" "---------------"
    find . -type f -name "$1" -exec grep -${CASE_SENSITIVE}nH --color=always "$2" {} \; | grep -v '^Binary' | uniq | sed -r -e "$FILTER"
  ) | column -t -s "$SEP"
  echo
}

gphp(){ search '*.php' "$1"; }
gphpi(){ search '*.php' "$1" 1; }
gcss(){ search '*.css' "$1"; }
gcssi(){ search '*.css' "$1" 1; }
gjs(){ search '*.js' "$1"; }
gjsi(){ search '*.js' "$1" 1; }
searchall(){ search '*' "$1"; }
searchalli(){ search '*' "$1" 1; }
searchcount(){ echo; printf "\nMatches\tFilename\n-----\t--------------------------------\n$(\grep -RHn "$1" | grep -v '^Binary' | cut -d: -f1 | uniq -c)\n\n" | column -t; echo; }
searchcounti(){ printf "\nMatches\tFilename\n-----\t--------------------------------\n$(\grep -iRHn "$1" | grep -v '^Binary' | cut -d: -f1 | uniq -c)\n\n" | column -t; }


## Useful Functions
# Convert all mp3 files in the current directory to 64kbps versions and associate the first .jpg image as their cover art
change_title(){ printf '\033]2;%s\007' "$(echo $@)"; }
find_up(){ p="$(pwd)"; while [[ "$p" != "" && ! -e "$p/$1" ]]; do p="${p%/*}"; done; echo "$p"; }
is_binary(){ grep -m1 '^' $1 | grep -q '^Binary'; } # Returns "0" for binary and "1" for text
mp3-64(){ for i in *.mp3; do lame --preset cbr 64 --ti $(ls *.jpg | head -n1) $i ${i%.mp3}-64.mp3; done; }

# Show what a command with aliases is actually executing
show_cmd(){
  cmd="eval "
  for i in "$@"; do
    if [[ "$i" =~ .*[[:space:]].* ]]; then
      # Argument came in with a space so restore quotes around it
      cmd+='"'$i'" '
    else
      cmd+=$i' '
    fi
  done
  reset=$(shopt -p expand_aliases); # Determine initial state of expand_aliases
  shopt -s expand_aliases; # Set expand_aliases to "on"
  (set -x; $cmd; set +x;) 2>&1 | sed -e '1d' -e 's/$d/OUTPUT:/' -e 's/^++/COMMAND:/g';
  $reset; # Reset expand_aliases to original value
}

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


## Bash Prompt Start

# Function to shorten the directory
function shorten_pwd {
  test ${#PWD} -gt 40 && pwd | awk -F/ '{print "/"$2"/["(NF-4)"]/"$(NF-1)"/"$NF}' || pwd
}

function show_prompt {
  ## Prompt Colors
  fgr="\e[0;37m"                        # Foreground White Regular
  fgb="\e[1;37m"                        # Foreground White Bold
  root_bg="\e[48;5;130m"                # Orange
  user_bg="\e[48;5;24m"                 # Blue
  dir_bg="\e[48;5;236m"                 # Dark Gray
  box_bg="\e[48;5;30m"                  # Blue-Green
  N="\e[0m"                             # Reset styles
  export git_style="\e[0;38;05;15;48;05;54m"  # Foreground White Bold, Purple background
  export git_clean="\e[1;38;05;46m"           # Green
  export git_dirty="\e[1;38;05;160m"          # Red
  export git_ignored="\e[1;38;05;243m"        # Gray
  unset git_color
  test -f ~/.displayname && box="$(cat ~/.displayname)"

  ## Determine if user is root or not
  test $UID -eq 0 && bg_color='root_bg' || bg_color='user_bg'

  # Check if current directory is a git repo
  $(git status &>/dev/null)
  if [[ $? -eq 0 ]]; then
    export gstatus=1
    export gbranch=$(git branch --show-current)
  else
    export gstatus=0
    export gbranch=""
  fi

  ## Combine styles (Using \[ and \] around colors is necessary to prevent issues with command line editing/browsing/completion!)
  export prefix="\[$fgr\]\[${!bg_color}\] $USER \[$fgr\]\[$box_bg\] $box \[$fgr\]\[$dir_bg\] "
  export suffix="> \[$N\]"
}

# Done:
# dirty = color red/green
# ahead/behind/current
# stashes exist = $
# in an ignored dir = color grey
# in .git dir  = color inverse red
# in a detached head (just branch name?)

# To-Do:
# Status: MERGING, CHERRY-PICKING, REVERTING, BISECTING, REBASING
# in a submodule = color diff background
# in a repo with no remotes = color diff background

function git_bg {
  if [[ "$gstatus" -eq 1 ]]; then
    # Check if in an ignored directory
    if [[ "$(git check-ignore .)" == '.' ]]; then
      printf "$git_ignored"
      return
    fi
    test -z "$(git status -s)" && printf "$git_clean" || printf "$git_dirty"
  else
    printf "$git_dirty"
  fi
}

function git_branch {
  if [[ "$gstatus" -eq 1 ]]; then
    printf "$gbranch"
    output=''

    # Stashes
    test -z "$(git stash list)" || output+='$'

    # Branch ahead or behind
    stream="$(git status | grep 'Your branch')"
    if [[ "$stream" =~ .*is\ behind.* ]]; then
      output+="<$(printf "$stream" | sed -e 's~[^0-9]*\([0-9]\+\).*~\1~g')"
    elif [[ "$stream" =~ .*is\ ahead.* ]]; then
      output+=">$(printf "$stream" | sed -e 's~[^0-9]*\([0-9]\+\).*~\1~g')"
    fi

    # If anything got added to the output var, print it w/ a space
    test -z "$output" || printf " $output"
  else
    if [[ "$PWD" =~ .*/\.git.* ]]; then
      printf "!GIT DIR"
    fi
  fi
}

# Run this function every time the prompt is displayed to update the variables
PROMPT_COMMAND="show_prompt"

# Run the function once to pre-load variables
show_prompt

# Set the prompt
export PS1="$prefix"
PS1+="\$(shorten_pwd)"
PS1+=" \[$git_style\] ["
PS1+="\[\$(git_bg)\]"
PS1+="\$(git_branch)"
PS1+="\[$git_style\]]"
PS1+="$suffix"

## Bash Prompt End


## Include local_env.sh
if [[ ! -f ~/bin/local_env.sh ]]; then
    touch ~/bin/local_env.sh
fi
source ~/bin/local_env.sh
