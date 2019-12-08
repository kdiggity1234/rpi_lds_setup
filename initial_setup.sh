## Update OS and Firmware ##
apt update && apt upgrade -y && echo y |rpi-update

## Install inital software ##
apt install deluged deluge-web deluge-console sabnzbd openvpn iptables-persistent unzip nfs-common git unar -y

## Update locale ##
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
perl -pi -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen en_US.UTF-8
update-locale en_US.UTF-8

## Disable un-needed hardware ##
# Disable in boot config
echo "dtoverlay=pi3-disable-wifi" | sudo tee -a /boot/config.txt
echo "dtoverlay=pi3-disable-bt" | sudo tee -a /boot/config.txt
sudo systemctl disable hciuart

# Disable ipv6
echo "ipv6.disable=1" | sudo tee -a /boot/cmdline.txt

# Disable in sysctl
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf

## Setup Log2RAM ##
cd /home/pi
git clone https://github.com/azlux/log2ram.git
cd log2ram
chmod +x install.sh
sudo ./install.sh

## Deluge Setup ##
# Add deluge user
sudo adduser --system  --gecos "Deluge Service" --disabled-password --group --home /var/lib/deluge deluge

# Create log directory and assign permissions
sudo mkdir -p /var/log/deluge
sudo chown -R deluge: /var/log/deluge
sudo chmod -R 750 /var/log/deluge

# Change startup type
sudo /etc/init.d/deluge-daemon stop
sudo rm /etc/init.d/deluge-daemon
sudo update-rc.d deluge-daemon remove
sudo service deluged stop
sudo service deluge-web stop
sudo rm /etc/init/deluge-web.conf
sudo rm /etc/init/deluged.conf

# Enable systemctl startup
sudo systemctl enable /etc/systemd/system/deluged.service
sudo systemctl enable /etc/systemd/system/deluge-web.service
sudo systemctl daemon-reload
sudo systemctl start deluged && sudo systemctl start deluge-web

## SABNZB Setup ##
sudo adduser --system  --gecos "SABnzbd Service" --disabled-password --group --home /home/sabnzbd sabnzbd
sudo systemctl enable /etc/systemd/system/sabnzbd.service
sudo systemctl daemon-reload
service sabnzbd start
