# Replace cd functionality to use pushd instead. If file is given, open in default editor.
#
# You can define an array of keyword-based pre-defined directories which will work anywhere
# Examples:
#   "cd bin" will take you to ~/bin/
#   "cd logs" will take you to /var/log/apache2/
# Setup:
#   Inside your local_env.sh script, define them in this manner:
#     cd_array=(
#       'bin'='/root/bin'
#       'www'='/var/www'
#       'logs'='/var/log/apache2'
#       'apache'='/etc/apache2/sites-available'
#     )
function cd(){
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
# Display a list of cd aliases
# TODO: enhance with fzf
alias cdlist='printf "\nList of cd aliases:\n\n" && printf "%s\n" ${cd_array[@]} | column -t -s= && echo'

# Add a "back directory" function to change back (with popd) any number of directories
function bd(){
  if [[ -z "$1" ]]; then
    popd &>/dev/null
  else
    for i in $(seq $1); do
      popd &>/dev/null
    done
  fi
}


# Intelligent replacement for the cat command
cat(){
  if [[ "$1" =~ \ -[beEnstTuv]*A[beEnstTuv]*\  ]]; then  # If passed with -A then use regular cat
    command cat "$@"
  elif [[ -d "$1" ]]; then           # Directory
    ls -l "$1"
  elif [[ "${@: -1}" =~ ^.*\.json$ ]] && [[ -x "$(type -fP jq)" ]]; then  # If .json file then send through JQ (if installed)
    command cat "$@" | jq
  elif [[ "${@: -1}" =~ ^.*\.md$ ]] && [[ -x "$(type -fP glow)" ]]; then  # If .md file then view with glow (if installed)
    glow "$@"
  elif [[ "$1" =~ ^\>.*$ ]]; then    # If concatenating multiple files use regular cat
    command cat "$@"
  elif [[ ! -z "$1" ]] && [[ -x "$(type -fP ccat)" ]]; then  # If ccat is installed use ccat
    ccat --bg=dark -G String=darkgreen -G Keyword=darkred -G Plaintext=white -G Plaintext=white -G Type=purple -G Literal=yellow -G Comment=purple -G Punctuation=white -G Tag=blue -G HTMLTag=darkgreen -G Decimal=white "$@"
  else                               # Else use regular cat
    command cat "$@"
  fi
}


## Extract function with progress bars where possible
function e() {
  # Exit the function if the file is not found
  if [[ ! -f "$1" ]]; then
    printf "\n\e[31mERROR: Couldn't find file to extract.\e[0m\n"
    return 1
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
      return 1
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
    *)          printf "\e[31mError: Cannot determine how to extract '$1'\e[0m\n" && return 1;;
  esac

  printf "\e[32mExtracting $filename\e[0m\n"

  # Check if extraction command is installed/executable
  [[ -x "$(type -fP fzf)" ]] || printf "\e[31mError: $cmd is not installed\e[0m\n" && return 1

  # Check if pv is enabled and installed
  if [[ $usepv -eq 1 ]] && [[ -x "$(type -fP pv)" ]]; then
    filesize=$(stat -c '%s' "$1")
    newfile="${1%%$ext}"

    # Handle special case for .zip since unzip command doesn't allow piping and funzip doesn't allow multiple files
    if [[ $ext == ".zip" ]]; then
      # If the .zip contains 1 file and if funzip and pv are installed we can show a progress bar
      if [[ $(zipinfo -t "$1" | awk '{print $1}') -eq 1 ]] && [[ -x "$(type -fP funzip)" ]]; then
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
