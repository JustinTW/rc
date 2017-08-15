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
  unzip git zsh curl vim tmux ssh autofs nfs-common \
  build-essential

echo 'Packages install success !'
echo 'Next: Force install !'
read -rsp $'Press any key to continue...\n' -n1 key

sudo apt install -f -y

echo 'Packages force install success !'
echo 'Next: Setup ssh !'
read -rsp $'Press any key to continue...\n' -n1 key

# setup

# ssh
sudo -u root sed -i -e 's/PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
if ! grep -q "AllowUsers $sUserName" /etc/ssh/sshd_config ; then
  sudo /bin/su -c  "echo 'AllowUsers $sUserName' >> /etc/ssh/sshd_config"
fi
sudo service ssh restart

echo 'Setup ssh security finish !'
echo 'Next: Setup vim !'
read -rsp $'Press any key to continue...\n' -n1 key


# network

if ! grep -q 'hopebaytech.com' /etc/network/interfaces ; then
  sudo /bin/su -c "echo 'dns-search hopebaytech.com' >> /etc/network/interfaces"
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
echo 'Next: Setup autofs !'
read -rsp $'Press any key to continue...\n' -n1 key

# auto mount
if ! grep -q '/etc/auto.direct' /etc/auto.master ; then
  sudo /bin/su -c "echo '\n/- /etc/auto.direct' >> /etc/auto.master"
fi

sudo service autofs stop

if [ ! -f '/etc/auto.direct' ]; then
  sudo mkdir -p /mnt/nas/justin.liu
  sudo mkdir -p /mnt/nas/ubuntu
  sudo /bin/su -c "echo '/mnt/nas/justin.liu -rw,bg,soft,rsize=32768,wsize=32768 nas:/justin.liu' >> /etc/auto.direct"
  sudo /bin/su -c "echo '/mnt/nas/ubuntu -rw,bg,soft,rsize=32768,wsize=32768 nas:/ubuntu' >> /etc/auto.direct"
fi
sudo service autofs restart

echo 'Setup autofs finish !'
read -rsp $'Press any key to exit...\n' -n1 key
