# Prevent continually adding to the path
if [[ ! "$PATH" =~ ~/bin:? ]]; then
  export PATH=$PATH:~/bin
fi

## Check for interactive terminal, otherwise, don't load all these aliases and functions
if [[ $- =~ i ]]; then

  ## Turn off CTRL+S mode
  stty -ixon

  export TERM='xterm-256color'
  export LS_OPTIONS='--color=auto -F --time-style=posix-long-iso'
  profile_sh_path="$BASH_SOURCE"
  profile_sh_dir="${profile_sh_path%/profile.sh}"

  ## Detect Environment and set vars
  os_ver="$(cat /proc/version 2>/dev/null)"
  # Cygwin
  if [[ "$os_ver" =~ CYGWIN ]]; then
    export bash_env='cygwin'
    export dir_prefix='/cygdrive/c/'
    export bash_on_windows=1
  # WSL on Windows
  elif [[ "$os_ver" =~ WSL ]]; then
    export bash_env='wsl'
    export dir_prefix='/'
    export bash_on_windows=1
  # Git for Windows
  elif [[ "$os_ver" =~ MINGW ]]; then
    export bash_env='gitforwin'
    export dir_prefix='/mnt/c/'
    export bash_on_windows=1
  # Git Bash
  elif [[ "$os_ver" =~ Microsoft ]]; then
    export bash_env='git'
    export dir_prefix='/c/'
    export bash_on_windows=1
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

  ## Aliases
  alias clear='printf "\033c"'
  alias cls='printf "\033c"'
  alias l='vi ~/bin/local_env.sh'
  alias ls='\ls $LS_OPTIONS'
  alias d='ls'
  alias da='ls -a'
  alias la='ls -lah'
  alias ll='ls -lh'
  alias v='ls -l'
  alias vim='vim "+syntax on"'
  alias vi='vim'
  alias vless='$(find /usr/share/vim/ -name less.sh 2>/dev/null)'
  alias reload='. $profile_sh_path'
  alias r='reload'
  alias p='$EDITOR $profile_sh_path'
  alias s='sudo su -'
  alias ds='OUT=$(df -PTh | grep -v "Use" | awk "{printf \"%-9s %4s %4s\n\", \$7, \$6, \$5}" | sort); printf "Location Used Free\n%s\n" "$OUT" | column -t'
  alias dsf='OUT=$(df -PTh | grep -v "Use" | awk "{printf \"%-9s %4s %4s %-6s\n\", \$7, \$6, \$5, \$2}" | sort); printf "Location Used Free Format \n%s\n" "$OUT" | column -t'
  alias reboot?='reb(){ local r=/var/run/reboot-required; local rp=$r.pkgs; test -f $r && (echo "Reboot required"; test -f $rp && echo -e "\nPackages updated:\n$(cat $rp)\n") || echo "No need to reboot."; }; reb'
  alias upt='echo Load Average w/ Graph && perl -e '"'"'while(1){`cat /proc/loadavg` =~ /^([^ ]+)/;printf("%5s %s\n",$1,"#"x($1*10));sleep 4}'"'"' 2>/dev/null'
  alias vimdiff='vimdiff -c "set diffopt=filler,context:0,iwhite"'
  alias colordiff='colordiff -w'
  alias sdiff='sdiff -bBWs'
  alias diffy='test $COLUMNS -ge 155 && COLS=154 || COLS=$COLUMNS; diff -yw --suppress-common-lines -W $COLS'


  ## Include Shortcut files

  # Include Helper shortcuts
  source "$profile_sh_dir/include/helper_shortcuts.sh"

  # Include Programming shortcuts
  source "$profile_sh_dir/include/programming_shortcuts.sh"

  # Include Search Contents function
  source "$profile_sh_dir/include/search_shortcuts.sh"

  # Include Experimental shortcuts (comment out if problems arise)
  source "$profile_sh_dir/include/experimental_shortcuts.sh"

  # Include Docker aliases if Docker is installed
  test "$bash_on_windows" -eq 1 && check_for_docker='docker.exe' || check_for_docker='docker'
  which $check_for_docker &>/dev/null && source "$profile_sh_dir/include/docker_shortcuts.sh"


  ## Include local_env.sh
  test ! -f ~/bin/local_env.sh && touch ~/bin/local_env.sh
  source ~/bin/local_env.sh

fi # End Check for interactive mode
