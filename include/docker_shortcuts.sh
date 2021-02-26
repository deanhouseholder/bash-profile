## Docker Shortcuts

# Docker Aliases
if [[ "$bash_on_windows" -eq 1 ]]; then
  # This bash is running on Windows so use docker.exe
  [[ -x "$(type -fP winpty)" ]] && alias docker='winpty docker.exe' || alias docker='docker.exe'
  alias docker-compose='docker-compose.exe'
  alias docker-machine='docker-machine.exe'
fi
alias da='docker attach'
alias dbs='docker_build_and_start'
alias ddiff='docker diff'
alias di='docker images'
alias dins='docker inspect'
alias distart='docker_interactive_start_stop start'
alias distop='docker_interactive_start_stop stop'
alias doc='docker'
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

# Docker Compose
alias ddown='docker-compose stop'
alias dc='docker-compose'
alias dcbt='docker_compose_build_and_maybe_tag'
alias dclogs='docker-compose logs'
alias dcps='docker-compose ps'
alias dup='docker-compose up -d'

# Docker Machine
alias dm='echo "Switching docker-machine" && docker-machine'
alias dmnative='echo "Switching native docker" && eval $(dm env -u)'

# Interactive Docker start/stop function using fzf (fuzzy-finder)
# TODO: Add ability to start any image not just a stopped container
function docker_interactive_start_stop() {
  # If fzf is not installed, exit
  [[ -x "$(type -fP fzf)" ]] || { printf "Error: fzf is not installed\n"; return 1; }

  # Make sure Docker is ready
  docker_ready

  # Offer help if run with -h or --help
  if [[ "$1" =~ ^-{1,2}h[elp]?$ ]]; then
    echo "Usage: distart [start/stop]" && return 1
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
  [[ -x "$(type -fP fzf)" ]] || { printf "Error: fzf is not installed\n"; return 1; }

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
function docker_shell() {
  docker_ready
  if [[ $# -ne 1 ]]; then
    echo "Usage: dsh [CONTAINER_ID/CONTAINER_NAME]" && return 1
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
function docker_start_image_by_name() {
  if [[ $# -lt 1 ]]; then
    echo "Usage dstart [IMAGENAME]" && return 1
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
function docker_build_and_start() {
  if [[ $# -lt 1 ]]; then
    echo "Usage dbs TAGNAME [DIRNAME]" && return 1
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
function docker_compose_build_and_maybe_tag() {
  if [[ $# -lt 1 ]]; then
    echo "Usage dcbt DIRNAME [TAGNAME ...]" && return 1
  fi
  local args="$1"
  shift
  if [ $# -ge 2 ]; then
    args="$args -t $@"
  fi
  docker-compose build $args
}

# Get the Docker containers' locally-mapped port by name
function docker_get_local_listening_port_by_container_name() {
  docker inspect -f '{{.NetworkSettings.Ports}}' "$1" | sed -r -e 's/.* ([0-9]+)}.*/\1/'
}

# Get the Docker containers' internal service port number by name
function docker_get_internal_service_port_from_container_by_name() {
  docker inspect -f '{{.ContainerConfig.ExposedPorts}}' $(docker images -q "$1") | sed -r -e 's/.*\[([0-9]+)\/.*/\1/'
}

# Get a docker image id (or list of id's) by name (wildcards allowed)
function docker_get_image_id_by_name() {
  docker images -q "$1"
}

# Get a single docker container id by name
function docker_get_container_id_by_name() {
  docker ps -aqf "name=$1"
}

# Get container id of currently running container name
function docker_get_running_continer_id_by_name() {
  docker ps -qf "name=$1"
}
