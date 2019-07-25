#!/bin/bash
DATA_SHARE=/dockerconfigs
NGINX_CONFIG=/dockerconfigs
OVPN_DATA=/dockerconfigs/ovpn-data
OVPN_URL="ha.bedards.net"
SMB_USER="pi"


### Check root permissions
if [ "$EUID" -ne 0 ]
  then echo "[Error] Must be run as root!!!"
  exit
  else "[Info] Root perms detected, continuing..."
fi

### Install Samba for Docker Config Admin
echo "[Info] Create docker shared config directory ($DATA_SHARE)..."
sudo mkdir -m 1777 $DATA_SHARE
echo "[Info] Install samba for config directory access..."
sudo apt-get install samba samba-common-bin
sudo echo "[Folder Shares]" >> /etc/samba/smb.conf 
sudo echo "  [Docker App Config]" >> /etc/samba/smb.conf 
sudo echo "          Comment = Docker App Configs" >> /etc/samba/smb.conf 
sudo echo "          Path = $DATA_SHARE" >> /etc/samba/smb.conf 
sudo echo "          Browseable = yes" >> /etc/samba/smb.conf 
sudo echo "          Writeable = Yes" >> /etc/samba/smb.conf 
sudo echo "          only guest = no" >> /etc/samba/smb.conf 
sudo echo "          create mask = 0777" >> /etc/samba/smb.conf 
sudo echo "          directory mask = 0777" >> /etc/samba/smb.conf 
sudo echo "          Public = no" >> /etc/samba/smb.conf 
sudo echo "          Guest ok = no" >> /etc/samba/smb.conf 
sudo smbpasswd -a $SMB_USER
sudo /etc/init.d/samba restart

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
mkdir $OVPN_DATA
echo "[Info] Create OpenVPN config..."
docker run -v $OVPN_DATA:/etc/openvpn --rm giggio/openvpn-arm ovpn_genconfig -u udp://$OVPN_URL
echo "[Info] Install OpenVPN server certificate..."
docker run -v $OVPN_DATA:/etc/openvpn --rm -it giggio/openvpn-arm ovpn_initpki nopass
echo "[Info] Start OpenVPN..."
docker run -v $OVPN_DATA:/etc/openvpn -d --name openvpn -p 1194:1194/udp --cap-add=NET_ADMIN giggio/openvpn-arm

### Get VPN Client Cert
echo "[Info] Generate OpenVPN client cert..."
mkdir $OVPN_DATA/clientcert
read -p "Enter the name of your pc client: " CLIENTNAME
docker run -v $OVPN_DATA:/etc/openvpn --rm -it giggio/openvpn-arm easyrsa build-client-full $CLIENTNAME nopass
docker run -v $OVPN_DATA:/etc/openvpn --rm giggio/openvpn-arm ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn
