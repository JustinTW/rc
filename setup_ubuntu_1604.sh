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
  fcitx fcitx-chewing sublime-text-installer autofs nfs-common\
  xmonad libghc-xmonad-contrib-dev xmobar xcompmgr nitrogen stalonetray moreutils synapse ssh-askpass-gnome thunar terminator remmina \
  build-essential libgtk2.0-dev

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

# network

if ! grep -q 'hopebaytech.com' /etc/network/interfaces ; then
  sudo /bin/su -c "echo 'dns-search hopebaytech.com' >> /etc/network/interfaces"
  service networking restart
fi

# install my rc file
if [ ! -d "/home/$sUserName/.rc" ]; then
  wget -O - https://raw.github.com/JustinTW/rc/develop/auto-install.sh |sh
  chsh -s /usr/bin/zsh $sUserName
fi

sudo ls -al /root/.rc &> /dev/null
if [ ! $? -eq 0 ]; then
  sudo /bin/su -c  "wget -O - https://raw.github.com/JustinTW/rc/develop/auto-install.sh |sh"
  sudo -u root chsh -s /usr/bin/zsh root
fi

# config fcitx
echo "please choose fcitx"

if [ ! -d "/home/$sUserName/.xmonad" ]; then
  git clone https://github.com/JustinTW/xmonad-ubuntu-conf.git /home/$sUserName/.xmonad
  cd /home/$sUserName/.xmonad && ./install-xmonad && cd -
fi

# auto mount
if ! grep -q '/etc/auto.direct' /etc/auto.master ; then
  sudo /bin/su -c "echo '\n/- /etc/auto.direct' >> /etc/auto.master"
fi

sudo service autofs stop

if [ ! -f '/etc/auto.direct' ]; then
  sudo mkdir -p /mnt/disk
  sudo mkdir -p /mnt/btrfs
  sudo mkdir -p /mnt/nas/justin.liu
  sudo mkdir -p /mnt/nas/ubuntu
  sudo mkdir -p /mnt/drive/justin.liu
  sudo /bin/su -c "echo '/mnt/disk -fstype=btrfs :/dev/sdb1' > /etc/auto.direct"
  sudo /bin/su -c "echo '/mnt/btrfs -fstype=btrfs :/dev/sda1' >> /etc/auto.direct"
  sudo /bin/su -c "echo '/mnt/nas/justin.liu -rw,bg,soft,rsize=32768,wsize=32768 nas:/justin.liu' >> /etc/auto.direct"
  sudo /bin/su -c "echo '/mnt/nas/ubuntu -rw,bg,soft,rsize=32768,wsize=32768 nas:/ubuntu' >> /etc/auto.direct"
  sudo /bin/su -c "echo '/mnt/drive/justin.liu -rw,bg,soft,rsize=32768,wsize=32768 drive:/justin.liu_local' >> /etc/auto.direct"
fi
sudo service autofs restart

# terminator
terminatorConf="/home/$sUserName/.config/terminator/config"
if [ ! -h "$terminatorConf" ]; then
  mkdir -p "/home/$sUserName/.config/terminator"
  if [ ! -f "$terminatorConf" ]; then
    mv "$terminatorConf" "$terminatorConf"_origin
  fi
  ln -sf "/home/$sUserName/.rc/terminator.conf" "$terminatorConf"
fi

# sublime cht input
if [ ! -f '/opt/sublime_text/libsublime-imfix.so' ]; then
  cd /opt/sublime_text
  sudo wget -O sublime_imfix.c https://raw.githubusercontent.com/JustinTW/rc/develop/sublime-text-3/sublime_imfix.c
  sudo gcc -shared -o libsublime-imfix.so sublime_imfix.c  `pkg-config --libs --cflags gtk+-2.0` -fPIC
  cd -
fi
if ! grep -q 'libsublime-imfix.so' /usr/share/applications/sublime-text.desktop ; then
  sudo -u root sed -i -e "s/\/opt\/sublime_text\/sublime_text/bash -c 'LD_PRELOAD=\/opt\/sublime_text\/libsublime-imfix.so \/opt\/sublime_text\/sublime_text'/g" /usr/share/applications/sublime-text.desktop
fi

# link sublime packages
sublInstallPackage="/home/$sUserName/.config/sublime-text-3/Installed Packages"
if [ ! -h "$sublInstallPackage" ]; then
  if [ ! -f "$sublInstallPackage" ]; then
    mv "$sublInstallPackage" "$sublInstallPackage"_origin
  fi
  ln -sf "/home/$sUserName/.rc/sublime-text-3/Installed Packages" "$sublInstallPackage"
fi

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

