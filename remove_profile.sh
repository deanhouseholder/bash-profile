#!/bin/bash

printf "\nThis script will update the following files:\n\n"
echo "  .bashrc                 - Remove the line: source ~/bin/profile.sh"
echo "  .displayname            - To be deleted"
echo "  bin/git-completion.bash - To be deleted"
echo "  bin/git-menu.md         - To be deleted"
echo "  bin/gitprompt.sh        - To be deleted"
echo "  bin/profile.sh          - To be deleted"
echo "  bin/ssh-keys.sh         - To be deleted"
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
rm -v ~/.displayname
rm -v ~/bin/git-completion.bash
rm -v ~/bin/git-menu.md
rm -v ~/bin/gitprompt.sh
rm -v ~/bin/profile.sh
rm -v ~/bin/ssh-keys.sh
mv -v ~/bin/local_env.sh ~/bin/local_env.sh.bak
sed -i '/^source .*\/bin\/profile.sh$/d' ~/.bashrc

printf "\nThe above actions have been taken.\n"
printf "The changes will take effect the next time you log on or open your terminal.\n\n"
printf "You can now safely remove this script\n\n"
