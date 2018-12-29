#!/bin/bash
sUserName=$(whoami)


# visudo
echo '----------------------------------'
echo 'sudo visudo'
echo '%admin  ALL = (ALL) NOPASSWD: ALL'
echo '----------------------------------'
echo ''
echo 'Please change visudo manually !'
echo 'Next: install brew !'
read -rsp $'Press any key to continue...\n' -n1 key



# install brew
command -v brew
if [ ! $? -eq 0 ]; then
echo '---------------------------------'
echo '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
echo '---------------------------------'
echo 'Please install brew manually'
fi
echo 'Next: install git !'
read -rsp $'Press any key to continue...\n' -n1 key


# install git
git --version
command -v git
if [ ! $? -eq 0 ]; then
  brew install git
fi

# install tmux
command -v tmux
if [ ! $? -eq 0 ]; then
  brew install tmux
fi

# install mtr
command -v mtr
if [ ! $? -eq 0 ]; then
  brew install mtr
fi

# install wget
command -v wget
if [ ! $? -eq 0 ]; then
  brew install wget
fi

# install gpg
command -v gpg
if [ ! $? -eq 0 ]; then
  brew install gpg
fi

echo 'Packages install success !'
echo 'Next: setup ssh !'
read -rsp $'Press any key to continue...\n' -n1 key

# setup

# ssh
sudo -u root sed -i'' -e 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
if ! grep -q "AllowUsers $sUserName" /etc/ssh/sshd_config ; then
  sudo /bin/su -c  "echo 'AllowUsers $sUserName' >> /etc/ssh/sshd_config"
fi

echo 'Setup ssh security finish !'
echo 'Setup network finish !'
echo 'Next: Setup trash-cli !'
read -rsp $'Press any key to continue...\n' -n1 key

# setup vscode
if [ ! -f /usr/local/bin/code ]; then
  sudo ln -fs "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/
fi

# setup vscode extension
command -v code
if [ $? -eq 0 ]; then
code --install-extension Rubymaniac.vscode-paste-and-indent
code --install-extension Atishay-Jain.All-Autocomplete
code --install-extension azemoh.one-monokai
code --install-extension bierner.color-info
code --install-extension christian-kohler.npm-intellisense
code --install-extension christian-kohler.path-intellisense
code --install-extension dariofuzinato.vue-peek
code --install-extension dbaeumer.vscode-eslint
code --install-extension eamodio.gitlens
code --install-extension eg2.tslint
code --install-extension eg2.vscode-npm-script
code --install-extension esbenp.prettier-vscode
code --install-extension felixfbecker.php-debug
code --install-extension felixfbecker.php-intellisense
code --install-extension felixfbecker.php-pack
code --install-extension formulahendry.auto-close-tag
code --install-extension formulahendry.auto-rename-tag
code --install-extension ghmcadams.lintlens
code --install-extension himanoa.Python-autopep8
code --install-extension HookyQR.beautify
code --install-extension jpoissonnier.vscode-styled-components
code --install-extension mrmlnc.vscode-duplicate
code --install-extension ms-python.python
code --install-extension ms-vscode.cpptools
code --install-extension ms-vscode.Go
code --install-extension ms-vscode.sublime-keybindings
code --install-extension mubaidr.vuejs-extension-pack
code --install-extension naumovs.color-highlight
code --install-extension octref.vetur
code --install-extension PeterJausovec.vscode-docker
code --install-extension redhat.java
code --install-extension robertohuertasm.vscode-icons
code --install-extension Shan.code-settings-sync
code --install-extension tombonnike.vscode-status-bar-format-toggle
code --install-extension vscjava.vscode-java-debug
code --install-extension vscjava.vscode-java-dependency
code --install-extension vscjava.vscode-java-pack
code --install-extension vscjava.vscode-java-test
code --install-extension vscjava.vscode-maven
code --install-extension vsmobile.vscode-react-native
code --install-extension xabikos.JavaScriptSnippets
fi

# install font: fira code
if [ ! -d '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask-fonts' ]; then
brew tap caskroom/fonts
brew cask install font-fira-code
brew cask install font-fira-mono
brew cask install font-fira-mono-for-powerline
brew cask install font-fira-sans
fi

# install trash-cli
command -v trash-list &>/dev/null
if [[ ! $? -eq 0 ]]; then
  cd /tmp
  git clone https://github.com/andreafrancia/trash-cli.git
  cd trash-cli
  sudo python setup.py install
  cd --
fi

echo 'Setup trash-cli finish!'
echo 'Next: Setup zsh !'
read -rsp $'Press any key to continue...\n' -n1 key

# install my rc file
if [ ! -d "/home/$sUserName/.rc" ]; then
  wget -O /tmp/install_rc.sh https://raw.github.com/JustinTW/rc/develop/auto-install.sh && bash /tmp/install_rc.sh
  chsh -s /usr/bin/zsh $sUserName
fi

echo 'Setup zsh env finish !'
echo 'Next: Setup root zsh !'
read -rsp $'Press any key to continue...\n' -n1 key

sudo ls -al /root/.rc &> /dev/null
if [ ! $? -eq 0 ]; then
  sudo /bin/su -c  "  wget -O /tmp/install_rc.sh https://raw.github.com/JustinTW/rc/develop/auto-install.sh && bash /tmp/install_rc.sh"
  sudo -u root chsh -s /usr/bin/zsh root
fi

echo 'Setup zsh for root finish !'
read -rsp $'Press any key to exit...\n' -n1 key
