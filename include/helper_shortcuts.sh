# Changing Directories up
# "up" will cd up a directory or if you pass in a number it will cd up that many times
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

# Empty/not-empty functions. Usage:
# empty "$var" && set_var
# not_empty && clear_var
function empty()[[ -z "$1" ]]
function not_empty()[[ -n "$1" ]]

# Check if a file is of a given type
function is_binary()[[ "$(file -b --mime-encoding "$1")" == "binary" ]]
function is_ascii()[[ "$(file -b --mime-encoding "$1")" =~ "ascii" ]]
function is_utf8(){ iconv -f UTF-8 "$1" -t UTF-8 -o /dev/null; }

# Time command/script in hours/mins/secs
function time_cmd() {
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

# Dump the call stacktrace, echo any args and exit
function die_stack() {
  local frame=0
  while caller $frame; do
    let frame++
  done
  echo "$*"
  exit 1
}

# Simple calculator function
function calc() {
  awk "BEGIN{print $*}"
}

# Return 0 for a number and 1 otherwise
function is_num()[[ "$1" =~ [0-9]+ ]]

# Set the window title to function arguments
function change_title(){ test -z "$1" && printf "No title passed to function\n" || printf '\033]0;%s\007' "$(echo $@)"; }

# Find a file or directory through parent directories
function find_up(){ local p="$(pwd)"; while [[ "$p" != "" && ! -e "$p/$1" ]]; do p="${p%/*}"; done; echo "$p"; }

# Find a file or directory through parent directories
function go_up(){ local p="$(pwd)"; while [[ "$p" != "" && ! -e "$p/$1" ]]; do p="${p%/*}"; done; cd "$p"; }

# ls with octal permission labels
function lso () {
  test -z "$1" && local dirname="." || local dirname="$1"
  ls -lF --color "$dirname" | sed -e 's/--x/1/g' -e 's/-w-/2/g' -e 's/-wx/3/g' -e 's/r--/4/g' -e 's/r-x/5/g' -e 's/rw-/6/g' -e 's/rw[xt]/7/g' -e 's/---/0/g'
}

# Get an ordered list of subdirectory sizes
function big () {
  \ls -d */ .*/ | grep -vE -e '^\.+/$' | sed -E 's/(.*)\//\1/' | xargs du -sk | sort -n | awk 'BEGIN{ pref[1]="K"; pref[2]="M"; pref[3]="G";} { total = total + $1; x = $1; y = 1; while( x > 1024 ) { x = (x + 1023)/1024; y++; } printf("%g%s\t%s\n",int(x*10)/10,pref[y],$2); } END { y = 1; while( total > 1024 ) { total = (total + 1023)/1024; y++; } printf("Total: %g%s\n",int(total*10)/10,pref[y]); }'
}

# Check if a binary exists
# Usage: [[ $(bin_exists fzf) -eq 0 ]]
function bin_exists() {
  [[ -x "$(type -fP $1)" ]] && { echo 0; } || { echo 1; }
}

# Call to the cheat.sh Cheat Sheet site for a search
function cheat() {
  if [[ -z "$1" ]]; then
    echo "You forgot to pass in what to search for"
    exit 1
  fi
  curl cheat.sh/$(echo $@ | tr ' ' /)
}

# Reverse DNS Lookup
function rdns() {
  dig +short -x $1
}

# Add directory to path if not present
# Appends to end by default. Pass in "pre" to prepend new dir to path instead.
path_add() {
  if ! echo "$PATH" | grep -Eq "(^|:)$1($|:)"; then
     test "$2" == "pre" && export PATH=$1:$PATH || export PATH=$PATH:$1
  fi
}

# Show a log of internet connection status
pingloop() {
  while true; do
    printf "%s\t" "$(date '+%r')"
    if (echo >/dev/tcp/google.com/443) &>/dev/null; then
      echo -e "\e[1;32mOnline\e[0m"
    else
      echo -e "\e[1;31mOffline\e[0m"
    fi
    sleep 5
  done
}

