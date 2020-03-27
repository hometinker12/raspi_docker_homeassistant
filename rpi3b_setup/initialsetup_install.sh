#!/bin/bash
DATA_SHARE="/docker"
PORTAINER_DATA="/portainer"
HASSIO_DATA="/hassio"


### Check root permissions
if [ "$EUID" -ne 0 ]
  then echo "[Error] Must be run as root!!!"
  exit
  else echo "[Info] Root perms detected, continuing..."
fi

### Update Hostname
read -p 'Enter a new hostname for your docker host: ' HOST_NAME
sed -i "s/raspberrypi/$HOST_NAME/" /etc/hostname
sed -i "s/raspberrypi/$HOST_NAME/" /etc/hosts
