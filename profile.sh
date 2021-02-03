# Prevent continually adding to the path
if [[ ! "$PATH" =~ ~/bin:? ]]; then
  export PATH=$PATH:~/bin
fi

## Check for interactive terminal
if [[ $- =~ i ]]; then

  ## Turn off CTRL+S mode (only if in interactive mode)
  stty -ixon

  export TERM='xterm-256color'
  export LS_OPTIONS='--color=auto -F --time-style=posix-long-iso'
  export PROFILE_SH_PATH="$BASH_SOURCE"
  export PROFILE_SH_DIR="${PROFILE_SH_PATH%profile.sh}"

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

  ## Aliases
  alias vi='vim "+syntax on"'
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
  alias r='reload'
  alias p='$EDITOR ~/bin/profile.sh'
  alias s='sudo su -'
  alias ds='OUT=$(df -PTh | grep -v "Use" | awk "{printf \"%-9s %4s %4s\n\", \$7, \$6, \$5}" | sort); printf "Location Used Free\n%s\n" "$OUT" | column -t'
  alias dsf='OUT=$(df -PTh | grep -v "Use" | awk "{printf \"%-9s %4s %4s %-6s\n\", \$7, \$6, \$5, \$2}" | sort); printf "Location Used Free Format \n%s\n" "$OUT" | column -t'
  alias reboot?='reb(){ r=/var/run/reboot-required; rp=$r.pkgs; test -f $r && (echo "Reboot required"; test -f $rp && echo -e "\nPackages updated:\n$(cat $rp)\n") || echo "No need to reboot."; }; reb'
  alias upt='echo Load Average w/ Graph && perl -e '"'"'while(1){`cat /proc/loadavg` =~ /^([^ ]+)/;printf("%5s %s\n",$1,"#"x($1*10));sleep 4}'"'"' 2>/dev/null'
  alias bin='cd ~/bin'

  ## Diff Aliases
  alias vimdiff='vimdiff -c "set diffopt=filler,context:0,iwhite"'
  alias colordiff='colordiff -w'
  alias sdiff='sdiff -bBWs'
  alias diffy='test $COLUMNS -ge 155 && COLS=154 || COLS=$COLUMNS; diff -yw --suppress-common-lines -W $COLS'

  ## Changing Directories up
  ## "up" will cd up a directory or if you pass in a number it will cd up that many times
  function up() {
    if [[ -z "$1" ]]; then
      cd ..
    else
      if [[ $1 =~ [0-9]+ ]]; then
        cd $(printf "%0.s../" $(seq $1))
      else
        printf "You must enter a valid number.\n"
      fi
    fi
  }
  alias up2='cd ../..'
  alias up3='cd ../../..'
  alias up4='cd ../../../..'
  alias up5='cd ../../../../..'
  alias up6='cd ../../../../../..'
  alias up7='cd ../../../../../../..'
  alias up8='cd ../../../../../../../..'
  alias up9='cd ../../../../../../../../..'
  alias up10='cd ../../../../../../../../../..'
  alias ut='cd /'

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
  alias r='a route:list'
  alias routes='a route:list'
  alias newproject='np(){ c create-project --prefer-dist laravel/laravel .; }; np'

  ## Symfony
  alias bc='bin/console --ansi'
  alias rt='bc debug:router'
  alias aw='bc debug:autowiring'
  alias cdc='bc debug:container'
  alias dcfg='bc debug:config'
  alias dcfgf='bc debug:config framework'
  alias cdump='bc config:dump'
  alias cdumpf='bc config:dump framework'

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
  if [[ "$(uname -a | grep WSL)" != "" ]]; then
    # This bash is running via WSL on Windows so use docker.exe
    which winpty &>/dev/null && WINPTY='winpty ' || WINPTY=''
    alias docker='${WINPTY}docker.exe'
    alias docker-compose='docker-compose.exe'
    alias docker-machine='docker-machine.exe'
  fi
  alias da='docker attach'
  alias dbs='docker_build_and_start'
  alias dc='docker-compose'
  alias dcbt='docker_compose_build_and_maybe_tag'
  alias dclogs='docker-compose logs'
  alias dcps='docker-compose ps'
  alias ddiff='docker diff'
  alias ddown='docker-compose stop'
  alias di='docker images'
  alias dins='docker inspect'
  alias distart='docker_interactive_start_stop start'
  alias distop='docker_interactive_start_stop stop'
  alias dm='echo "Switching docker-machine"; docker-machine'
  alias dmnative='echo "Switching native docker"; eval $(dm env -u)'
  alias doc="docker"
  alias dps='docker ps'
  alias dpsa='docker ps -a'
  alias dready='docker_ready'
  alias drestartl='docker start $(docker ps -ql) && docker attach $(docker ps -ql)'
  alias drm='docker rm'
  alias drma='docker_remove_all_containers'
  alias drmd='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
  alias drmi='docker rmi'
  alias drmia='docker_remove_all_images'
  alias drun='docker run'
  alias dsh='docker_shell'
  alias dstart='docker_start_image_by_name'
  alias dstop='docker stop'
  alias dup='docker-compose up -d'

  # Interactive Docker start/stop function using fzf (fuzzy-finder)
  # TODO: Add ability to start any image not just a stopped container
  function docker_interactive_start_stop() {
    # If fzf is not installed, exit
    which fzf &>/dev/null || { printf "Error: fzf is not installed\n"; return 1; }

    # Make sure Docker is ready
    docker_ready

    # Offer help if run with -h or --help
    if [[ "$1" =~ ^-{1,2}h[elp]?$ ]]; then
      echo "Usage: $FUNCNAME [start/stop]" && return 1
    fi

    # Default to "start" mode if not defined
    test -z "$1" && mode=start || mode=$1
    local containers=()

    # Check the mode
    if [[ "$mode" == "start" ]]; then

      # Start one or more containers
      local lines="$(docker ps -a -f 'status=exited' | grep -v 'CONTAINER ID' | fzf -0 --tac -m)"
      test -z "$lines" && { printf "No stopped Docker containers found.\n"; return 1; }
      while read -a line; do
        printf "\rStarting (${line[0]}) ${line[1]}...\n"
        containers=(${containers[@]} ${line[0]})
      done <<< $lines
      docker start ${containers[@]} >/dev/null

    elif [[ "$mode" == "stop" ]]; then

      # Stop one or more containers
      local lines="$(docker ps | grep -v 'CONTAINER ID' | fzf -0 --tac -m)"
      test -z "$lines" && { printf "No running Docker containers found.\n"; return 1; }
      while read -a line; do
        printf "\rStopping (${line[0]}) ${line[1]}...\n"
        containers=(${containers[@]} ${line[0]})
      done <<< $lines
      docker stop ${containers[@]} >/dev/null
    fi

    test $(echo "$lines" | wc -l) -eq 1 && printf "\nTip: By pressing tab, you can select multiple next time.\n"
  }

  # Interactive Docker function to open a shell in a running container using fzf
  function docker_interactive_shell() {
    # If fzf is not installed, exit
    which fzf &>/dev/null || { printf "Error: fzf is not installed\n"; return 1; }

    # Make sure Docker is ready
    docker_ready

    # Prompt for a list of running Docker containers
    local line=($(docker ps | grep -v 'CONTAINER ID' | fzf -0 --tac --phony))
    test -z "$line" && { printf "\rNo running Docker containers found, or none selected.\n"; return 1; }

    local container_id=${line[0]}
    local container_name=${line[1]}

    # Launch bash
    printf "\rLaunching bash shell in $container_name\n"
    docker exec -it $container_id bash

    # If bash failed, launch sh instead
    if [[ $? -ne 0 ]]; then
      # Clear previous error line and replace it with "using sh instead" message
      printf "\r\e[ABash not found. Launching sh shell instead.\e[K\n"
      docker exec -it $container_id sh
      printf "\n"
    fi
  }

  # Wait for Docker engine to start
  function docker_ready() {
    local i=1
    docker version &>/dev/null
    while [[ $? -ne 0 ]]; do
      printf "\rWaiting for docker engine to start up... [$i]"
      sleep 1
      let i++
      docker version &>/dev/null
    done
    test $i -gt 1 && printf "\n\nDocker is now ready\n\n"
  }

  # Stop and delete all Docker containers
  function docker_remove_all_containers() {
    docker_ready
    local containers=($(docker ps -aq))  # Get a list of the running docker containers
    test -z $containers && printf "\nNo containers found.\n\n" && return 1
    printf "\nStopping ${#containers[@]} docker containers:\n"
    docker stop ${containers[@]}   # Stop all running containers
    printf "\nDestroying ${#containers[@]} docker containers:\n"
    docker rm ${containers[@]}     # Destroy all containers
    echo
  }

  # Delete all downloaded Docker images. Note: This is not necessary except to clear space
  function docker_remove_all_images() {
    docker_ready
    local images=($(docker images -aq)) # Get list of images
    test -z $images && echo "No images found." && return 1
    printf "\nDestroying docker images:\n"
    docker rmi ${images[@]} # Remove images
    echo
  }

  # Run a shell in the specified Docker container (try bash first)
  docker_shell() {
    docker_ready
    if [[ $# -ne 1 ]]; then
      echo "Usage: $FUNCNAME [CONTAINER_ID/CONTAINER_NAME]" && return 1
    fi
    local containers=($(docker ps -aq))  # Get a list of the running docker containers
    test -z $containers && printf "\nNo running containers found.\n\n" && return 1
    if [[ "${containers[@]}" =~ $1 ]]; then
      # It's a container ID
      docker exec -it $1 bash 2>/dev/null || docker exec -it $1 sh
    else
      # It's a container name
      docker-compose exec $1 bash 2>/dev/null || docker-compose exec $1 sh
    fi
  }

  # Start a docker image by name
  docker_start_image_by_name() {
    if [[ $# -lt 1 ]]; then
      echo "Usage $FUNCNAME IMAGENAME" && return 1
    fi

    # Check to see if a container by this name is/was previously running
    local container_id=$(docker_get_container_id_by_name "$1")
    if [[ ! -z "$container_id" ]]; then
      local running_container_id=$(docker_get_running_continer_id_by_name "$1")
      if [[ ! -z "$running_container_id" ]]; then
        printf "\nThe docker container $1 is already running.\n"
        local local_port=$(docker_get_local_listening_port_by_container_name "$1")
        printf "\nYou can access it via: http://localhost:$local_port/\n\n"
        return 0
      else
        printf "\nStarting $1\n"
        docker start "$1" >/dev/null
        if [[ $? -eq 0 ]]; then
          local local_port=$(docker_get_local_listening_port_by_container_name "$1")
          printf "\nYou can access it via: http://localhost:$local_port/\n\n"
          return 0
        else
          return 1
        fi
      fi
    fi

    # Didn't find an existing container, so create a new container from the image name
    local image_id=$(docker images -q "$1")
    local internal_port="$(docker_get_internal_service_port_from_container_by_name $1)"
    printf "\nReady to start $1...\n\nThe docker image listens on port $internal_port.\n"

    # Prompt user for what local port to map (only necessary for new container)
    printf "What local port do you want to access it on? [$internal_port] "
    read local_port
    test -z "$local_port" && local_port=$internal_port

    # Create the container
    docker run -d --name "$1" -p $local_port:$internal_port $image_id >/dev/null
    if [[ $? -eq 0 ]]; then
      printf "\n$1 is now running.\n\nYou can access it at:\n\nhttp://localhost:$local_port/\n\n"
    else
      printf "\n$1 failed to start.\n\n"
      return 1
    fi
  }

  # Docker build and start
  # Usage: dbs tag-name [path]
  # [path] assumes current directory
  docker_build_and_start() {
    if [[ $# -lt 1 ]]; then
      echo "Usage $FUNCNAME TAGNAME [DIRNAME]" && return 1
    fi
    if [ $# -gt 1 ]; then
      local args="-t $@"
    else
      local args="-t $1 ."
    fi
    docker build $args
    if [[ $? -eq 0 ]]; then
      docker_start_image_by_name "$1"
    fi
  }

  # Docker-compose build with optional tagging
  docker_compose_build_and_maybe_tag() {
    if [[ $# -lt 1 ]]; then
      echo "Usage $FUNCNAME DIRNAME [TAGNAME ...]" && return 1
    fi
    local args="$1"
    shift
    if [ $# -ge 2 ]; then
      args="$args -t $@"
    fi
    docker-compose build $args
  }

  # Get the docker container's locally-mapped port by name
  docker_get_local_listening_port_by_container_name() {
    docker inspect -f '{{.NetworkSettings.Ports}}' "$1" | sed -r -e 's/.* ([0-9]+)}.*/\1/'
  }

  docker_get_internal_service_port_from_container_by_name() {
    docker inspect -f '{{.ContainerConfig.ExposedPorts}}' $(docker images -q "$1") | sed -r -e 's/.*\[([0-9]+)\/.*/\1/'
  }

  # Get a docker image id (or list of id's) by name (wildcards allowed)
  docker_get_image_id_by_name() {
    docker images -q "$1"
  }

  # Get a single docker container id by name
  docker_get_container_id_by_name() {
    docker ps -aqf "name=$1"
  }

  # Get container id of currently running container name
  docker_get_running_continer_id_by_name() {
    docker ps -qf "name=$1"
  }



  ## Useful Functions

  # Recursive File Contents Search function
  # $1 = Search string
  # $2 = (optional) File pattern (ex: *.js) (default is: *)
  # $3 = (optional) Set to 1 for case-insensitive search (default is: case-sensitive)
  search(){
    # Define Vars
    local sep=$'\x01' # Obscure ascii character not likely to appear in files
    local col_spacing=3
    local bold='\e[1m'
    local end='\e[0m'
    local green='\e[32m'
    local purple='\e[35m'
    local filter_swap_separators="s/^([^:]*):([^:]+):\s*(.*)$/\2$sep\1$sep\3/g"
    local filter_out_colors="\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]"
    local col_line_w=0 # Column containing the line number's max width
    local col_path_w=0 # Column containing the file path's max width
    local search name case_sensitive find col_line col_path col_data error message usage

    # Check for missing input
    if [[ -z "$1" ]]; then
      error="${bold}\e[37m\e[41m"
      message="${bold}\e[36m"
      usage="\n${bold}Recursive File Search${end}\n\n"
      usage="${usage}${error}Error: %s${end}\n\n${message}Usage:\n${end}"
      usage="${usage}search \"SEARCH_STRING\"                    (Search all files for case-sensitive matching)\n"
      usage="${usage}search \"SEARCH_STRING\" \"FILE_PATTERN\"     (For case-sensitive matching)\n"
      usage="${usage}search \"SEARCH_STRING\" \"FILE_PATTERN\" 1   (For case-insensitive matching)\n\n"
      usage="${usage}${message}Examples:${end}\n"
      usage="${usage}search \"undefined\" '*.js' 1\n"
      usage="${usage}search 'Fatal Error:' '*.log'\n\n"
      printf "$usage" "No search string given"
      return 1
    fi

    # Process user input
    search="$1"
    test -z "$2" && name='*' || name="$2"
    test "$3" == '1' && case_sensitive='i'

    # Run find command can capture the results into an array
    mapfile find < <( \
      find . -type f -name "$name" -exec grep -${case_sensitive}nH --color=always "$search" {} \; \
      | grep -v '^Binary' | uniq | sed -r -e "$filter_swap_separators" \
    )

    # loop through the first time to determine max column widths
    while read line; do
      while IFS="$sep" read -r col_line col_path col_data; do
        # Strip out color characters everywhere
        col_line_plain="$(echo "$col_line" | sed -r "s/$filter_out_colors//g")"
        col_path_plain="$(echo "$col_path" | sed -r "s/$filter_out_colors//g")"
        if [[ $col_line_w -lt ${#col_line_plain} ]]; then col_line_w=${#col_line_plain}; fi
        if [[ $col_path_w -lt ${#col_path_plain} ]]; then col_path_w=${#col_path_plain}; fi
      done < <(echo "${line[@]}")
    done < <(echo "${find[@]}")

    # Add some padding
    let col_line_w+=$col_spacing
    if [[ $col_line_w -lt $((4 + $col_spacing)) ]]; then
      col_line_w=$((4 + $col_spacing)) # Because the heading "Line" is 4 chars, make it at least that long
    fi
    let col_path_w+=$col_spacing

    # Print heading
    printf "${bold}%-${col_line_w}s%-${col_path_w}s%s${end}\n" "Line" "File Path" "Search Results"
    printf "${bold}%-${col_line_w}s%-${col_path_w}s%s${end}\n" "----" "---------" "---------------"

    # Loop through again to display output in columns
    while read line; do
      while IFS="$sep" read -r col_line col_path col_data; do
        col_line=$(echo "$col_line" | sed -r "s/$filter_out_colors//g")         # Strip out color codes everywhere
        col_path=$(echo "$col_path" | sed -r "s/$filter_out_colors//g")         # Strip out color codes everywhere
        col_data=$(echo "$col_data" | sed -r "s/^($filter_out_colors)*//g")     # Trim leading color codes only
        col_data=$(echo "$col_data" | sed -r -e 's/^[ \t]*//' -e 's/[ \t]*$//') # Trim leading/trailing spaces
        printf "${green}%-${col_line_w}s$end${purple}%-${col_path_w}s$end%s\n" "$col_line" "$col_path" "${col_data//^\w/}"
      done < <(echo "${line[@]}")
    done < <(echo "${find[@]}")
  }

  sphp(){ search "$1" '*.php'; }
  sphpi(){ search "$1" '*.php' 1; }
  scss(){ search "$1" '*.css'; }
  scssi(){ search "$1" '*.css' 1; }
  sjs(){ search "$1" '*.js'; }
  sjsi(){ search "$1" '*.js' 1; }
  searchall(){ search "$1" '*'; }
  searchalli(){ search "$1" '*' 1; }
  searchcount(){ echo; printf "\nMatches\tFilename\n-----\t--------------------------------\n$(\grep -RHn "$1" | grep -v '^Binary' | cut -d: -f1 | uniq -c)\n\n" | column -t; echo; }
  searchcounti(){ printf "\nMatches\tFilename\n-----\t--------------------------------\n$(\grep -iRHn "$1" | grep -v '^Binary' | cut -d: -f1 | uniq -c)\n\n" | column -t; }


  # Dump the call stacktrace, echo any args and exit
  die_stack() {
    local frame=0
    while caller $frame; do
      let frame++
    done
    echo "$*"
    exit 1
  }

  # Replace cd functionality to use pushd instead. If file is given, open in default editor.
  #
  # You can define an array of keyword-based pre-defined directories which will work anywhere
  # Examples:
  #   "cd bin" will take you to ~/bin/
  #   "cd logs" will take you to /var/log/apache2/
  # Setup:
  #   Inside your local_env.sh script, define them in this manner:
  #     cd_array=( \
  #       'bin'='/root/bin' \
  #       'www'='/var/www' \
  #       'logs'='/var/log/apache2' \
  #       'apache'='/etc/apache2/sites-available' \
  #     )
  cd(){
    if [[ "$#" == "0" ]]; then
      pushd $HOME 1>/dev/null
    elif [[ -f "$1" ]]; then
      $EDITOR "$1"
    elif [[ "$1" =~ ^\-+$ ]]; then
      # support multiple dashes and go back through dir stack for each one
      bd ${#1} 1>/dev/null
    elif [[ -d "$1" ]]; then
      pushd "$1" 1>/dev/null
    else
      # If an array called $cd_array is defined, loop through it and check for shortcuts
      # matching $1 to jump to a pre-defined location instead
      for i in "${cd_array[@]}"; do
        keyword=$(echo "$i" | cut -d= -f1)
        path=$(echo "$i" | cut -d= -f2)
        test "$1" == "$keyword" && local newdir="$path" && break
      done
      if [[ ! -z "$newdir" ]]; then
        pushd "$newdir" 1>/dev/null
      else
        printf "cd $1: No such file or directory\n"
      fi
    fi
  }

  # Add a "back directory" function to change back (with popd) any number of directories
  bd(){
    if [[ -z "$1" ]]; then
      popd &>/dev/null
    else
      for i in $(seq $1); do
        popd &>/dev/null
      done
    fi
  }

  # Simple calculator function
  calc() {
    awk "BEGIN{print $*}"
  }

  # Time command/script in hours/mins/secs
  time_cmd() {
    local time_start=$(date +%s%N)
    eval "$@"
    local time_end=$(date +%s%N)
    local time_elapsed=$(expr $time_end - $time_start)
    if [[ ${#time_elapsed} -lt 9 ]]; then
      local secs=0
      local nano=$time_elapsed
    else
      local secs=${time_elapsed:0:(-9)}
      local nano=${time_elapsed:(-9)}
    fi
    test ${#nano} -lt 9 && nano=$(printf "%09d" $nano)
    date -d@${secs}.${nano} -u "+Time taken: %Hh %Mm %Ss %Nns"
  }

  # Intelligent replacement for the cat command
  cat(){
    if [[ "$1" =~ \ -[beEnstTuv]*A[beEnstTuv]*\  ]]; then  # If passed with -A then use regular cat
      command cat "$@"
    elif [[ -d "$1" ]]; then           # Directory
      ls -l "$1"
    elif [[ "${@: -1}" =~ ^.*\.json$ ]] && [[ ! -z "$(which jq 2>&1 | grep -v 'no jq')" ]]; then  # If .json file then send through JQ (if installed)
      command cat "$@" | jq
    elif [[ "${@: -1}" =~ ^.*\.md$ ]] && [[ ! -z "$(which glow 2>&1 | grep -v 'no glow')" ]]; then  # If .md file then view with glow (if installed)
      glow "$@"
    elif [[ "$1" =~ ^\>.*$ ]]; then    # If concatenating multiple files use regular cat
      command cat "$@"
    elif [[ ! -z "$1" ]] && [[ ! -z "$(which ccat 2>&1 | grep -v 'no ccat')" ]]; then  # If ccat is installed use ccat
      ccat --bg=dark -G String=darkgreen -G Keyword=darkred -G Plaintext=white -G Plaintext=white -G Type=purple -G Literal=yellow -G Comment=purple -G Punctuation=white -G Tag=blue -G HTMLTag=darkgreen -G Decimal=white "$@"
    else                               # Else use regular cat
      command cat "$@"
    fi
  }

  # Return 1 for a number and 0 otherwise
  is_num() { if [[ "$1" =~ [0-9]+ ]]; then echo 1; else echo 0; fi; }

  # Returns 0 for binary and 1 for text
  is_binary(){ grep -m1 '^' $1 | grep -q '^Binary'; }

  # Set the window title to function arguments
  change_title(){ printf '\033]2;%s\007' "$(echo $@)"; }

  # Find a file or directory through parent directories
  find_up(){ p="$(pwd)"; while [[ "$p" != "" && ! -e "$p/$1" ]]; do p="${p%/*}"; done; echo "$p"; }

  # Find a file or directory through parent directories
  go_up(){ p="$(pwd)"; while [[ "$p" != "" && ! -e "$p/$1" ]]; do p="${p%/*}"; done; cd "$p"; }

  # Convert all mp3 files in the current directory to 64kbps versions and associate the first .jpg image as their cover art
  mp3_64(){ for i in *.mp3; do lame --preset cbr 64 --ti $(ls *.jpg | head -n1) $i ${i%.mp3}-64.mp3; done; }


  ## Display Alias Menu
  display_alias_menu() {

    repeat_string() {
      printf "%0.s$1" $(seq $2)
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
    [[ ! -x "$(which $cmd 2>&1 | grep -v 'no ')" ]] && printf "\e[31mError: $cmd is not installed\e[0m\n" && kill -INT $$

    # Check if pv is enabled and installed
    if [[ $usepv -eq 1 && -x "$(which pv 2>&1 | grep -v 'no pv')" ]]; then
      filesize=$(stat -c '%s' "$1")
      newfile="${1%%$ext}"

      # Handle special case for .zip since unzip command doesn't allow piping and funzip doesn't allow multiple files
      if [[ $ext == ".zip" ]]; then
        # If the .zip contains 1 file and if funzip and pv are installed we can show a progress bar
        if [[ $(zipinfo -t "$1" | awk '{print $1}') -eq 1 && -x "$(which funzip 2>&1 | grep -v 'no funzip')" ]]; then
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

  ## Include local_env.sh
  test ! -f ~/bin/local_env.sh && touch ~/bin/local_env.sh
  source ~/bin/local_env.sh

fi # End Check for interactive mode
