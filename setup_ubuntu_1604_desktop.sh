#!/bin/bash
sUserName=$(whoami)

sudo dpkg --remove-architecture i386 || true

# visudo
# ubuntu 16.04
sudo -u root sed -i -e 's/%sudo   ALL=(ALL:ALL) ALL/%sudo	ALL=NOPASSWD:ALL/g' /etc/sudoers
# ubuntu 16.04.2
sudo -u root sed -i -e 's/%sudo	ALL=(ALL:ALL) ALL/%sudo       ALL=NOPASSWD:ALL/g' /etc/sudoers

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

apt-key list |grep otto-kesselgulasch &> /dev/null
if [ ! $? -eq 0 ]; then
  sudo add-apt-repository ppa:otto-kesselgulasch/gimp -y
fi

apt-key list |grep gekkio &> /dev/null
if [ ! $? -eq 0 ]; then
  sudo add-apt-repository ppa:gekkio/xmonad -y
fi

apt-key list |grep Google &> /dev/null
if [ ! $? -eq 0 ]; then
  sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb stable main" > /etc/apt/sources.list.d/google-chrome.list'
fi

echo 'Add apt repositories finish !'
echo 'Next: Update apt !'
read -rsp $'Press any key to continue...\n' -n1 key

# update apt
sudo apt update

echo 'Update apt finish !'
echo 'Next: Upgrade packages !'
read -rsp $'Press any key to continue...\n' -n1 key

# upgrade
sudo apt upgrade -y -q

echo 'Upgrade finish, reboot is recommand !'
echo 'Next: Install packages !'
read -rsp $'Press any key to continue...\n' -n1 key

# install
sudo apt install -y --fix-missing \
  unzip git zsh curl vim tmux ssh google-chrome-stable \
  gnome-panel gnome-flashback gnome-session-flashback indicator-applet-appmenu \
  fcitx fcitx-chewing sublime-text-installer autofs nfs-common \
  xmonad libghc-xmonad-contrib-dev xmobar xcompmgr nitrogen stalonetray moreutils synapse ssh-askpass-gnome thunar terminator remmina gnome-session-xmonad \
  build-essential libgtk2.0-dev gimp unar openvpn

echo 'Packages install success !'
echo 'Next: Force install !'
read -rsp $'Press any key to continue...\n' -n1 key

sudo apt install -f -y

echo 'Packages force install success !'
echo 'Next: Setup ssh !'
read -rsp $'Press any key to continue...\n' -n1 key

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

echo 'Setup ssh security finish !'
echo 'Next: Setup vim !'
read -rsp $'Press any key to continue...\n' -n1 key

# network
if ! grep -q 'moxa.online' /etc/network/interfaces ; then
  sudo /bin/su -c "echo 'dns-search moxa.online' >> /etc/network/interfaces"
  service networking restart
fi

echo 'Setup network finish !'
echo 'Next: Setup trash-cli !'
read -rsp $'Press any key to continue...\n' -n1 key

# install trash-cli
command -v trash-list &>/dev/null
if [[ ! $? -eq 0 ]]; then
  cd /tmp
  git clone https://github.com/andreafrancia/trash-cli.git
  cd trash-cli
  sudo python setup.py install
  cd --
  # aruto rotate
  sudo /bin/su -c "echo \"#\!/bin/bash\" > /etc/cron.daily/trash-cli-rotate"
  sudo /bin/su -c "echo \"find $HOME/.local/share/Trash/ -mtime +29 --delete\\n\" >> /etc/cron.daily/trash-cli-rotate"
  sudo /bin/su -c "chmod +x /etc/cron.daily/trash-cli-rotate"
fi

echo 'Setup trash-cli finish !'
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
  sudo /bin/su -c  "wget -O /tmp/install_rc.sh https://raw.github.com/JustinTW/rc/develop/auto-install.sh && bash /tmp/install_rc.sh"
  sudo -u root chsh -s /usr/bin/zsh root
fi

echo 'Setup zsh for root finish !'
echo 'Next: Setup xmonad !'
read -rsp $'Press any key to continue...\n' -n1 key

if [ ! -d "/home/$sUserName/.xmonad" ]; then
  git clone https://github.com/JustinTW/xmonad-ubuntu-conf.git /home/$sUserName/.xmonad
  cd /home/$sUserName/.xmonad && ./install-xmonad && cd -
fi

echo 'Setup xmonad finish !'
echo 'Next: Setup autofs !'
read -rsp $'Press any key to continue...\n' -n1 key

# auto mount
if ! grep -q '/etc/auto.direct' /etc/auto.master ; then
  sudo /bin/su -c "echo '\n/- /etc/auto.direct' >> /etc/auto.master"
fi

sudo service autofs stop

if [ ! -f '/etc/auto.direct' ]; then
  sudo mkdir -p /mnt/disk
  sudo mkdir -p /mnt/btrfs
  sudo /bin/su -c "echo '/mnt/disk -fstype=btrfs :/dev/sdb1' > /etc/auto.direct"
  sudo /bin/su -c "echo '/mnt/btrfs -fstype=btrfs :/dev/sda1' >> /etc/auto.direct"
fi
sudo service autofs restart

echo 'Setup autofs finish !'
echo 'Next: Setup terminator !'
read -rsp $'Press any key to continue...\n' -n1 key

# terminator
terminatorConf="/home/$sUserName/.config/terminator/config"
if [ ! -h "$terminatorConf" ]; then
  mkdir -p "/home/$sUserName/.config/terminator"
  if [ ! -f "$terminatorConf" ]; then
    mv "$terminatorConf" "$terminatorConf"_origin
  fi
  ln -sf "/home/$sUserName/.rc/terminator.conf" "$terminatorConf"
fi

echo 'Setup terminator finish !'
echo 'Next: Fix sublime cht input !'
read -rsp $'Press any key to continue...\n' -n1 key

# sublime cht input
#if [ ! -f '/opt/sublime_text/libsublime-imfix.so' ]; then
cd /opt/sublime_text
sudo wget -O sublime_imfix.c https://raw.githubusercontent.com/JustinTW/rc/develop/sublime-text-3/sublime_imfix.c
  sudo gcc -shared -o libsublime-imfix.so sublime_imfix.c  `pkg-config --libs --cflags gtk+-2.0` -fPIC
cd -
#fi

if ! grep -q 'libsublime-imfix.so' /usr/share/applications/sublime-text.desktop ; then
  sudo -u root sed -i -e "s/\/opt\/sublime_text\/sublime_text/bash -c 'LD_PRELOAD=\/opt\/sublime_text\/libsublime-imfix.so \/opt\/sublime_text\/sublime_text'/g" /usr/share/applications/sublime-text.desktop
fi

echo 'Setup Sublime cht input finish !'
echo 'Next: Open Sublime !'
read -rsp $'Press any key to continue...\n' -n1 key

# link sublime packages
/usr/bin/subl
/bin/sleep 3
pkill -9 sublime_text

echo 'Setup Sublime cht input finish !'
echo 'Next: Setup Sublime Packages !'
read -rsp $'Press any key to continue...\n' -n1 key

# setup sublime package control
mkdir -p "/home/$sUserName/.config/sublime-text-3/Installed Packages"
wget https://packagecontrol.io/Package%20Control.sublime-package -P "/home/$sUserName/.config/sublime-text-3/Installed Packages"

echo 'Setup Sublime Packages finish !'
echo 'Next: link sublime settings'
read -rsp $'Press any key to continue...\n' -n1 key

# link sublime settings
sublSettings="/home/$sUserName/.config/sublime-text-3/Packages/User"
preferences="Preferences.sublime-settings"
if [ ! -h "$sublSettings/$preferences" ]; then
  if [ ! -f "$sublSettings/$preferences" ]; then
    mv "$sublSettings/$preferences" "$sublSettings/$preferences"_origin
  fi
  ln -sf "/home/$sUserName/.rc/sublime-text-3/Packages/User/$preferences" "$sublSettings/$preferences"
fi

# link key bind
preferences="Default (Linux).sublime-keymap"
if [ ! -h "$sublSettings/$preferences" ]; then
  if [ ! -f "$sublSettings/$preferences" ]; then
    mv "$sublSettings/$preferences" "$sublSettings/$preferences"_origin
  fi
  ln -sf "/home/$sUserName/.rc/sublime-text-3/Packages/User/$preferences" "$sublSettings/$preferences"
fi

# link AutoPEP8
preferences="AutoPep8.sublime-settings"
if [ ! -h "$sublSettings/$preferences" ]; then
  if [ ! -f "$sublSettings/$preferences" ]; then
    mv "$sublSettings/$preferences" "$sublSettings/$preferences"_origin
  fi
  ln -sf "/home/$sUserName/.rc/sublime-text-3/Packages/User/$preferences" "$sublSettings/$preferences"
fi

# link snippet pdb
preferences="pdb.sublime-snippet"
if [ ! -h "$sublSettings/$preferences" ]; then
  if [ ! -f "$sublSettings/$preferences" ]; then
    mv "$sublSettings/$preferences" "$sublSettings/$preferences"_origin
  fi
  ln -sf "/home/$sUserName/.rc/sublime-text-3/Packages/User/$preferences" "$sublSettings/$preferences"
fi

# link sublime settings
preferences="Package Control.sublime-settings"
if [ ! -h "$sublSettings/$preferences" ]; then
  if [ ! -f "$sublSettings/$preferences" ]; then
    mv "$sublSettings/$preferences" "$sublSettings/$preferences"_origin
  fi
  ln -sf "/home/$sUserName/.rc/sublime-text-3/Packages/User/$preferences" "$sublSettings/$preferences"
fi

echo 'link sublime settings finish !'
echo 'Next: Open sublime text and wait for package install'
read -rsp $'Press any key to continue...\n' -n1 key

# open sublime-text, this should auto install sublime packages
/usr/bin/subl
