# Start of apt-specific functions
if [[ -x "$(type -fP apt)" ]]; then   # Only load if apt is present

  # fzf start service(s)
  function start() {
    printf "Generating list of stopped running services\r"
    service --status-all 2>&1 | grep '\[ \- \]' | awk '{print $4}' \
    | fzf --tac -0 -m --prompt="Choose service(s) to start: " \
    | while read service; do
        printf "Starting $service\e[K\n"
        sudo service $service start
      done
    printf "\e[K"
  }

  # fzf stop service(s)
  function stop() {
    printf "Generating list of running services\r"
    service --status-all 2>&1 | grep '+' | awk '{print $4}' \
    | fzf --tac -0 -m --prompt="Choose service(s) to stop: " \
    | while read service; do
        printf "Stopping $service\e[K\n"
        sudo service $service stop
      done
    printf "\e[K"
  }

  # fzf restart service(s)
  function restart() {
      printf "Generating list of services\r"
      service --status-all 2>&1 | awk '{print $4}' \
      | fzf --tac -0 -m --prompt="Choose service(s) to restart: " \
      | while read service; do
          printf "Restarting $service\e[K\n"
          sudo service $service restart
        done
    printf "\e[K"
  }

  # fzf check the status of service(s)
  function status() {
    printf "Generating list of running services\r"
    service --status-all 2>&1 | grep '+' | awk '{print $4}' \
    | fzf --tac -0 -m --prompt="Choose service(s) to see the status: " \
    | while read service; do
        printf "\e[K\n=====================================\n\nDisplaying status for $service\n\n"
        sudo service $service status
      done
     printf "\e[K"
  }


  # Check dependencies: fzf and column
  if [[ -x "$(type -fP fzf)" ]] && [[ -x "$(type -fP column)" ]]; then

    alias afu='apt_fuzzy_upgrade'
    alias afi='apt_fuzzy_install'
    alias afun='apt_fuzzy_uninstall'


    # Display apt packages available for update and prompt user to selectively select for install
    function apt_fuzzy_upgrade() {
      # Check for apt updates
      sudo apt update

      # Get list of packages, pass to fzf, update selected
      sudo apt list --upgradable 2>/dev/null | sed '1d' | \
        sed -E -e 's/^([^\/]+)\/[^0-9]*([0-9\.\-]+)[^\[]*\[[^0-9]*([^\+]+).*$/\1@\3@➤@\2/g' | column -t -s@ | \
        fzf --tac -m -0 | sed -E -e 's/^([^ ]+).*/\1/g' | sudo xargs apt install -y
    }


    # Allow user to interactively select packages to be installed based on input
    # TODO: allow for a parameter that switches modes from "contains" to "starts-with" to "exact"
    function apt_fuzzy_install() {
      # Check input
      if [[ -z "$1" ]]; then
        printf "Error: No package to search the apt package repo was specified.\n\nUSAGE: afi [package_name]\n"
        return 1
      fi

      # Check for apt updates
      sudo apt update

      # Search apt for packages matching input, display with fuzzy finder with full preview, install selected
      sudo apt search $1 2>/dev/null | sed '1,2d' | egrep '^([^ ].*)$' | \
        sed -E -e 's/([^/]+)\/.* (\[[a-z,\])/\1@\2/g' -e 's/([^/]+)\/.*/\1/g' | column -t -s@ | \
        fzf -0 -m --tac --preview="echo {} | awk '{print \$1}' | xargs apt-cache show --no-all-versions |
        sed -E -e 's/^Description-en: (.*)$/\fDescription: \1\n/' -e 's/^Description-md5.*/\f/' |
        awk 'BEGIN{RS=\"\f\"}/Description/{print}' | sed -E -e 's/^\W*\.$//g' -e 's/^\W*(.*)$/\1/g'" | sudo xargs apt install -y
    }


    function apt_fuzzy_uninstall() {
      # Check dependencies
      [[ -x "$(type -fP fzf)"    ]] || { printf "fzf is required but not installed.\n";   return 1; }
      [[ -x "$(type -fP column)" ]] || { printf "column is required but not installed\n"; return 1; }

      sudo apt list --installed 2>/dev/null | sed '1d' | grep -v ',automatic]' | \
        sed -E -e 's/([^\/]+)\/.* ([0-9\.\-]+).*/\1@\2/g' | column -t -s@ | \
        fzf -0 -m --tac --preview="echo {} | awk '{print \$1}' | xargs apt-cache show --no-all-versions |
        sed -E -e 's/^Description-en: (.*)$/\fDescription: \1\n/' -e 's/^Description-md5.*/\f/' |
        awk 'BEGIN{RS=\"\f\"}/Description/{print}' | sed -E -e 's/^\W*\.$//g' -e 's/^\W*(.*)$/\1/g'" | \
        awk '{print $1'} | sudo xargs apt remove -y
    }

  fi

# End of apt-specific functions
fi


# Interactive Cheat Sheet lookup
function icheat() {
  curl -ks cht.sh/$(curl -ks cht.sh/:list | fzf --preview 'curl -ks cht.sh/{}' -q "$*";)
}
