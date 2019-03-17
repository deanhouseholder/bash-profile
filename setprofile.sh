#!/bin/bash

bin_dir=~/bin
ssh_dir=~/.ssh
startup_file=~/.bashrc
profile=$bin_dir/profile.sh
local_env=$bin_dir/local_env.sh
git_prompt=$bin_dir/git-prompt.sh
key_file=$ssh_dir/.pkey
git_prompt_download="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
git_profile_download="https://raw.githubusercontent.com/deanhouseholder/bash-profile/master/profile.sh"

echo -e "\nStarting configuration of bash profile\n"

mkdir -p $bin_dir
curl "$git_prompt_download" -o $git_prompt 2>/dev/null
curl "$git_profile_download" -o $profile 2>/dev/null

# If the local_env.sh doesn't exist or is 0 bytes
if [[ ! -s $local_env ]]; then
  echo "# Add any custom bash profile tweaks specific to this environment in this file" > $local_env
fi

# If there is no EDITOR defined prompt for one
if [[ $(grep "EDITOR=" $local_env | wc -l) -eq 0 ]]; then
  read -p "Which editor do you prefer? [vim], nano, emacs" editor
  [[ -z $editor ]] && editor=vim
  echo "export EDITOR=$editor" >> $local_env
  echo
fi

# Add auto loading of new profile.sh script in .bashrc if it isn't there
if [[ $(grep "source $profile" $startup_file | wc -l) -eq 0 ]]; then
  echo -e "\nsource $profile\n" >> $startup_file
fi

# Set up ssh key passphrase
mkdir -p $ssh_dir
chmod 700 $ssh_dir

if [[ ! -f $key_file ]]; then
  # Read password
  prompt="Enter SSH Key Passphrase: "
  while IFS= read -p "$prompt" -r -s -n 1 char
  do
    if [[ $char == $'\0' ]]; then
        break
    elif [[ $char == $'\177' ]]; then
        prompt=$'\b \b'
        PASS="${PASS%?}"
    else
      prompt='*'
      PASS+="$char"
    fi
  done
  echo -e "\n\n"

  # Add password to key_file
  echo "echo \"$PASS\"" > $key_file
  unset PASS
  chmod 700 $key_file
fi

source $profile

echo -e "Done\nYou can savely remove setprofile.sh if you want or use it to pull updates.\n"
