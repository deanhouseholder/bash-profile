# Recursive File Contents Search function
# $1 = Search string
# $2 = (optional) File pattern (ex: *.js) (default is: *)
# $3 = (optional) Set to 1 for case-insensitive search (default is: case-sensitive)
# $4 = (optional) Comma-separated list of directories to ignore (format is: ".git,vendor,tmp")
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
  local fixed_strings='--fixed-strings '
  local search name case_sensitive find_array col_line col_path col_data error message usage

  # Ignore certain binary filetypes to speed up searching
  local filetypes_to_ignore=(class gif gpg gz jar jpeg jpg jrb pgp pgp_ png pp pyc 'so.*' tar zip)

  # Check for missing input
  if [[ -z "$1" ]]; then
    error="${bold}\e[37m\e[41m"
    message="${bold}\e[36m"
    local usage="\n${bold}Recursive File Search${end}\n\n"
    usage+="${error}Error: %s${end}\n\n${message}Usage:\n${end}"
    usage+="search SEARCH_PATTERN [FILE_PATTERN] [CASE_INSENSITIVE] [IGNORE_DIRS]\n\n"

    usage+="${message}Parameters:${end}\n"
    usage+="SEARCH_PATTERN       The string to be matched\n"
    usage+="FILE_PATTERN         File matching pattern such as '*.php'\n"
    usage+="CASE_INSENSITIVE     0 for case-sensitive search (default), 1 for case-insensitive\n"
    usage+="IGNORE_DIRS          Comma-separated list of directories to ignore\n\n"

    usage+="${message}Examples:${end}\n"
    usage+="search '.ajax' '*.js' 1\n"
    usage+="search 'Fatal Error:' '*.log'\n"
    usage+="search '<div class=\"d-flex\">' '*' 0 '.git,bin,vendor'\n\n"

    printf "$usage" "No search string given"
    return 1
  fi

  # Process user input
  search="$1"
  [[ -z "$2" ]] && name='*' || name="$2"
  [[ "$name" == "*." ]] && name='*'
  [[ "$3" == "1" ]] && case_sensitive='i'

  # Build out switches to ignore directories
  if [[ ! -z "$4" ]]; then
    IFS=',' read -r -a paths_to_ignore <<< "$4"

    # Expand out the array of paths to match this syntax:
    # -path "*/tmp*" -prune -o -path "*/.git*" -prune -o -path "*/app*" -prune -o
    local ignore_paths=""
    for path in ${paths_to_ignore[@]}; do
      ignore_paths+=" -path \"*/${path}/*\" -prune -o"
    done
  fi

  # Expand out the array of filetypes
  local ignore_filetypes=""
  for filetype in ${filetypes_to_ignore[@]}; do
    ignore_filetypes+=" -name '*.${filetype}' -prune -o"
  done

  # Escape any semicolons in search input for safety with grep
  local escaped_search="$(printf -- "%s" "$search" | sed -e 's/;/\;/g')"
  if [[ "$search" == ';' ]]; then # Special case if search is just a semicolon
    fixed_strings=''
    escaped_search='\;'
  fi

  # To avoid difficulty allowing all search characters without sed confusing them for regex characters,
  # convert search input to hex characters where replace is simple.
  local search_hex="$(printf -- "%s" "$search" | xxd -p -c 1000000)" # Convert search into hex
  local replace_hex="$start_red_hex$search_hex$stop_red_hex"  # Build replacement string in hex

  # Perform search and capture the results into an array
  mapfile find_array < <( \
    eval "find . $ignore_paths $ignore_filetypes -type f -name '$name' -exec grep -${case_sensitive}nH --color=never $fixed_strings -- '$escaped_search' {} \; \
      | grep -v -- '^Binary' | uniq | sed -r -e '$filter_swap_separators'" \
  )

  # loop through the first time to determine max column widths and total count
  local count=0
  while read line; do
    while IFS="$sep" read -r col_line col_path col_data; do
      [[ ! -z "$col_data" ]] && let count++
      [[ $col_line_w -lt ${#col_line} ]] && col_line_w=${#col_line}
      [[ $col_path_w -lt ${#col_path} ]] && col_path_w=${#col_path}
    done < <(echo "${line[@]}")
  done < <(echo "${find_array[@]}")

  # Add some padding
  let col_line_w+=$col_spacing
  if [[ $col_line_w -lt $((4 + $col_spacing)) ]]; then
    col_line_w=$((4 + $col_spacing)) # Because the heading "Line" is 4 chars, make it at least that long
  fi
  let col_path_w+=$col_spacing

  if [[ $count -eq 0 ]]; then
    printf "\nNo matches found\n\n"
  else
    # Print heading
    printf "\n${bold}%-${col_line_w}s%-${col_path_w}s%s${end}\n" "Line" "File Path" "Search Results"
    printf   "${bold}%-${col_line_w}s%-${col_path_w}s%s${end}\n" "----" "---------" "---------------"

    # Loop through again to display output in columns
    while read line; do
      while IFS="$sep" read -r col_line col_path col_data; do
        if [[ ! -z "$col_data" ]]; then
          # Add color to search string in results (Do search/replace in hex mode and then swap back)
          col_data="$(printf -- "%s" "$col_data" | xxd -p -c 1000000 | sed -- "s/$search_hex/$replace_hex/g" | xxd -p -r)"
          printf -- "${green}%-${col_line_w}s$end${purple}%-${col_path_w}s$end%s\n" "$col_line" "$col_path" "${col_data//^\w/}"
        fi
      done < <(echo "${line[@]}")
    done < <(echo "${find_array[@]}")
    printf "\nMatches found: $count\n\n"
  fi
}

function se(){    search "$1" "*.$2" 0 "$3";   } # Search shortcut which puts in the *. prefix to a filetype for you
function si(){    search "$1" "*.$2" 1 "$3";   } # Case-insensitive shortcut function
function sphp(){  search "$1" '*.php' $2 "$3"; } # Search PHP files
function scss(){  search "$1" '*.css' $2 "$3"; } # Search CSS files
function sjs(){   search "$1" '*.js' $2 "$3";  } # Search JavaScript files

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
