#!/bin/bash
DATA_SHARE=/usr/share/dockerconfigs
OVPN_DATA=/ovpn-data
PORTAINER_DATA=/ovpn-data
HASSIO_DATA=/hassio
OVPN_URL="ha.bedards.net"
SMB_USER="pi"
HOST_NAME="ha-host"


### Check root permissions
if [ "$EUID" -ne 0 ]
  then echo "[Error] Must be run as root!!!"
  exit
  else "[Info] Root perms detected, continuing..."
fi

### Update Hostname
sed -i "s/raspberrypi/$HOST_NAME/" /etc/hostname
sed -i "s/raspberrypi/$HOST_NAME/" /etc/hosts

### Create config share
echo "[Info] Create docker shared config directory ($DATA_SHARE)..."
mkdir $DATA_SHARE


### Install Docker
echo "[Info] Install docker..."
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh


### HomeAssistant
echo "[Info] Install hassio pre-reqs..."
apt-get install dbus
apt-get install avahi-daemon
apt-get install jq
apt-get install apparmor-utils
apt-get install network-manager

echo "[Info] Install hassio..."
echo "[Warn] Executing: https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh...."
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh | bash -s -- -m raspberrypi3 -d $DATA_SHARE$HASSIO_DATA


### Install Portainer (web based docker admin)
echo "[Info] Install portainer..."
echo "[Info] Create portainer config location ($DATA_SHARE$PORTAINER_DATA)..."
docker volume create $DATA_SHARE$PORTAINER_DATA/
docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v $DATA_SHARE$PORTAINER_DATA:/data portainer/portainer


### OpenVPN
echo "[Info] Install OpenVPN..."
echo "[Info] Create openvpn config location ($DATA_SHARE$OVPN_DATA)..."
mkdir $DATA_SHARE$OVPN_DATA
echo "[Info] Create OpenVPN config..."
docker run -v $DATA_SHARE$OVPN_DATA:/etc/openvpn --rm giggio/openvpn-arm ovpn_genconfig -u udp://$OVPN_URL
echo "[Info] Install OpenVPN server certificate..."
docker run -v $DATA_SHARE$OVPN_DATA:/etc/openvpn --rm -it giggio/openvpn-arm ovpn_initpki nopass
echo "[Info] Start OpenVPN..."
docker run -v $DATA_SHARE$OVPN_DATA:/etc/openvpn -d --name openvpn -p 1194:1194/udp --cap-add=NET_ADMIN giggio/openvpn-arm

### Get VPN Client Cert
echo "[Info] Generate OpenVPN client cert..."
mkdir $DATA_SHARE$OVPN_DATA/clientcert
read -p "Enter the name of your pc client: " CLIENTNAME
docker run -v $DATA_SHARE$OVPN_DATA:/etc/openvpn --rm -it giggio/openvpn-arm easyrsa build-client-full $CLIENTNAME nopass
docker run -v $DATA_SHARE$OVPN_DATA:/etc/openvpn --rm giggio/openvpn-arm ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn




### Authelia  !!!needswork
#mkdir $DATA_SHARE/authelia
#wget https://raw.githubusercontent.com/clems4ever/authelia/master/config.template.yml -O $DATA_SHARE/authelia/config.yml
#docker run -v $DATA_SHARE/authelia/config.yml:/etc/authelia/config.yml clems4ever/authelia


### NGINX  !!!needswork
#mkdir $DATA_SHARE/nginx/
#wget https://raw.githubusercontent.com/clems4ever/authelia/master/config.template.yml -O $DATA_SHARE/authelia/config.yml
#docker run --name my-custom-nginx-container -v /host/path/nginx.conf:/etc/nginx/nginx.conf:ro -d nginx
