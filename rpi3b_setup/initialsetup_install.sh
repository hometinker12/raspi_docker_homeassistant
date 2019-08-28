#!/bin/bash
DATA_SHARE=/usr/share
PORTAINER_DATA=/portainer
HASSIO_DATA=/hassio


### Check root permissions
if [ "$EUID" -ne 0 ]
  then echo "[Error] Must be run as root!!!"
  exit
  else "[Info] Root perms detected, continuing..."
fi

### Update Hostname
read -p "Enter a new hostname for your docker host: " HOST_NAME
sed -i "s/raspberrypi/$HOST_NAME/" /etc/hostname
sed -i "s/raspberrypi/$HOST_NAME/" /etc/hosts

### Create config share
echo "[Info] Create docker shared config directory ($DATA_SHARE)..."
mkdir $DATA_SHARE


### Install Docker
echo "[Info] Install docker..."
echo "[Warn] Executing: get.docker.com -o get-docker.sh && sh get-docker.sh...."
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh


### HomeAssistant
echo "[Info] Install hassio pre-reqs..."
apt-get --yes --force-yes install dbus
apt-get --yes --force-yes install avahi-daemon
apt-get --yes --force-yes install jq
apt-get --yes --force-yes install apparmor-utils
apt-get --yes --force-yes install network-manager

echo "[Info] Install hassio..."
echo "[Warn] Executing: https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh...."
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh | bash -s -- -m raspberrypi3 -d $DATA_SHARE$HASSIO_DATA


### Install Portainer (web based docker admin)
echo "[Info] Install portainer..."
echo "[Info] Create portainer config location ($DATA_SHARE$PORTAINER_DATA)..."
docker volume create $DATA_SHARE$PORTAINER_DATA/
docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v $DATA_SHARE$PORTAINER_DATA:/data portainer/portainer
