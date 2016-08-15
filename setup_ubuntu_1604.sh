#!/bin/bash
sUserName=robo

sudo dpkg --remove-architecture i386 || true

# visudo
sudo -u root sed -i -e 's/%sudo   ALL=(ALL:ALL) ALL/%sudo	ALL=NOPASSWD:ALL/g' /etc/sudoers

# add repositories
apt-key list |grep git-core &> /dev/null
if [ ! $? -eq 0 ]; then
  sudo add-apt-repository ppa:git-core/ppa -y
fi

apt-key list |grep frol &> /dev/null
if [ ! $? -eq 0 ]; then
  sudo add-apt-repository ppa:frol/zip-i18n -y
fi

apt-key list |grep pi-rho &> /dev/null
if [ ! $? -eq 0 ]; then # tmux
  sudo add-apt-repository ppa:pi-rho/dev -y
fi

apt-key list |grep gnome-terminator &> /dev/null
if [ ! $? -eq 0 ]; then
  sudo add-apt-repository ppa:gnome-terminator/ppa -y
fi

apt-key list |grep synapse-core &> /dev/null
if [ ! $? -eq 0 ]; then
  sudo add-apt-repository ppa:synapse-core/testing -y
fi

apt-key list |grep webupd8team &> /dev/null
if [ ! $? -eq 0 ]; then
  sudo add-apt-repository ppa:webupd8team/sublime-text-3 -y
fi

apt-key list |grep Google &> /dev/null
if [ ! $? -eq 0 ]; then
  sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb stable main" > /etc/apt/sources.list.d/google.list'
fi


# update apt
sudo apt update

# upgrade
sudo apt upgrade -y -q

# install
sudo apt install -q -y --fix-missing \
  unzip git zsh curl vim tmux ssh google-chrome-stable \
  gnome-panel gnome-flashback gnome-session-flashback indicator-applet-appmenu \
  fcitx fcitx-chewing sublime-text-installer \
  xmonad libghc-xmonad-contrib-dev xmobar xcompmgr nitrogen stalonetray moreutils synapse ssh-askpass-gnome thunar terminator remmina

  
  

sudo apt install -f -y -q

# setup

# ssh
if ! grep -q 'Port 2200' /etc/ssh/sshd_config ; then
  sudo -u root sed -i -e 's/Port 22/Port 2200/g' /etc/ssh/sshd_config
fi
sudo -u root sed -i -e 's/PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
if ! grep -q "AllowUsers $sUserName" /etc/ssh/sshd_config ; then
  sudo /bin/su -c  "echo 'AllowUsers $sUserName' >> /etc/ssh/sshd_config"
fi
sudo service ssh restart

# vim
if ! grep -q 'set nu' /etc/vim/vimrc ; then
  sudo /bin/su -c "echo 'set nu' >> /etc/vim/vimrc"
fi

# install my rc file
if [ ! -d "/home/$sUserName/.rc" ] ; then
  wget -O - https://raw.github.com/JustinTW/rc/develop/auto-install.sh |sh
  chsh -s /usr/bin/zsh $sUserName
  sudo -u root wget -O - https://raw.github.com/JustinTW/rc/develop/auto-install.sh |sh
  sudo -u root chsh -s /usr/bin/zsh root
fi

# config fcitx
echo "please choose fcitx"

if [ ! -d "/home/$sUserName/.xmonad" ]; then
  git clone https://github.com/JustinTW/xmonad-ubuntu-conf.git /home/$sUserName/.xmonad
  cd /home/$sUserName/.xmonad && ./install-xmonad && cd -
fi



