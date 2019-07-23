#!/bin/bash
DATA_SHARE=/usr/share
NGINX_CONFIG=/usr/share
OVPN_DATA="ovpn-data"
OVPN_URL="ha.bedards.net"


### Check root permissions
if [ "$EUID" -ne 0 ]
  then echo "[Error] Must be run as root!!!"
  exit
  else "[Info] Root perms detected, continuing..."
fi


### Install Docker
echo "[Info] Install docker..."
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh


### HomeAssistant
echo "[Info] Install hassio pre-reqs..."
sudo apt-get install dbus
sudo apt-get install avahi-daemon
sudo apt-get install jq
sudo apt-get install apparmor-utils
sudo apt-get install network-manager

echo "[Info] Install hassio..."
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh | bash -s -- -m raspberrypi3 -d $DATA_SHARE/hassio


### Install Portainer (web based docker admin)
echo "[Info] Install portainer..."
docker volume create $DATA_SHARE/portainer_data/
docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v $DATA_SHARE/portainer_data:/data portainer/portainer


### Authelia  !!!needswork
#mkdir $DATA_SHARE/authelia
#wget https://raw.githubusercontent.com/clems4ever/authelia/master/config.template.yml -O $DATA_SHARE/authelia/config.yml
#docker run -v $DATA_SHARE/authelia/config.yml:/etc/authelia/config.yml clems4ever/authelia


### NGINX  !!!needswork
#mkdir $DATA_SHARE/nginx/
#wget https://raw.githubusercontent.com/clems4ever/authelia/master/config.template.yml -O $DATA_SHARE/authelia/config.yml
#docker run --name my-custom-nginx-container -v /host/path/nginx.conf:/etc/nginx/nginx.conf:ro -d nginx



### OpenVPN
echo "[Info] Install OpenVPN..."
docker volume create --name $OVPN_DATA
docker run -v $OVPN_DATA:/etc/openvpn --rm giggio/openvpn-arm ovpn_genconfig -u udp://$OVPN_URL
docker run -v $OVPN_DATA:/etc/openvpn --rm -it giggio/openvpn-arm ovpn_initpki nopass

docker run -v $OVPN_DATA:/etc/openvpn -d --name openvpn -p 1194:1194/udp --cap-add=NET_ADMIN giggio/openvpn-arm

###Get VPN Client Cert
#docker run -v $OVPN_DATA:/etc/openvpn --rm -it giggio/openvpn-arm easyrsa build-client-full CLIENTNAME nopass
#docker run -v $OVPN_DATA:/etc/openvpn --rm giggio/openvpn-arm ovpn_getclient CLIENTNAME > CLIENTNAME.ovpn
