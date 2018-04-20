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

if [ ! -f $RC_HOME/PWD ]; then
  cp -r $RC_HOME/PWD_S $RC_HOME/PWD
fi

mv $HOME/.config/Code/User/keybindings.json $HOME/.config/Code/User/keybindings.json.old
mv $HOME/.config/Code/User/settings.json $HOME/.config/Code/User/settings.json.old
ln -s "$RC_HOME/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
ln -s "$RC_HOME/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

git submodule update --init
command -v ssh-copy-id >/dev/null 2>&1 || brew install ssh-copy-id
command -v sshpass >/dev/null 2>&1 || apt-get install sshpass -y
