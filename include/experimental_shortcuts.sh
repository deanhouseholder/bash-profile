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
function cd() {
  if [[ $# -eq 0 ]]; then # If no options passed in cd to $HOME
    pushd $HOME 1>/dev/null
  elif [[ -f "$1" ]]; then # If a file is passed in, edit it in default $EDITOR otherwise use nano
    [[ -n "$EDITOR" ]] && $EDITOR "$1" || nano "$1"
  elif [[ "$1" =~ ^\-+$ ]]; then # If input is any number of dashes go back through dir stack for each one
    bd ${#1} 1>/dev/null
  elif [[ -d "$1" ]]; then # If a dir is passed in, cd into it and add it to the dir stack
    pushd "$1" 1>/dev/null
  else
    # If an array called $cd_array is defined, loop through it and check for shortcuts
    # matching $1 to jump to a pre-defined location instead
    for i in "${cd_array[@]}"; do
      keyword=$(echo "$i" | cut -d= -f1)
      path=$(echo "$i" | cut -d= -f2)
      test "$1" == "$keyword" && local newdir="$path" && break
    done
    if [[ -n "$newdir" ]]; then
      pushd "$newdir" 1>/dev/null
    else
      printf "cd $1: No such file or directory\n"
    fi
  fi
}
# Display a list of cd aliases
alias cdlist='printf "\nList of cd aliases:\n\n" && printf "%s\n" ${cd_array[@]} | column -t -s= && echo'
# Display interactive list of cd aliases if fzf is installed
alias cdi='[[ -x $(type -fP fzf) ]] && cd "$(( cdlist ) | sed '1,3d' | fzf --tac -0 | awk '\''{print $2}'\'')" || echo fzf is not installed'
alias cdb='[[ -x $(type -fP fzf) ]] && cd "$(dirs | sed -e "s/ /\n/g" | fzf --tac -0)" || echo fzf is not installed'

# Add a "back directory" function to change back (with popd) any number of directories
function bd() {
  if [[ -z "$1" ]]; then
    popd &>/dev/null
  else
    for i in $(seq $1); do
      popd &>/dev/null
    done
  fi
}


# Intelligent replacement for the cat command
function cat() {
  if [[ ! -t 1 ]]; then                                                   # If output is a pipe/redirect use cat (checks if stdout is not a terminal)
    command cat "$@"
  elif [[ "$*" =~ -[beEnstTuv]*A[beEnstTuv]* ]]; then                 # If passed with -A then use regular cat
    command cat "$@"
  elif [[ -d "$1" ]]; then                                                # Directory provided, so show a list of the files
    ls -l "$@"
  elif [[ "${@: -1}" =~ ^.*\.json$ ]] && [[ -x "$(type -fP jq)" ]]; then  # If .json file then send through JQ (if installed)
    command cat "$@" | jq
  elif [[ "${@: -1}" =~ ^.*\.md$ ]] && [[ -x "$(type -fP glow)" ]]; then  # If .md file then view with glow (if installed)
    glow "$@"
  elif [[ -n "$1" ]] && [[ -x "$(type -fP batcat)" ]]; then             # If batcat is installed, use it
    batcat "$@"
  elif [[ -n "$1" ]] && [[ -x "$(type -fP ccat)" ]]; then               # If ccat is installed, use it with better colors
    ccat --bg=dark -G String=yellow -G Keyword=darkred -G Comment=faint -G Type=darkgreen -G Literal=yellow -G Punctuation=lightgray -G Plaintext=lightgray -G Tag=blue -G HTMLTag=darkgreen -G Decimal=purple "$@"
  else                                                                    # Else use regular cat
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
  local filepath="$1"
  local filename="$(basename $1)"
  local dir="$(pwd)"

  case "$1" in
    *.7z)       ext=".7z";       cmd="7z";          options="x";      usepv=0;;
    *.tar.bz2)  ext=".tar.bz2";  cmd="tar";         options="-jxvf";  usepv=0;;
    *.tbz2)     ext=".tbz2";     cmd="tar";         options="-jxvf";  usepv=0;;
    *.tar.gz)   ext=".tar.gz";   cmd="tar";         options="-zxvf";  usepv=0;;
    *.tgz)      ext=".tgz";      cmd="tar";         options="-zxvf";  usepv=0;;
    *.tar)      ext=".tar";      cmd="tar";         options="-xvf";   usepv=0;;
    *.rar)      ext=".rar";      cmd="unrar";       options="x";      usepv=0;;
    *.Z)        ext=".Z";        cmd="uncompress";  options="";       usepv=0;;
    *.bz2)      ext=".bz2";      cmd="bunzip2";     options="";       usepv=1;;
    *.gz)       ext=".gz";       cmd="gunzip";      options="";       usepv=1;;
    *.zip)      ext=".zip";      cmd="unzip";       options="";       usepv=1;;
    *)          printf "\e[31mError: Cannot determine how to extract '$1'\e[0m\n" && return 2;;
  esac

  local filename_without_ext="${filename%$ext}"
  printf "\nExtract \e[36m$filename\e[0m into \e[36m$dir\e[0m\n\n"

  local count=$(\ls | wc -l | awk '{print $1}')
  if [[ $count -ne 0 ]]; then
    printf "\e[33mWARNING: The current directory is not empty!\e[0m\n\n"
    printf "Would you like to:\n1. Proceed anyway\n2. Extract to a subdirectory called '$filename_without_ext'\nC. Cancel\n"
    read -sn 1 prompt
    if [[ ! $prompt =~ [12] ]]; then
      printf "\nCancelled\n\n"
      return 3
    elif [[ $prompt == 2 ]]; then
      # Check if new dir exists
      if [[ -d "$filename_without_ext" ]]; then
        printf "\n\e[33mWARNING: The directory '$filename_without_ext' already exists!\e[0m\n\nCancelling\n\n"
        return 4
      fi

      # If using tar, use --one-top-level to create the new dir and prevent nested dirs with the same name
      if [[ $cmd == "tar" ]]; then
        options="--one-top-level $options"
      else
        # Make a new dir
        mkdir "$filename_without_ext"
        cd "$filename_without_ext"
        filepath="../$filepath"
      fi
    fi
  fi

  printf "\n\e[32mExtracting $filename\e[0m\n\n"

  # Check if extraction command is installed/executable
  [[ -x "$(type -fP fzf)" ]] || ( printf "\e[31mError: $cmd is not installed\e[0m\n" && return 5 )

  # Check if pv is enabled and installed
  if [[ $usepv -eq 1 ]] && [[ -x "$(type -fP pv)" ]]; then
    filesize=$(stat -c '%s' "$filepath")
    newfile="$filename_without_ext"

    # Handle special case for .zip since unzip command doesn't allow piping and funzip doesn't allow multiple files
    if [[ $ext == ".zip" ]]; then
      # If the .zip contains 1 file and if funzip and pv are installed we can show a progress bar
      if [[ $(zipinfo -t "$filepath" | awk '{print $filepath}') -eq 1 ]] && [[ -x "$(type -fP funzip)" ]]; then
        cat "$filepath" | pv -s $filesize -i 0.1 -D 0 | funzip > "$newfile"
      else
        unzip "$filepath"
      fi
    else
      # Use pv command to show progress bars
      cat "$filepath" | pv -s $filesize -i 0.1 -D 0 | $cmd $options > $newfile
    fi
  else
    # Run command
    $cmd $options "$filepath"
  fi
  cd "$dir"
  printf "\nDone\n\n"
}

# Colorize Output
# Usage: cat logfile | red error | green success
co() {
  case "$1" in
      black)  color='0;30';;
      dgray)  color='1;30';;
      red)    color='1;31';;
      green)  color='0;32';;
      lgreen) color='1;32';;
      honey)  color='0;33';;
      yellow) color='1;33';;
      blue)   color='1;34';;
      purple) color='0;35';;
      pink)   color='1;35';;
      lblue)  color='0;36';;
      cyan)   color='1;36';;
      gray)   color='0;37';;
      white)  color='1;37';;
      *)      color='1;34';;
  esac

  while IFS= read -r line; do
    if [[ -z "$2" ]]; then
      echo "$line"
    else
      echo "$line" | sed "s/$2/\x1b[0;${color}m$2\x1b[0m/g"
    fi
  done
}
alias black='co black'
alias blue='co blue'
alias cyan='co cyan'
alias dgray='co dgray'
alias gray='co gray'
alias green='co green'
alias honey='co honey'
alias lblue='co lblue'
alias lgreen='co lgreen'
alias pink='co pink'
alias purple='co purple'
alias red='co red'
alias white='co white'
alias yellow='co yellow'

# Colorize Background
# Usage: cat logfile | bred error | bgreen success
cb() {
  case "$1" in
      black)  color="1;40";;
      red)    color="1;41";;
      green)  color="1;42";;
      yellow) color="1;43";;
      blue)   color="1;44";;
      purple) color="1;45";;
      cyan)   color="1;46";;
      gray)   color="1;47";;
      *)      color="1;44";;
  esac

  while IFS= read -r line; do
    if [[ -z "$2" ]]; then
      echo "$line"
    else
      echo "$line" | sed "s/$2/\x1b[0;${color}m$2\x1b[0m/g"
    fi
  done
}
alias bblack='cb black'
alias bred='cb red'
alias bgreen='cb green'
alias byellow='cb yellow'
alias bblue='cb blue'
alias bpurple='cb purple'
alias bcyan='cb cyan'
alias bgray='cb gray'

# Colorize Background for Whole Line
# Usage: cat logfile | blred error | blgreen success
cbl() {
  case "$1" in
      black)  color="1;40";;
      red)    color="1;41";;
      green)  color="1;42";;
      yellow) color="1;43";;
      blue)   color="1;44";;
      purple) color="1;45";;
      cyan)   color="1;46";;
      gray)   color="1;47";;
      *)      color="1;44";;
  esac

  while IFS= read -r line; do
    if [[ -z "$2" ]]; then
      echo "$line"
    else
      echo "$line" | sed "s/\(.*$2.*\)/\x1b[0;${color}m\1\x1b[0m/g"
    fi
  done
}
alias blblack='cbl black'
alias blred='cbl red'
alias blgreen='cbl green'
alias blyellow='cbl yellow'
alias blblue='cbl blue'
alias blpurple='cbl purple'
alias blcyan='cbl cyan'
alias blgray='cbl gray'

# Simple function to list all available color aliases
listcolors() {
  printf "Foreground colors:\n%s\n\n" "$(alias | grep "'co " | cut -d= -f1 | cut -d' ' -f2)"
  printf "Background colors:\n%s\n\n" "$(alias | grep "'cb " | cut -d= -f1 | cut -d' ' -f2)"
  printf "Background colors for whole line:\n%s\n\n" "$(alias | grep "'cb " | cut -d= -f1 | cut -d' ' -f2)"
}
