#!/bin/bash
# setprofile.sh
# Description: This script will install Dean Householder's bash prompt
# URL: https://github.com/deanhouseholder/bash-profile

# Define variables
dir_bin=~/bin
dir_ssh=~/.ssh
dir_code=~/code
dir_bash_profile="$dir_code/bash-profile"
dir_gitprompt="$dir_code/gitprompt"
file_startup=~/.bash_profile
file_profile="$dir_bash_profile/profile.sh"
file_local_env="$dir_bin/local_env.sh"
file_git_ssh_keys="$dir_bin/ssh-keys.sh"
file_gitprompt="$dir_gitprompt/default-prompt.sh"
file_displayname=~/.displayname
url_bash_profile="https://raw.githubusercontent.com/deanhouseholder/bash-profile/master/profile.sh"
url_git_ssh_keys="https://raw.githubusercontent.com/deanhouseholder/ssh-keys/master/ssh-keys.sh"
repo_bash_profile="https://github.com/deanhouseholder/bash-profile.git"
repo_gitprompt="https://github.com/deanhouseholder/gitprompt.git"

# Start install script
printf "\nStarting configuration of bash profile\n"

# Set up directories
mkdir -p $dir_bin
chmod 700 $dir_bin
mkdir -p $dir_ssh
chmod 700 $dir_ssh
mkdir -p $dir_code
chmod 700 $dir_code

# Prompt for Y or N
# $1 = [optional] prompt to display
# $2 = [optional] default value if user presses Enter (Either "Y" or "N")
# $3 = [optional] variable name to capture (default is $yn)
# Set variable ($yn or $2) is always uppercase "Y" or "N"
prompt_yn() {
  local prompt default out_varname passed   # Define local vars
  [[ -z "$1" ]] || printf "$1"              # If prompt is set, display it
  [[ "$2" =~ ^[YyNn]$ ]] && default=${2^^}  # Set default if valid $2 is passed in
  [[ "$3" =~ ^[a-zA-Z0-9_]+$ ]] && out_varname=$3  # Ensure custom var name is safe to use

  # Infinate loop to read in one character. Break if any of: y, Y, n, N
  while true; do
    # Prompt for one character. Disable IFS to disambiguate between Space, Enter, ESC
    IFS= read -rsn 1 prompt

    # Check if Y or N was pressed
    if [[ "$prompt" =~ [yYnN] ]]; then
      prompt=${prompt^^}                    # Convert to uppercase
      passed=1
    fi

    # Check if Enter was pressed -- check for default $2 passed in
    if [[ -z "$prompt" ]] && [[ ! -z "$default" ]]; then
      prompt=$default
      passed=1
    fi

    # Valid input was entered, now assign it
    if [[ $passed -eq 1 ]]; then
      if [[ ! -z "$out_varname" ]]; then    # If user passed in a custom var name
        eval "$out_varname=$prompt"         # Set custom var name to the prompt value
      else
        yn=$prompt                          # Set a public variable to the value
      fi
      echo $prompt
      break                                 # Break out of the loop
    fi
  done
}

# If the local_env.sh doesn't exist or is 0 bytes
if [[ ! -s $file_local_env ]]; then
  printf "# Add any custom bash profile tweaks specific to this environment in this file\n\n" > $file_local_env
fi

# Add ssh-keys.sh if it doesn't exist
prompt_yn "\nDo you want to install/update ssh-keys script to manage your ssh keys? [y/N] " N
if [[ $yn == Y ]]; then
  curl -s "$url_git_ssh_keys" -o "$file_git_ssh_keys"
  if [[ -z "$(grep 'ssh_keys_load=' $file_local_env)" ]]; then
    printf "ssh_keys_load=()\nssh_keys_pass=()\nsource $file_git_ssh_keys\n\n" >> $file_local_env
  fi
fi

# If there is no EDITOR defined prompt for one
if [[ -z $(grep "EDITOR=" $file_local_env) ]]; then
  printf "\nWhich editor do you prefer? [vim], nano, emacs: "
  read editor
  test -z $editor && editor=vim
  echo "export EDITOR=$editor" >> $file_local_env
  echo
fi

# Add a .vimrc file to always turn on syntax highlighting and line numbers
if [[ ! -s ~/.vimrc ]]; then
  printf "syntax on\nset nu\nset tabstop=4\n" > ~/.vimrc
fi

# Download and auto-load bash-profile
# If file already exists, prompt to overwrite
if [[ -f "$file_profile" ]]; then
  prompt_yn "\nDo you want to update your copy of the bash-profile with the latest version? [Y/n] " Y
fi
# If ok to overwrite or file is not there, download it
if [[ $yn == "Y" ]] || [[ ! -f "$file_profile" ]]; then
  if [[ -d "$dir_bash_profile" ]]; then
    cd "$dir_bash_profile"
    git pull
  else
    cd "$dir_code"
    git clone "$repo_bash_profile"
  fi
  cd -
  echo
fi

# Add auto loading of new profile.sh script in .bashrc if it isn't there
if [[ -z "$(grep "source $file_profile" $file_startup)" ]]; then
  printf "\nsource $file_profile\n" >> $file_startup
fi

# Configure Git
prompt_yn "Do want to configure Git? [Y/n] " "Y"
echo

# User confirmed they want to configure Git
if [[ $yn == "Y" ]]; then

  if [[ -z "$(which git 2>&1 | grep -v 'no git')" ]]; then
    printf "Git is not installed! Please install then re-run $0\n\n"
    return
  fi

  # Configure git settings
  if [[ -z "$(git config --global user.name)" ]]; then
    read -p "What name would you like to use for git commits? (typically your full name) " user_name
    git config --global user.name "$user_name"
    echo
  fi
  if [[ -z "$(git config --global user.email)" ]]; then
    read -p "What email address would you like to use for git commits? " user_email
    git config --global user.email "$user_email"
    echo
  fi
  prompt_yn "Would you like to update your Git colors/options configuration? [Y/n] " Y
  if [[ "$yn" == "Y" ]]; then
      git config --global core.whitespace "fix,-indent-with-non-tab,trailing-space,cr-at-eol"
      git config --global format.pretty "%C(178)%h%Creset %C(110)%cd%Creset %C(85)%d %C(15)%s"
      git config --global color.branch "auto"
      git config --global color.interactive "auto"
      git config --global color.diff "auto"
      git config --global color.status "auto"
      git config --global color.ui "auto"
      git config --global color.branch.current "reverse 40"
      git config --global color.branch.local "40"
      git config --global color.branch.remote "166"
      git config --global color.diff.meta "116"
      git config --global color.diff.frag "15"
      git config --global color.diff.old "196"
      git config --global color.diff.new "76"
      git config --global color.status.added "40"
      git config --global color.status.changed "166"
      git config --global color.status.untracked "50"
      git config --global color.decorate.branch "40"
      git config --global color.decorate.remoteBranch "80"
      git config --global color.decorate.tag "166"
      git config --global color.decorate.stash "40"
      git config --global color.decorate.HEAD "50"
      git config --global push.default "simple"
  fi
  echo

  # Clone or update the gitprompt repo
  prompt_yn "Do want to install/update gitprompt? [Y/n] " "Y"
  if [[ $yn == "Y" ]]; then

    # Clone/Update gitprompt
    if [[ ! -d $dir_gitprompt ]]; then
      printf "\nSetting up gitprompt...\n\n"
      git clone $repo_gitprompt $dir_gitprompt
    else
      printf "\nUpdating the gitprompt repo...\n\n"
      cd $dir_gitprompt
      git pull
      cd -
    fi
    echo

    # Add auto loading of gitprompt in .bashrc if it isn't there
    if [[ -z "$(grep "source $file_gitprompt" $file_startup)" ]]; then
      printf "\n# Include the Git Prompt functions\nsource $file_gitprompt\n\n" >> $file_startup
    fi

    # Save the machine's name to .displayname
    if [[ ! -f $file_displayname ]]; then
      printf "\nWhat display name would you use for this machine (used in the title and prompt)?\n"
      read machine_name
      if [[ ! -z "$machine_name" ]]; then
        echo "$machine_name" > $file_displayname
        printf "\nalias set_title=\"change_title $(cat ~/.displayname)\"\nset_title\n" >> $file_local_env
      else
        hostname > $file_displayname
      fi
    fi
  fi
fi

# Load new profile script
source "$file_profile"
source "$file_gitprompt"

# Clean up
unset dir_bin dir_code dir_bash_profile dir_gitprompt dir_ssh editor file_displayname file_git_ssh_keys file_gitprompt file_local_env file_profile file_startup repo_bash_profile repo_gitprompt machine_name url_bash_profile url_git_ssh_keys user_email user_name yn

printf "\nDone\n\nYou can safely remove setprofile.sh if you want, or use it to pull updates.\n\n"
