#!/bin/bash
# setprofile.sh
# Description: This script will install Dean Householder's bash prompt
# URL: https://github.com/deanhouseholder/bash-profile

# Define variables
dir_bin=~/bin
dir_ssh=~/.ssh
file_startup=~/.bashrc
file_profile=$dir_bin/profile.sh
file_git_menu=$dir_bin/git-menu.md
file_local_env=$dir_bin/local_env.sh
file_git_completion=$dir_bin/git-completion.bash
file_git_prompt=$dir_bin/gitprompt.sh
file_git_ssh_keys=$dir_bin/ssh-keys.sh
url_git_completion="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
url_git_profile="https://raw.githubusercontent.com/deanhouseholder/bash-profile/master/profile.sh"
url_git_menu="https://raw.githubusercontent.com/deanhouseholder/bash-profile/master/git-menu.md"
url_git_prompt="https://raw.githubusercontent.com/deanhouseholder/gitprompt/master/gitprompt.sh"
url_git_ssh_keys="https://raw.githubusercontent.com/deanhouseholder/ssh-keys/master/ssh-keys.sh"

# Start install script
printf "\nStarting configuration of bash profile\n\n"

# Set up directories
mkdir -p $dir_bin
chmod 700 $dir_bin
mkdir -p $dir_ssh
chmod 700 $dir_ssh

# If the local_env.sh doesn't exist or is 0 bytes
if [[ ! -s $file_local_env ]]; then
  printf "# Add any custom bash profile tweaks specific to this environment in this file\n\n" > $file_local_env
fi

# Add ssh-keys.sh if it doesn't exist
if [[ ! -f "$file_git_ssh_keys" ]]; then
  curl "$url_git_ssh_keys" -o "$file_git_ssh_keys" 2>/dev/null
  printf "ssh_keys_load=()\nssh_keys_pass=()\nsource ~/bin/ssh-keys.sh\n\n" >> $file_local_env
fi

# If there is no EDITOR defined prompt for one
if [[ $(grep "EDITOR=" $file_local_env | wc -l) -eq 0 ]]; then
  read -p "Which editor do you prefer? [vim], nano, emacs" editor
  test -z $editor && editor=vim
  echo "export EDITOR=$editor" >> $file_local_env
  echo
fi

# Save the machine's name to .displayname
if [[ ! -f ~/.displayname ]]; then
  printf "What name would you like to give this server to be displayed in the title and prompt?\n"
  read server_name
  if [[ ! -z "$server_name" ]]; then
    echo "$server_name" > ~/.displayname
    printf "\nalias set_title='change_title $(cat ~/.displayname)'\nset_title\n" >> $file_local_env
  fi
fi

# Add a .vimrc file to always turn on syntax highlighting
if [[ ! -s ~/.vimrc ]]; then
  printf "syntax on\nset nu\n" > ~/.vimrc
fi

# Add auto loading of new profile.sh script in .bashrc if it isn't there
if [[ $(grep "source $file_profile" $file_startup | wc -l) -eq 0 ]]; then
  printf "\nsource $file_profile\n\n" >> $file_startup
fi

# Configure Git
read -p "Do want to configure Git? [Y/n] " use_git
if [[ ! "$use_git" =~ [nN][oO]? ]]; then
    curl "$url_git_completion" -o $file_git_completion 2>/dev/null
    curl "$url_git_menu" -o $file_git_menu 2>/dev/null
    curl "$url_git_profile" -o $file_profile 2>/dev/null
    curl "$url_git_prompt" -o $file_git_prompt 2>/dev/null

    # Configure git settings
    if [[ -z "$(git config --global user.name)" ]]; then
      read -p "What name would you like to use for git commits? (typically your full name) " user_name
      git config --global user.name "$user_name"
    fi
    if [[ -z "$(git config --global user.email)" ]]; then
      read -p "What email address would you like to use for git commits? " user_email
      git config --global user.email "$user_email"
    fi
    read -p "Would you like to update your Git colors/options configuration? [Y/n] " update_git
    if [[ ! "$update_git" =~ [nN][oO]? ]]; then
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
fi

# Clean up
unset dir_bin dir_ssh file_startup file_git_menu file_local_env file_git_completion file_git_ssh_keys url_git_completion url_git_profile url_git_menu url_git_ssh_keys editor use_git user_name user_email update_git

# Load new profile script
source $file_profile
unset file_profile

printf "\nDone\n\nYou can safely remove setprofile.sh if you want, or use it to pull updates.\n\n"
