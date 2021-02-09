#!/bin/bash

clear

# Set these to change the version of Trittium to install
TARBALLURL="https://github.com/Carbon-Reduction-Initiative/CARI/releases/download/CARIv1.1.0/CARI-v1.1.0-linux-ubuntu16.tar.gz"
TARBALLNAME="CARI-v1.1.0-linux-ubuntu16.tar.gz"
TRTTVERSION="1.1.0"

#!/bin/bash

# Check if we are root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

# Check if we have enough memory
if [[ `free -m | awk '/^Mem:/{print $2}'` -lt 850 ]]; then
  echo "This installation requires at least 1GB of RAM.";
  exit 1
fi

# Check if we have enough disk space
if [[ `df -k --output=avail / | tail -n1` -lt 10485760 ]]; then
  echo "This installation requires at least 10GB of free disk space.";
  exit 1
fi

# Install tools for dig and systemctl
echo "Preparing installation..."
#apt-get install git dnsutils systemd -y > /dev/null 2>&1

# Check for systemd
systemctl --version >/dev/null 2>&1 || { echo "systemd is required. Are you using Ubuntu 16.04?"  >&2; exit 1; }

# CHARS is used for the loading animation further down.
CHARS="/-\|"

#EXTERNALIP=`dig +short myip.opendns.com @resolver1.opendns.com`

clear

echo "

  ------- CRI MASTERNODE INSTALLER v2.1.1--------+
 |                                                  |
 |                                                  |::
 |       The installation will install and run      |::
 |        the masternode under a user tritt.     |::
 |                                                  |::
 |        This version of installer will setup      |::
 |           fail2ban and ufw for your safety.      |::
 |                                                  |::
 +------------------------------------------------+::
   ::::::::::::::::::::::::::::::::::::::::::::::::::

"

sleep 5

USER=cari

adduser $USER --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password > /dev/null

echo "" && echo 'Added user "cari"' && echo ""
sleep 1


USERHOME=`eval echo "~$USER"`


read -e -p "Enter Masternode Private Key (e.g. 7edfjLCUzGczZi3JQw8GHp434R9kNY33eFyMGeKRymkB56G4324h # THE KEY YOU GENERATED EARLIER) : " KEY
sleep 1
clear

read -e -p "Enter Second IP ADDRESS (e.g. 192.168.1.1) : " IP_ADDRESS
sleep 1
clear


# Generate random passwords
RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# update packages and upgrade Ubuntu
#echo "Installing dependencies..."
#apt-get -qq update
#apt-get -qq upgrade
#apt-get -qq autoremove
#apt-get -qq install wget htop unzip
#apt-get -qq install build-essential && apt-get -qq install libtool libevent-pthreads-2.0-5 autotools-dev autoconf automake && apt-get -qq install libssl-dev && apt-get -qq install libboost-all-dev && apt-get -qq install software-properties-common && add-apt-repository -y ppa:bitcoin/bitcoin && apt update && apt-get -qq install libdb4.8-dev && apt-get -qq install libdb4.8++-dev && apt-get -qq install libminiupnpc-dev && apt-get -qq install libqt4-dev libprotobuf-dev protobuf-compiler && apt-get -qq install libqrencode-dev && apt-get -qq install git && apt-get -qq install pkg-config && apt-get -qq install libzmq3-dev
#apt-get -qq install aptitude
#
#  aptitude -y -q install fail2ban
#  service fail2ban restart
#
#  apt-get -qq install ufw
#  ufw default deny incoming
#  ufw default allow outgoing
#  ufw allow ssh
#  ufw allow 30001/tcp
#  yes | ufw enable

#
# /* no parameters, creates and activates a swapfile since VPS servers often do not have enough RAM for compilation */
#
#check if swap is available
#if [ $(free | awk '/^Swap:/ {exit !$2}') ] || [ ! -f "/var/mnode_swap.img" ];then
#    echo "* No proper swap, creating it"
#    # needed because ant servers are ants
#    rm -f /var/mnode_swap.img
#    dd if=/dev/zero of=/var/mnode_swap.img bs=1024k count=4096
#    chmod 0600 /var/mnode_swap.img
#    mkswap /var/mnode_swap.img
#    swapon /var/mnode_swap.img
#    echo '/var/mnode_swap.img none swap sw 0 0' | tee -a /etc/fstab
#    echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
#    echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf
#else
#    echo "* All good, we have a swap"
#fi


# Install CRI daemon
#wget $TARBALLURL && unzip $TARBALLNAME -d $USERHOME/  && rm $TARBALLNAME
wget $TARBALLURL && tar -xvf $TARBALLNAME -C $USERHOME/  && rm $TARBALLNAME
cp $USERHOME/carid /usr/local/bin
cp $USERHOME/cari-cli /usr/local/bin
cp $USERHOME/cari-tx /usr/local/bin
rm $USERHOME/cari*
chmod 755 /usr/local/bin/cari*

# Create .cari directory
mkdir $USERHOME/.cari



#cat > /etc/systemd/system/trittiumd.service << EOL
#[Unit]
#Description=trittiumd
#After=network.target
#[Service]
#Type=forking
#User=${USER}
#WorkingDirectory=${USERHOME}
#ExecStart=/usr/local/bin/trittiumd -conf=${USERHOME}/.trittium2/trittium2.conf -datadir=${USERHOME}/.trittium2
#ExecStop=/usr/local/bin/trittium-cli -conf=${USERHOME}/.trittium2/trittium2.conf -datadir=${USERHOME}/.trittium2 stop
#Restart=on-abort
#[Install]
#WantedBy=multi-user.target
#EOL
#sudo systemctl enable trittiumd
#sudo systemctl stop trittiumd
#killall tritt*
#sleep 6


# Create cari.conf
touch $USERHOME/.cari/cari.conf
cat > $USERHOME/.cari/cari.conf << EOL
rpcuser=${RPCUSER}
rpcpassword=${RPCPASSWORD}
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
maxconnections=256
rpcport=31812
masternodeaddr=${IP_ADDRESS}:31813
bind=${IP_ADDRESS}:31813
masternodeprivkey=${KEY}
masternode=1
EOL
chmod 0600 $USERHOME/.cari/cari.conf
chown -R $USER:$USER $USERHOME/.cari


sleep 5

USER1=cari1

adduser $USER1 --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password > /dev/null

echo "" && echo 'Added user "cari1"' && echo ""
sleep 1


USERHOME1=`eval echo "~$USER1"`


read -e -p "Enter Masternode Private Key (e.g. 7edfjLCUzGczZi3JQw8GHp434R9kNY33eFyMGeKRymkB56G4324h # THE KEY YOU GENERATED EARLIER) : " KEY1
sleep 1
clear

read -e -p "Enter Second IP ADDRESS (e.g. 192.168.1.1) : " IP_ADDRESS_1
sleep 1
clear



# Generate random passwords
RPCUSER1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
RPCPASSWORD1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Create .cari1 directory
mkdir $USERHOME1/.cari

sleep 6


# Create cari.conf (second node)
touch $USERHOME1/.cari/cari.conf
cat > $USERHOME1/.cari/cari.conf << EOL
rpcuser=${RPCUSER1}
rpcpassword=${RPCPASSWORD1}
rpcallowip=127.0.0.2
listen=0
server=1
daemon=1
maxconnections=256
rpcport=31812
masternodeaddr=${IP_ADDRESS}:31813
bind=${IP_ADDRESS}:31813
masternodeprivkey=${KEY1}
masternode=1
EOL
chmod 0600 $USERHOME1/.cari/cari.conf
chown -R $USER1:$USER1 $USERHOME1/.cari

sleep 1

clear

echo "Your masternodes are installed."
