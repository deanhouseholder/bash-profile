#!/bin/bash

printf "\nThis script will update the following files:\n\n"
echo "  .bash_profile           - Remove the line: source ~/bin/profile.sh"
echo "  .bash_profile           - Remove the line: # Include the Git Prompt functions"
echo "  .bash_profile           - Remove the line: source ~/code/gitprompt/default-prompt.sh"
echo "  .displayname            - To be deleted"
echo "  .vimrc                  - Remove the 2 added lines"
echo "  bin/ssh-keys.sh         - To be deleted"
echo "  code/bash-profile/      - To be deleted"
echo "  code/gitprompt/         - To be deleted"
echo "  bin/local_env.sh        - To be renamed to bin/local_env.sh.bak"

printf "\nDo you want to proceed? [y/N] "
read proceed

if [[ "$proceed" =~ ^[yY]$ ]]; then
  printf "\nProceeding\n\n"
else
  printf "\nAborting\n\n"
  exit 1
fi

# Remove/rename/update files
echo "Removing the two lines added by the setprofile.sh to .vimrc"
sed -i -e '/^syntax on$/d' -e '/^set nu/d' ~/.vimrc
rm -vf ~/.displayname
rm -vf ~/code/bash-profile
rm -vf ~/bin/ssh-keys.sh
echo "Renaming ~/bin/local_env.sh to ~/bin/local_env.sh.bak"
mv -vf ~/bin/local_env.sh ~/bin/local_env.sh.bak
echo "Removing the added line to .bash_profile to include bin/profile.sh"
sed -i '/^source .*\/bin\/profile.sh$/d' ~/.bash_profile
echo "Removing the added lines to .bash_profile to include gitprompt"
sed -i -e '/^# Include the Git Prompt functions$/d' -e '/^source .*\/gitprompt\/default-prompt.sh$/d' ~/.bash_profile
if [[ -d ~/code/gitprompt ]]; then
  echo "Removing the gitprompt directory"
  rm -rf ~/code/gitprompt
fi

printf "\nThe above actions have been taken.\n"
printf "The changes will take effect the next time you log on or open your terminal.\n\n"
printf "You can now safely remove this script\n\n"
