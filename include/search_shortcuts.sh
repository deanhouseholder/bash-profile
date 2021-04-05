# Recursive File Contents Search function
# $1 = Search string
# $2 = (optional) File pattern (ex: *.js) (default is: *)
# $3 = (optional) Set to 1 for case-insensitive search (default is: case-sensitive)
# Bug: Backslashes are not displaying in results. (ex: "\n" shows up as "n")
function search(){
  # Define Vars
  local sep=$'\x01' # Obscure ascii character not likely to appear in files
  local col_spacing=3
  local bold='\e[1m'
  local end='\e[0m'
  local green='\e[32m'
  local purple='\e[35m'
  local start_red_hex='1b5b313b33316d' # printf '\e[1;31m' | xxd -p
  local stop_red_hex='1b5b306d'        # printf '\e[0m' | xxd -p
  local filter_swap_separators="s/^([^:]*):([^:]+):\s*(.*)$/\2$sep\1$sep\3/g"
  local col_line_w=0 # Column containing the line number's max width
  local col_path_w=0 # Column containing the file path's max width
  local search name case_sensitive find_array col_line col_path col_data error message usage

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

  # Escape any semicolons in search input for safety with grep
  local escaped_search="$(printf "%s" "$search" | sed -e 's/;/\\;/g')"

  # To avoid difficulty allowing all search characters without sed confusing them for regex characters,
  # convert search input to hex characters where replace is simple.
  local search_hex="$(printf "%s" "$search" | xxd -p)" # Convert search into hex
  local replace_hex="$start_red_hex$search_hex$stop_red_hex"  # Build replacement string in hex

  # Run find command and capture the results into an array
  mapfile find_array < <( \
    find . -type f -name "$name" -exec grep -${case_sensitive}nH --fixed-strings "$escaped_search" {} \; \
    | grep -v '^Binary' | uniq | sed -r -e "$filter_swap_separators" \
  )

  # loop through the first time to determine max column widths
  while read line; do
    while IFS="$sep" read -r col_line col_path col_data; do
      if [[ $col_line_w -lt ${#col_line} ]]; then col_line_w=${#col_line}; fi
      if [[ $col_path_w -lt ${#col_path} ]]; then col_path_w=${#col_path}; fi
    done < <(echo "${line[@]}")
  done < <(echo "${find_array[@]}")

  # Add some padding
  let col_line_w+=$col_spacing
  if [[ $col_line_w -lt $((4 + $col_spacing)) ]]; then
    col_line_w=$((4 + $col_spacing)) # Because the heading "Line" is 4 chars, make it at least that long
  fi
  let col_path_w+=$col_spacing

  # Print heading
  printf "\n${bold}%-${col_line_w}s%-${col_path_w}s%s${end}\n" "Line" "File Path" "Search Results"
  printf   "${bold}%-${col_line_w}s%-${col_path_w}s%s${end}\n" "----" "---------" "---------------"

  # Loop through again to display output in columns
  while read line; do
    while IFS="$sep" read -r col_line col_path col_data; do
      # Add color to search string in results (Do search/replace in hex mode and then swap back)
      col_data="$(printf "%s" "$col_data" | xxd -p | sed "s/$search_hex/$replace_hex/g" | xxd -p -r)"
      printf "${green}%-${col_line_w}s$end${purple}%-${col_path_w}s$end%s\n" "$col_line" "$col_path" "${col_data//^\w/}"
    done < <(echo "${line[@]}")
  done < <(echo "${find_array[@]}")
}

function se(){    search "$1" "*.$2";    } # Search shortcut which puts in the *. prefix to a filetype for you
function si(){    search "$1" "*.$2";    } # Case-insensitive shortcut function
function sai(){   search "$1" '*' 1;     } # Search all files case-insensitive
function sphp(){  search "$1" '*.php';   } # Search PHP files
function sphpi(){ search "$1" '*.php' 1; } # Search PHP files case-insensitive
function scss(){  search "$1" '*.css';   } # Search CSS files
function scssi(){ search "$1" '*.css' 1; } # Search CSS files case-insensitive
function sjs(){   search "$1" '*.js';    } # Search JavaScript files
function sjsi(){  search "$1" '*.js' 1;  } # Search JavaScript files case-insensitive

# Search for a count of matches within each file
function searchcount(){
  local matches="$(command grep -RHn "$1" | grep -v '^Binary' | cut -d: -f1 | uniq -c)"
  printf "Matches\tFilename\n-----\t--------------------------------\n%s\n" "$matches" | column -t
}

# Search for a count of case-insensitive matches within each file
function searchcounti(){
  local matches="$(command grep -RHni "$1" | grep -v '^Binary' | cut -d: -f1 | uniq -c)"
  printf "Matches\tFilename\n-----\t--------------------------------\n%s\n" "$matches" | column -t
}
