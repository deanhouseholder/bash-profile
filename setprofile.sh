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
url_git_bash_profile="https://github.com/deanhouseholder/bash-profile/archive/refs/heads/master.zip"
url_git_fzf="https://github.com/junegunn/fzf/archive/refs/heads/master.zip"
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
check_dependency tar
check_dependency unzip
check_dependency vim
check_dependency wget
if [[ $error == 1 ]]; then
  printf "\nError: Missing Dependencies\nPlease install the following apps before continuing:"
  printf " %s" "${apps_to_install[@]}"
  printf "\n\n"
  return 1
fi

# Check if git is installed
which git >/dev/null 2>&1
git_installed=$?

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
mkdir -p ~/.vim/undo

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
    if [[ -z "$prompt" ]] && [[ -n "$default" ]]; then
      prompt=$default
      passed=1
    fi

    # Valid input was entered, now assign it
    if [[ $passed -eq 1 ]]; then
      if [[ -n "$out_varname" ]]; then    # If user passed in a custom var name
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
  echo 'colorscheme desert' > ~/.vimrc
  echo 'syntax on                      " Turn on syntax highlighting for known filetypes' >> ~/.vimrc
  echo 'set number                     " Enable line numbers' >> ~/.vimrc
  echo 'set tabstop=4                  " Interpret tabs to be 4 characters' >> ~/.vimrc
  echo 'set expandtab                  " When pressing tab, insert 4 spaces' >> ~/.vimrc
  echo 'set shiftwidth=4               " Set the number of spaces for auto-indentation' >> ~/.vimrc
  echo 'set ignorecase                 " Case-insensitive searching' >> ~/.vimrc
  echo 'set smartcase                  " If searching with an uppercase, that search will be case-sensitive' >> ~/.vimrc
  echo 'set incsearch                  " Shows partial matches for a search phrase as you type' >> ~/.vimrc
  echo 'set autoindent                 " Continues the indentation from the previous line' >> ~/.vimrc
  echo 'set smartindent                " Automatically inserts indents in certain contexts, useful for code' >> ~/.vimrc
  echo 'set backspace=indent,eol,start " Makes the backspace key more intuitive' >> ~/.vimrc
  echo 'set mouse=a                    " Enables mouse support in all modes' >> ~/.vimrc
  echo 'set splitbelow                 " Sets default split behavior to be below' >> ~/.vimrc
  echo 'set encoding=utf-8             " Default to UTF-8 file encoding' >> ~/.vimrc
  echo 'set undofile                   " Persistant Undo' >> ~/.vimrc
  echo 'set undodir=~/.vim/undo        " Saves undo history per file. Make sure the directory exists' >> ~/.vimrc
  echo 'set foldmethod=syntax          " Enables code folding based on syntax' >> ~/.vimrc
  echo 'set foldlevelstart=10          " Sets a default open fold level to keep most code unfolded on open' >> ~/.vimrc
  echo 'set showmatch' >> ~/.vimrc
  echo '' >> ~/.vimrc
  echo '" Remember cursor line number within each file' >> ~/.vimrc
  echo 'au BufReadPost * if line("'\''\"") > 0 && line ("'\''\"") <= line("$") | exe "normal! g'\''\"" | endif' >> ~/.vimrc
fi

# Check if bash-profile is already installed, and if there are updates, prompt to update
if [[ -f "$file_profile" ]]; then
  if [[ $git_installed -eq 0 ]]; then
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
  fi
else
  if [[ $git_installed -eq 0 ]]; then
    mkdir -p "$dir_bash_profile"
    git clone -q "$repo_bash_profile" "$dir_bash_profile"
    echo "Installed via git"
  else
    cd "$dir_code"
    wget -q "$url_git_bash_profile" -O master.zip >/dev/null
    unzip -q master.zip
    mv bash-profile-master "$dir_bash_profile"
    rm master.zip
    cd - >/dev/null
    echo "Installed via zip"
  fi
fi
echo

# Configure Git
prompt_yn "Do you want to configure Git? [Y/n] " Y
echo
if [[ $yn == Y ]]; then

  # User confirmed they want to configure Git. Confirm git is installed
  if which git >/dev/null; then

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
            git config --global core.pager "delta --file-style=box --minus-style=#820005 --minus-emph-style=#a90008 --plus-style=#15600b --plus-emph-style=#218815 --theme=1337"
            git config --global delta.features "side-by-side line-numbers decorations"
            git config --global delta.whitespace-error-style "22 reverse"
            git config --global delta.decorations.commit-decoration-style "bold yellow box ul"
            git config --global delta.decorations.file-style "bold yellow ul"
            git config --global delta.decorations.file-decoration-style "none"
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
          git config --global delta.navigate "true"
          git config --global interactive.difffilter "delta --color-only"
          git config --global diff.colorMoved "default"
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
        if [[ ! -d "$dir_gitprompt" ]]; then
          printf "\nInstalling gitprompt...\n\n"
          git clone -q "$repo_gitprompt" "$dir_gitprompt"
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
        if [[ -n "$machine_name" ]]; then
          echo "$machine_name" > "$file_displayname"
          printf "\nalias set_title=\"change_title \$(cat ~/.displayname)\"\nset_title\n" >> $file_local_env
        else
          hostname > "$file_displayname"
        fi
      fi
    fi

  else
    printf "Git is not found in path\n\n"
  fi
fi


# Prompt to install fzf
which fzf &>/dev/null
if [[ $? -ne 0 ]]; then
  printf "\nSeveral functions can be enhanced by installing the fuzzy finder (fzf).\n"
  prompt_yn "Do you wish to install fzf? [Y/n] " Y
  if [[ $yn == Y ]]; then
    if [[ $git_installed -eq 0 ]]; then
      git clone --depth 1 -q "$repo_fzf" "$dir_fzf"
      echo
    else
      cd "$dir_code"
      wget -q "$url_git_fzf" -O master.zip >/dev/null
      unzip -q master.zip
      mv fzf-master "$dir_fzf"
      rm master.zip
      cd - 2>/dev/null
    fi
    yes | "$dir_fzf/install" --all --no-zsh --no-fish >/dev/null
  fi
  echo
fi

# Add auto loading of new profile.sh script in .bash_profile if it isn't there
if [[ -z "$(grep "source $file_profile" $file_startup 2>/dev/null)" ]]; then
  printf "\n# Include the bash profile\nsource $file_profile\n" >> $file_startup
fi

# Load new profile script
source "$file_profile" 2>/dev/null
source "$file_gitprompt" 2>/dev/null

# Clean up
unset dir_bin dir_code dir_bash_profile dir_gitprompt dir_ssh editor file_displayname file_git_ssh_keys file_gitprompt file_local_env file_profile file_startup git_installed repo_bash_profile repo_gitprompt machine_name url_git_ssh_keys url_git_bash_profile url_git_fzf user_email user_name yn file_tmp_delta dir_tmp_delta dir_delta_install

printf "\nDone\n\nYou can safely remove setprofile.sh if you want, or use it to pull updates.\n\n"
