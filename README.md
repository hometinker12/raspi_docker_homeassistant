# Rasbian Docker and Hass.io (Home Assistant) Automated Install


## Running Installer Script
Must be run as root!
```bash
sudo su
curl -sL https://raw.githubusercontent.com/hometinker12/raspi_docker_homeassistant/master/initialsetup_install.sh | bash -s
```

## Post Install
After install open portainer and view the hass logs, it can take 20 minutes for hass to start.
### Portainer URL
  * http://[yourip]:9000
### HASS.io URL
   http://[yourip]:8123

## Raspbian Stretch Lite Images
https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-04-09/
