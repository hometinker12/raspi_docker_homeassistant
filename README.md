# Rasbian Docker and Hass.io (Home Assistant) Automated Install


## Running Installer Script
Must be run as root!
```bash
curl -sL "https://raw.githubusercontent.com/hometinker12/raspi_docker_homeassistant/master/rpi3b_setup/initialsetup_install.sh" >> initialsetup_install.sh
chmod +x initialsetup_install.sh
sudo ./initialsetup_install.sh
```

## Post Install
After install open portainer and view the hass logs, it can take 20 minutes for hass to start.
### Portainer URL
  * http://[yourip]:9000
### HASS.io URL
  * http://[yourip]:8123
### Secure Portainer with SSL
Consider securing portainer with ssl: https://portainer.readthedocs.io/en/stable/configuration.html

Set the ssl cert to the same as your hass.io certificate:
```bash
docker stop portainer
docker rm portainer
docker run -d -p 9000:9000 --name portainer  --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /usr/share/portainer:/data portainer/portainer --ssl true --sslcert /certs/cert.pem --sslkey /certs/cert.key
```

## Raspbian Stretch Lite Images
https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-04-09/
