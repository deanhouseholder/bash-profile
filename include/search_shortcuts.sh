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
