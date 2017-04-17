#!/bin/bash
RC_HOME=`pwd`
cd ..
for TARGET in zshrc screenrc psqlrc tmux.conf gitconfig vimrc;
do
  if [ -e ".$TARGET" ]; then
    mv ".$TARGET" ".$TARGET.old"
    echo
  fi
  ln -s "$RC_HOME/$TARGET" ".$TARGET"
done
if [[ "$SHELL" =~ .*/zsh ]]
then
  echo "Good. You are using $SHELL. No need to chsh."
else
  echo "Please change your shell to `which zsh`"
  chsh
fi

git submodule update --init
command -v ssh-copy-id >/dev/null 2>&1 || brew install ssh-copy-id
command -v sshpass >/dev/null 2>&1 || apt-get install sshpass -y
