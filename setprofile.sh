#!/bin/bash
# setprofile.sh
# Description: This script will install Dean Householder's bash prompt
# URL: https://github.com/deanhouseholder/bash-profile
#

# Define variables
dir_bin=~/bin
dir_ssh=~/.ssh
dir_code=~/code
dir_bash_profile="$dir_code/bash-profile"
dir_gitprompt="$dir_code/gitprompt"
dir_fzf="$dir_code/fzf"
dir_tmp_delta="/tmp/delta"
dir_delta_install=~/bin
file_startup=~/.bash_profile
file_profile="$dir_bash_profile/profile.sh"
file_local_env="$dir_bin/local_env.sh"
file_git_ssh_keys="$dir_bin/ssh-keys.sh"
file_gitprompt="$dir_gitprompt/default-prompt.sh"
file_displayname=~/.displayname
file_tmp_delta="/tmp/delta.tgz"
url_git_ssh_keys="https://raw.githubusercontent.com/deanhouseholder/ssh-keys/master/ssh-keys.sh"
repo_bash_profile="https://github.com/deanhouseholder/bash-profile.git"
repo_gitprompt="https://github.com/deanhouseholder/gitprompt.git"
repo_fzf="https://github.com/junegunn/fzf.git"
repo_delta="https://api.github.com/repos/dandavison/delta/releases/latest"
error=0
novim=0
apps_to_install=()

# Start install script
printf "\nStarting configuration of bash profile\n"

# Dependency Checks
function check_dependency() {
  which $1 &>/dev/null
  if [[ $? -ne 0 ]]; then
    error=1
    apps_to_install=(${apps_to_install[@]} $1)
  fi
}
check_dependency curl
check_dependency wget
check_dependency tar
check_dependency vim
check_dependency git
if [[ $error == 1 ]]; then
  printf "\nError: Missing Dependencies\nPlease install the following apps before continuing:"
  printf " %s" "${apps_to_install[@]}"
  printf "\n\n"
  return 1
fi

# Check for Mac
if [[ "$(uname)" == "Darwin" ]]; then
  bash_env='mac'
else
  bash_env='linux'
fi

# Set up directories
mkdir -p $dir_bin
chmod 700 $dir_bin
mkdir -p $dir_ssh
chmod 700 $dir_ssh
mkdir -p $dir_code
chmod 700 $dir_code

touch "$file_startup"

# Prompt for Y or N
# $1 = [optional] prompt to display
# $2 = [optional] default value if user presses Enter (Either "Y" or "N")
# $3 = [optional] variable name to capture (default is $yn)
# Set variable ($yn or $2) is always uppercase "Y" or "N"
unset prompt_yn
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
if [[ ! -f "$file_git_ssh_keys" ]]; then
  prompt_yn "\nDo you want to install/update ssh-keys script to manage your ssh keys? [y/N] " N
  if [[ $yn == Y ]]; then
    curl -s "$url_git_ssh_keys" -o "$file_git_ssh_keys"
    if [[ -z "$(grep 'ssh_keys_load=' $file_local_env)" ]]; then
      printf "ssh_keys_load=()\nssh_keys_pass=()\nsource $file_git_ssh_keys\n\n" >> $file_local_env
    fi
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

# Check if bash-prompt is already installed, and if there are updates, prompt to update
if [[ -f "$file_profile" ]]; then
  cd "$dir_bash_profile"
  if [[ "$(git fetch -q; git status | grep 'Your branch is behind' | wc -l)" -eq 1 ]]; then
    # Update bash-profile
    prompt_yn "Do want to update bash-profile to the latest version? [Y/n] " Y
    if [[ $yn == Y ]]; then
      git pull -q
      echo "Updated"
    else
      echo "Skipped"
    fi
  else
    echo "Your bash-profile is up-to-date."
  fi
  cd - >/dev/null
else
  mkdir -p "$dir_bash_profile"
  cd "$dir_bash_profile"
  git clone -q "$repo_bash_profile" .
  cd - >/dev/null
  echo "Installed"
fi
echo

# Configure Git
prompt_yn "Do plan to use Git? [Y/n] " Y
echo

# User confirmed they want to configure Git
if [[ $yn == Y ]]; then

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

  if [[ "$(git config --global format.pretty | grep '%C(178)%h%Creset %C(110)%cd%Creset %C(85)%d %C(15)%s' | wc -l)" == "0" ]]; then
    prompt_yn "Would you like to update your Git colors/options configuration? [Y/n] " Y
    if [[ "$yn" == Y ]]; then
        git config --global core.whitespace "fix,-indent-with-non-tab,trailing-space,cr-at-eol"
        git config --global format.pretty "| %C(178)%h%Creset | %C(110)%<(14)%ar%Creset | %C(85)%<(16)%an%Creset | %<(120,trunc)%s |"
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
  fi

  # Prompt to install delta if not installed
  if [[ ! -x "$dir_delta_install/delta" ]]; then
    prompt_yn "\nDo you want to install 'delta' for better git diff's? [Y/n] " Y
    if [[ $yn == Y ]]; then
      if [[ $bash_env == "mac" ]]; then
        delta_grep='_url.*-x86_64-apple-darwin.tar.gz'
      else
        delta_grep='_url.*-x86_64-unknown-linux-gnu.tar.gz'
      fi
      curl -s "$repo_delta" | grep -Ei $delta_grep | cut -d\" -f4 | wget -qi - -O "$file_tmp_delta"
      if [[ -f "$file_tmp_delta" ]]; then
        mkdir "$dir_tmp_delta"
        tar zxf "$file_tmp_delta" -C "$dir_tmp_delta" --strip-components=1
        cp "$dir_tmp_delta"/delta "$dir_delta_install/"
        cp "$dir_tmp_delta/README.md" "$dir_delta_install/delta-readme.md"
        rm "$file_tmp_delta"
        rm -rf "$dir_tmp_delta"
        if [[ -x "$dir_delta_install/delta" ]]; then
          git config --global core.pager "delta --file-style=box --minus-color=#820005 --minus-emph-color=#a90008 --plus-color=#15600b --plus-emph-color=#218815 --theme=1337"
          git config --global delta.features "side-by-side line-numbers decorations"
          git config --global delta.whitespace-error-style "22 reverse"
          git config --global delta.decorations.commit-decoration-style "bold yellow box ul"
          git config --global delta.decorations.file-style "bold yellow ul"
          git config --global delta.decorations.file-decoration-style "none"
          git config --global interactive.difffilter "delta --color-only"
          printf "Delta was installed successfully.\n\n"
        else
          printf "Failed to install delta\n\n"
        fi
      else
        printf "Failed to download delta\n\n"
      fi
    fi
  fi

  # Prompt to configure delta configs if delta is installed and configs are not present
  if [[ -x "$dir_delta_install/delta" ]]; then
    if [[ "$(git config --global core.pager | grep delta | wc -l)" == "0" ]]; then
      prompt_yn "Would you like to install git delta configs? [Y/n] " Y
      if [[ $yn == Y ]]; then
        git config --global core.pager "delta --file-style=box --minus-color=#820005 --minus-emph-color=#a90008 --plus-color=#15600b --plus-emph-color=#218815 --theme=1337"
        git config --global delta.features "side-by-side line-numbers decorations"
        git config --global delta.whitespace-error-style "22 reverse"
        git config --global delta.decorations.commit-decoration-style "bold yellow box ul"
        git config --global delta.decorations.file-style "bold yellow ul"
        git config --global delta.decorations.file-decoration-style "none"
        git config --global interactive.difffilter "delta --color-only"
      fi
    fi
  fi

  # Check if gitprompt is already installed and if there are updates, prompt to update
  if [[ -d "$dir_gitprompt" ]]; then
    cd "$dir_gitprompt"
    if [[ "$(git fetch -q; git status | grep 'Your branch is behind' | wc -l)" -eq 1 ]]; then
      # Update gitprompt
      prompt_yn "Do want to update gitprompt to the latest version? [Y/n] " Y
      if [[ $yn == Y ]]; then
        git pull -q
      fi
    fi
    cd - >/dev/null
  else
    # Install gitprompt
    printf "gitprompt provides a modern, nice-looking bash prompt which shows the current git branch "
    printf "with dirty/clean status, and other helpful status indicators.\n\nFor more information, see: "
    printf "https://github.com/deanhouseholder/gitprompt\n\n"
    prompt_yn "Do want to install gitprompt? [Y/n] " Y
    if [[ $yn == Y ]]; then
      if [[ ! -d $dir_gitprompt ]]; then
        printf "\nInstalling gitprompt...\n\n"
        git clone -q $repo_gitprompt $dir_gitprompt
      fi
    fi

    # Add auto-loading of gitprompt in .bash_profile if it isn't there
    if [[ -z "$(grep "source $file_gitprompt" $file_startup)" ]]; then
      printf "\n# Include the Git Prompt functions\nsource $file_gitprompt\n\n" >> $file_startup
    fi

    # Save the machine's name to .displayname
    if [[ ! -f "$file_displayname" ]]; then
      printf "\nWhat display name would you use for this machine (used in the title and prompt)?\n"
      read machine_name
      if [[ ! -z "$machine_name" ]]; then
        echo "$machine_name" > "$file_displayname"
        printf "\nalias set_title=\"change_title \$(cat ~/.displayname)\"\nset_title\n" >> $file_local_env
      else
        hostname > "$file_displayname"
      fi
    fi
  fi
fi

# Prompt to install fzf
which fzf &>/dev/null
if [[ $? -ne 0 ]]; then
  printf "\nSeveral functions can be enhanced by installing the fuzzy finder (fzf).\n"
  prompt_yn "Do you wish to install fzf? [Y/n] " Y
  if [[ $yn == Y ]]; then
    git clone --depth 1 -q "$repo_fzf" $dir_fzf
    echo
    $dir_fzf/install --all --no-zsh --no-fish >/dev/null
    printf "\n%s\n\n" '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' >> $file_startup
  fi
  echo
fi

# Add auto loading of new profile.sh script in .bash_profile if it isn't there
if [[ -z "$(grep "source $file_profile" $file_startup 2>/dev/null)" ]]; then
  printf "\n# Include the bash profile\nsource $file_profile\n" >> $file_startup
fi

# Load new profile script
source "$file_profile"
source "$file_gitprompt"

# Clean up
unset dir_bin dir_code dir_bash_profile dir_gitprompt dir_ssh editor file_displayname file_git_ssh_keys file_gitprompt file_local_env file_profile file_startup repo_bash_profile repo_gitprompt machine_name url_git_ssh_keys user_email user_name yn file_tmp_delta dir_tmp_delta dir_delta_install

printf "\nDone\n\nYou can safely remove setprofile.sh if you want, or use it to pull updates.\n\n"
